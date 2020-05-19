#!/usr/bin/env awk
# Note: The above shebang will not properly invoke this script
# awk -f <this_script> must be used

$0 == "" && membership == 1 {
    printf("%s %s", mod, user)
    for(i in groups) {
#        print "Printing group: "$groups[i] > "/dev/stderr"
        printf("/%s", groups[i])
    }
    print
}

$0 == "" { membership = 0 }

$2 ~ /module.users.aws_iam_user_group_membership.members/ && $NF == "created" {
    mod = $2
    membership = 1
    next
}

membership == 1 && $2 == "user" {
    user = substr($NF, 2, length($NF) - 2)
    next
}

membership == 1 && $2 == "groups" {
    in_group = 1
    next
}

membership == 1 && in_group > 0 && $1 == "]" {
    in_group = 0
    next
}

membership == 1 && in_group > 0 {
    in_group += 1
    groups[in_group] = substr($NF, 2, length($NF) - 3)
}
# vim: set et sw=4 ts=4 sts=4 syntax=awk :
