$0 == "" { roles = 0; next }
$2 ~ /module.svc_roles_and_policies.aws_iam_role.team/ && $NF == "created" {
    roles = 1
    mod=$2
}
roles == 1 && $2 == "name" {
    print mod, substr($NF, 2, length($NF) - 2)
}
