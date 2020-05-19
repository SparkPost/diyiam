#!/usr/bin/env bash
#
# This script imports all the users given as arguments to the current module's terraform
# state file. This is useful when moving users from one team to another. You remove
# their state from one group's module and import it into another. This avoids removing
# and re-creating the user entry, as terraform would otherwise want to do.
#
# Usage: import_users.sh <AWS USERNAME>

usage() {
    echo "$0 TEAM_NAME USER1 USER2 USER3 ..."
}

die() {
    local -i code
    local msg
    code=$1
    msg=$2
    echo "Error! -> $msg" >&2
    # shellcheck disable=SC2086
    exit $code
}

if [ $# -lt 2 ]
then
    die 1 "Must pass a team name and at least one username"
fi

team_name=$1
[ -d "./$team_name" ] || die 2 "The team named ${team_name} does not seem to exist in $(pwd)"
shift
cd "$team_name" || die 3 Could not cd to "$(pwd)/$team_name"
users=$*
echo "Importing $# user(s)" >&2
for user in $users
do
    echo Importing "$user" >&2
    ./deploy import "module.users.aws_iam_user.user[\"$user\"]" "$user"
    ./deploy import "module.users.aws_iam_user_login_profile.user[\"$user\"]" "$user"
done
echo "Import complete" >&2
