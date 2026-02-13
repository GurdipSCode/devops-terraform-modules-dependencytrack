resource "dependencytrack_policy" "this" {
  for_each = var.policies

  name      = each.value.name
  operator  = each.value.operator
  violation = each.value.violation
}

# Policy conditions
locals {
  policy_conditions = flatten([
    for policy_key, policy in var.policies : [
      for idx, cond in policy.conditions : {
        key        = "${policy_key}/${idx}"
        policy_key = policy_key
        subject    = cond.subject
        operator   = cond.operator
        value      = cond.value
      }
    ]
  ])
}

resource "dependencytrack_policy_condition" "this" {
  for_each = { for c in local.policy_conditions : c.key => c }

  policy   = dependencytrack_policy.this[each.value.policy_key].id
  subject  = each.value.subject
  operator = each.value.operator
  value    = each.value.value
}

# Policy → Project assignments
locals {
  policy_project_mappings = flatten([
    for policy_key, policy in var.policies : [
      for project_key in policy.projects : {
        key         = "${policy_key}/${project_key}"
        policy_key  = policy_key
        project_key = project_key
      }
    ]
  ])
}

resource "dependencytrack_policy_project" "this" {
  for_each = { for m in local.policy_project_mappings : m.key => m }

  policy  = dependencytrack_policy.this[each.value.policy_key].id
  project = dependencytrack_project.this[each.value.project_key].id
}
