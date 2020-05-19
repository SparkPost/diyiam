locals {
  team                    = basename(abspath(path.root))
  svc_roles               = fileset(path.root, "svc_roles/*.json")
  svc_roles_unprefixed    = fileset(path.root, "svc_roles/unprefixed/*.json")
  svc_policies            = fileset(path.root, "svc_policies/*.json")
  svc_policies_unprefixed = fileset(path.root, "svc_policies/unprefixed/*.json")
}

resource "aws_iam_role" "team" {
  for_each           = local.svc_roles
  name               = "${local.team}-ROLE-${trimsuffix(basename(each.value), ".json")}"
  assume_role_policy = file(each.value)
  tags = {
    team = local.team
  }
}

resource "aws_iam_policy" "team" {
  for_each = local.svc_policies
  name     = "${local.team}-ROLE-${trimsuffix(basename(each.value), ".json")}"
  policy   = file(each.value)
}

resource "aws_iam_role_policy_attachment" "team" {
  for_each   = aws_iam_role.team
  role       = each.value.id
  policy_arn = aws_iam_policy.team["svc_policies/${basename(each.key)}"].arn
}

resource "aws_iam_role" "team_unprefixed" {
  for_each           = local.svc_roles_unprefixed
  name               = trimsuffix(basename(each.value), ".json")
  assume_role_policy = file(each.value)
  tags = {
    team = local.team
  }
}

resource "aws_iam_policy" "team_unprefixed" {
  for_each = local.svc_policies_unprefixed
  name     = trimsuffix(basename(each.value), ".json")
  policy   = file(each.value)
}

resource "aws_iam_role_policy_attachment" "team_unprefixed" {
  for_each   = aws_iam_role.team_unprefixed
  role       = each.value.id
  policy_arn = aws_iam_policy.team_unprefixed["svc_policies/unprefixed/${basename(each.key)}"].arn
}
