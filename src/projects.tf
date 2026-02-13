resource "dependencytrack_project" "this" {
  for_each = var.projects

  name        = each.value.name
  description = each.value.description
  version     = each.value.version
  classifier  = each.value.classifier
  active      = each.value.active
  parent      = each.value.parent
  tags        = each.value.tags
  group       = each.value.group
}
