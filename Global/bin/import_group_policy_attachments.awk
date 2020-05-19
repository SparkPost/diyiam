#!/usr/bin/env awk
# Note: The above shebang will not properly invoke this script
# awk -f <this_script> must be used


$0 == ""  && attach == 1 {
    print mod, group, arn
}

$0 == "" {
    attach = 0
    next
}

$2 ~ /module.users.aws_iam_group_policy_attachment.attach/ && $NF == "created" {
    attach=1
    mod=$2
    next
}

attach == 1 && $2 == "group" {
    group = substr($NF, 2, length($NF) - 2)
    next
}

attach == 1 && $2 == "policy_arn" {
    if($NF > 4){
        arn = "Known_After_Import_Of_Policy"
    } else {
        arn = substr($NF, 2, length($NF) - 2)
    }
    next
}
