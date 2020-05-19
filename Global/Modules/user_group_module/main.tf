locals {
  team_name = basename(abspath(path.root))
  policies  = fileset("usr_policies/", "*.json")
  user_list = split("\n", file("usr_list"))
  tags      = merge(var.tags, { managed_by = "Terraform" })
}

locals {
  group_count = length(local.policies) / 10
}

locals {
  group_range = range(1, local.group_count + 1)
}

locals {
  chunked_policies = chunklist(local.policies, 10)
  group_list       = toset([for n in local.group_range : "${local.team_name}-0${n}"])
  users            = toset([for line in local.user_list : split(",", line)[0] if line != ""])
}

resource aws_iam_user "user" {
  for_each = local.users
  name     = each.value
  tags     = merge(local.tags, { 
    Name = title(join(" ", split(".", split("@", each.value)[0])))
    team = local.team_name
  })
  force_destroy = true
  lifecycle {
    ignore_changes = [
      tags["team"]
    ]
  }
}

resource aws_iam_user_login_profile "user" {
  for_each = aws_iam_user.user
  pgp_key  = var.gpg_key
  user     = each.value.name
  lifecycle {
      ignore_changes = [password_length, password_reset_required, pgp_key]
  }
}

resource aws_iam_group "group" {
  for_each = local.group_list
  name     = each.value
}

resource aws_iam_user_group_membership "members" {
  for_each = aws_iam_user.user
  user     = each.value.name
  groups   = [ for g in aws_iam_group.group : g.name ]
}

resource aws_iam_policy "policy1" {
  for_each = toset(length(local.chunked_policies) > 0  ? local.chunked_policies[0] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy2" {
  for_each = toset(length(local.chunked_policies) > 1  ? local.chunked_policies[1] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy3" {
  for_each = toset(length(local.chunked_policies) > 2  ? local.chunked_policies[2] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy4" {
  for_each = toset(length(local.chunked_policies) > 3  ? local.chunked_policies[3] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy5" {
  for_each = toset(length(local.chunked_policies) > 4  ? local.chunked_policies[4] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy6" {
  for_each = toset(length(local.chunked_policies) > 5  ? local.chunked_policies[5] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy7" {
  for_each = toset(length(local.chunked_policies) > 6  ? local.chunked_policies[6] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy8" {
  for_each = toset(length(local.chunked_policies) > 7  ? local.chunked_policies[7] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_policy "policy9" {
  for_each = toset(length(local.chunked_policies) > 8  ? local.chunked_policies[8] : [])
  name     = "${local.team_name}-${trimsuffix(basename(each.value), ".json")}"
  policy   = file("usr_policies/${each.value}")
}

resource aws_iam_group_policy_attachment "attach1" {
  for_each   = aws_iam_policy.policy1
  group      = "${local.team_name}-01"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach2" {
  for_each   = aws_iam_policy.policy2
  group      = "${local.team_name}-02"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach3" {
  for_each   = aws_iam_policy.policy3
  group      = "${local.team_name}-03"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach4" {
  for_each   = aws_iam_policy.policy4
  group      = "${local.team_name}-04"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach5" {
  for_each   = aws_iam_policy.policy5
  group      = "${local.team_name}-05"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach6" {
  for_each   = aws_iam_policy.policy6
  group      = "${local.team_name}-06"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach7" {
  for_each   = aws_iam_policy.policy7
  group      = "${local.team_name}-07"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach8" {
  for_each   = aws_iam_policy.policy8
  group      = "${local.team_name}-08"
  policy_arn = each.value.arn
}

resource aws_iam_group_policy_attachment "attach9" {
  for_each   = aws_iam_policy.policy9
  group      = "${local.team_name}-09"
  policy_arn = each.value.arn
}

output "passwords" {
  value = { for u in aws_iam_user_login_profile.user : u.user => aws_iam_user_login_profile.user[u.user].encrypted_password if aws_iam_user_login_profile.user[u.user].encrypted_password != ""}
}
