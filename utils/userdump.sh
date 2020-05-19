#!/bin/bash
TEAM=$2
PROFILE=$1

aws --profile $PROFILE iam get-group --group-name $TEAM | jq -r .Users[].UserName

