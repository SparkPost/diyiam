#!/bin/bash
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
echo Running from "$here" >&2

die() {
    local -i code
    local msg
    code=$1
    msg=$2
    echo "ERROR! $msg" >&2
    echo >&2
    usage
    # shellcheck disable=SC2086
    exit $code
}

usage() {
    echo Usage: "$0" PROFILE TEAM
}

# Grab our arguments and shift them off the ARGV, so the remaining arguments
# can be passed to `./deploy apply` (`terraform apply`) later.
prof=$1
[ -n "$prof" ] || die 1 "You must specify an AWS Profile to use"
shift
team=$1
[ -n "$team" ] || die 2 "You must specify a TEAM"
shift

: "${TF_VAR_gpg_key_file:=}"
if [ -z "$TF_VAR_gpg_key_file" ]
then
    die 5 "You muxt export the TF_VAR_gpg_key_file to use this module. This file can be created with gpg --export <pubkey> | base64 > /path/to/gpg_key_file"
fi

# Initialize the team's terraform module
cd "$here/$team" || die 3 "Could not cd to $here/$team"
if [ ! -L ./deploy ]
then 
    echo "No ./deploy found, initializing for $team"
    ../shared/deploy init || die 4 "Error initializing environment"
    echo "aws_profile = \"$prof\"" > vars.auto.tfvars
    ../Global/bin/import_perms.sh "$prof" || die 5 "Error importing permissions"
else
    ./deploy init || die 4 "Error initializing environment"
fi

# Set up planfiles and ensure they're removed on exit
planfile=$(mktemp /tmp/terraform-iam-plan-XXXXX.$$)
plainplan=$(mktemp /tmp/terraform-iam-plainplan-XXXXX.$$)
trap 'rm -f $planfile $plainplan' EXIT

echo "Gathering changes for $team in profile $prof" >&2

# Run the terraform plan and save the execution plan
./deploy plan -no-color -detailed-exitcode -out "$planfile" | tee "$plainplan"
exitcode=${PIPESTATUS[0]}
echo "exit code of terraform plan was $exitcode" >&2
# shellcheck disable=SC2086
if [ $exitcode -eq 0 ]
then
    echo No changes to apply for "$team"
    exit
fi
# shellcheck disable=SC2086
[ $exitcode -eq 2 ] || die 6 "There was an error getting an execution plan for $team"

# Show the planfiles so they can be examined if desired
echo -n "Planfile: " >&2
ls -l "$plainplan" >&2
echo -n "Binary Planfile: " >&2
ls -l "$planfile" >&2
destroyed=$(awk '$2 ~ /^module\.[^\.]*\.aws_iam_user\.user/ && $NF == "destroyed" { print $2 }' "$plainplan")
if [ -n "$destroyed" ]
then
    echo "User(s) will be destroyed with this plan: $destroyed" >&2
    # Remove the -auto-approve arg since a user could be destroyed
    if [[ "$*" =~ -auto-approve ]]
    then
        for arg
        do
			shift
			[ "$arg" = "-auto-approve" ] && continue
			set -- "$@" "$arg"
		done
    fi
fi

# If -auto-approve was passed as an argument, do not ask for confirmation
if [[ "$*" =~ -auto-approve ]]
then
    yn=y
else
    read -t 300 -n 1 -p "Do you want to apply this plan to the $team team? " -r yn
    exitcode=$?
    echo
    [ $exitcode -gt 127 ] && die 7 "Timed out reading input (> 300 seconds)"
    [ $exitcode -eq 0 ]   || die 8 "Something went wrong reading input"
fi


if [[ "$yn" =~ ^[Yy] ]]
then
    # Apply the plan
    echo "Pushing users, roles, and policies for $team in profile $prof" >&2
    exec ./deploy apply "$@" "$planfile"
else
    echo "Ok, exiting without applying changes to $team (you answered $yn)"
fi
