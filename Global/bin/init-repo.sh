#!/bin/bash
here=$(pwd)
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
    echo Usage: "$0" PROFILE
}

[ -d ./Global ] || die 1 "Must run from the root of an iam_mgmt tree (Cannot find ./Global)"

prof=$1
[ -n "$prof" ] || die 1 "You must specify an AWS Profile to use"
echo "Using profile $prof"
echo Running from "$here"

if [ ! -f tf_module_prefix ]
then
    prefix=$(basename "$here")
    read -n1 -r -p "Directory is $prefix, would you like to change the S3 state bucket prefix from CC/$prefix/ to something else? " yn
    echo
    if [[ "$yn" =~ ^[Yy] ]]
    then
        read -r -p "You answered Yes, enter the prefix to use now:" prefix
        read -r -n1 -p "Prefix will now be CC/$prefix/ for all s3 state keys. Is this correct?" yn2
        echo
        [[ "$yn2" =~ ^[Yy] ]] || die 4 "Ok, bailing. Re-run this script to continue initialization with different prefix"
    else
        echo "You answered No"
    fi
    echo "s3 state files will be stored in CC/$prefix/<TEAM>/terraform.tfstate where TEAM is the directory name of the TEAM" 
    echo "$prefix" > tf_module_prefix
fi

for sh in apply_perms import_users detach_users
do
    [ -L ./"${sh}.sh" ] || ln -s "Global/bin/${sh}.sh"
    [ -L ./"${sh}.sh" ] || die 2 "Failed to link ${sh}.sh"
done
[ -d ./shared ] || mkdir -p shared
cd shared || die 3 "Could not cd to ./shared"
[ -L ./deploy ] || ln -s ../Global/bin/deploy
for tf in ../Global/shared/*.tf
do
    [ -f ./"$(basename "$tf")" ] || ln -s "$tf"
done
for tf in providers globals
do
    [ -L ./"${tf}.tf" ] || ln -s ../Global/"${tf}.tf"
    [ -L ./"${tf}.tf" ] || die 4 "Could not link ${tf}.tf"
done

echo "Ready to Rock! (don't forget to commit changes to git)"
