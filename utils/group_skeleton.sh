#!/bin/bash
cd $(git rev-parse --show-toplevel)

TEAM=$2
PROFILE=$1

if [[ -z $1 ]] | [[ -z $2 ]]; then 
	echo "Add the team you're creating groups for. 2 letter identifier"
	echo "Example: ./group_skeleton <awsprofile> <TEAM>"
	echo "This will build the groups in AWS for the team and profile listed."
	exit
fi

read -p "Create groups for the $TEAM team on $PROFILE? " -n 1 -r
echo   
if [[ $REPLY =~ ^[Yy]$ ]]; then

for COUNT in 01; do
	aws --profile $PROFILE iam create-group --group-name $TEAM-$COUNT
done

fi

mkdir -p $TEAM
mkdir -p $TEAM/svc_policies
mkdir -p $TEAM/svc_roles
mkdir -p $TEAM/usr_policies
touch $TEAM/usr_list
touch $TEAM/{svc_policies,svc_roles,usr_policies}/.keep
