 $0 == "" { profile = 0; next }
 $2 ~ /module.users.aws_iam_user_login_profile.user/ && $NF == "created" {
     profile=1
     mod=$2
     next
 }
 profile == 1 && $2 == "user" {
     print mod, substr($NF, 2, length($NF) - 2)
 }
