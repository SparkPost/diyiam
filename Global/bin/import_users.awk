 $0 == "" { users = 0; next }
 $2 ~ /module.users.aws_iam_user.user/ && $NF == "created" {
     users=1
     mod=$2
     next
 }
 users == 1 && $2 == "name" {
     print mod, substr($NF, 2, length($NF) - 2)
 }
