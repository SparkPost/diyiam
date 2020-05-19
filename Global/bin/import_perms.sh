#!/bin/bash
: "${dry_run:=}"
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
real_here=$(realpath $here)
aws_profile=$1
if [ -z "$aws_profile" ]
then
    echo "You must supply the aws profile to use for this import" >&2
    echo "Usage: $0 AWS_PROFILE"
    exit 1
fi
AWS_PROFILE=$aws_profile
export aws_profile AWS_PROFILE
echo using aws_profile: "$aws_profile" >&2

die() {
    local -i code
    local msg
    code=$1
    msg=$2
    echo "Error! ${msg}"
    # shellcheck disable=2086
    exit $code
}

import() {
    local mod id
    mod=$1
    id=$2
    if [ -n "$dry_run" ]
    then
        echo ./deploy import "$mod" "$id"
    else
        ./deploy import -no-color "$mod" "$id"
    fi
}

lookup_policy() {
    local name
    name=$1
    if [ -n "$PASS_PROFILE_SUBDIR" ]
    then
        arn=$(prof aws iam list-policies --profile "$aws_profile" | jq --arg name "$name" '.[][] | select(.PolicyName == $name).Arn')
    else
        arn=$(aws iam list-policies --profile "$aws_profile" | jq --arg name "$name" '.[][] | select(.PolicyName == $name).Arn')
    fi
    echo "$arn"
}

deploy_plan() {
    local outfile message
    outfile=$1
    shift
    message=$*
    echo "Getting $message" >&2
    ./deploy plan -detailed-exitcode -no-color > "$outfile" 2>"$outfile.errors"
    retval=$?
    if [ $retval -eq 1 ]
    then
        die 1 "terraform plan failed: $(<"$tmpfile".errors)"
    fi
    echo "Wrote $message to $outfile" >&2
}

if [ -z "$dry_run" ]
then
    echo "Wiping current state (will re-import all the things)" >&2
    for mod in $(./deploy state list)
    do
        ./deploy state rm "$mod"
    done
fi

tmpfile=$(mktemp plan-XXXXX.json)
trap 'rm -f $tmpfile $tmpfile.errors' EXIT
deploy_plan "$tmpfile" "initial plan"

echo Importing Roles >&2
awk -f "$real_here"/import_roles.awk "$tmpfile" | while read -r mod role
do
    echo "Importing '$mod' - '$role'" >&2
    import "$mod" "$role"
done

echo Importing Policies and policy attachments >&2
awk -f "$real_here"/import_policies_and_attachments.awk "$tmpfile" | while read -r mod name
do
    echo "Importing '$mod' - '$name'" >&2
    arn=$(lookup_policy "$name")
    just_arn=$(echo "$arn" | awk '{print substr($0, 2, length($0) - 2)}')
    role_name=$(basename "$just_arn")
    mod_name=$(basename "$mod" | awk '{print substr($0, 1, length($0) - 2)}')
    echo "Importing '$mod_name' - '$role_name/$just_arn'" >&2
    import "$mod" "$just_arn"
    import module.svc_roles_and_policies.aws_iam_role_policy_attachment.team['"'svc_roles/"$mod_name"'"'] "$role_name/$just_arn"
done

echo Importing users >&2
awk -f "$real_here"/import_users.awk "$tmpfile" | while read -r mod user
do
    echo "Importing user $user" >&2
    import "$mod" "$user"
done

echo Importing login profiles >&2
awk -f "$real_here"/import_login_profiles.awk "$tmpfile" | while read -r mod user
do
    echo "Importing user login profile for $user" >&2
    import "$mod" "$user"
done

echo Importing groups >&2
awk -f "$real_here"/import_groups.awk "$tmpfile" | while read -r mod group
do
    echo "Importing group $group" >&2
    import "$mod" "$group"
done

echo Importing group memberships >&2
awk -f "$real_here"/import_group_memberships.awk "$tmpfile" | while read -r mod membership
do
    echo "Importing group membership $membership" >&2
    import "$mod" "$membership"
done

echo Importing group policies >&2
awk "$real_here"/import_group_policies.awk "$tmpfile" | while read -r mod name
do
    arn=$(lookup_policy "$name")
    just_arn=$(echo "$arn" | awk '{print substr($0, 2, length($0) - 2)}')
    echo "Importing policy $name" >&2
    import "$mod" "$just_arn"
done

# Get the plan again after the policy imports, so we know the arn
deploy_plan "$tmpfile" "plan which has policy_arn populated"

echo Importing group policy attachments >&2
awk -f "$real_here"/import_group_policy_attachments.awk "$tmpfile" | while read -r mod group arn
do
    echo "Importing policy attachment $group/$arn" >&2
    import "$mod" "$group"/"$arn"
done
echo Import complete
