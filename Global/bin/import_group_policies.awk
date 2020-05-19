 $0 == "" { policy = 0; next }
 $2 ~ /module.users.aws_iam_policy.policy/ && $NF == "created" {
     policy=1
     mod=$2
     next
 }
 policy == 1 && $2 == "name" {
     print mod, substr($NF, 2, length($NF) - 2)
 }
