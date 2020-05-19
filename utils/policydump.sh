#!/bin/bash
TEAM=$2
PROFILE=$1

POLICYLIST=( $(aws iam --profile $PROFILE list-attached-group-policies --group-name $TEAM | jq -r .AttachedPolicies[].PolicyArn))

for POLICY in ${POLICYLIST[@]}; do
	POLICYNAME=$(echo $POLICY | awk -F'/' '{print $2}')
	VERSION=$(aws --profile $PROFILE iam get-policy --policy-arn $POLICY | jq -r .Policy.DefaultVersionId)
	aws --profile $PROFILE iam get-policy-version --policy-arn $POLICY --version-id $VERSION | jq .PolicyVersion[] | head -n -3 
done
