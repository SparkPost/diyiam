 $0 == "" { group = 0; next }
 $2 ~ /module.users.aws_iam_group.group/ && $NF == "created" {
     group=1
     mod=$2
     next
 }
 group == 1 && $2 == "name" {
     print mod, substr($NF, 2, length($NF) - 2)
 }
