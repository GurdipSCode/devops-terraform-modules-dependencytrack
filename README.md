<p align="center">
  <img src="https://raw.githubusercontent.com/DependencyTrack/dependency-track/master/docs/images/dt-logo.svg" alt="DependencyTrack" width="200"/>
</p>

<h1 align="center">Terraform Module — OWASP DependencyTrack</h1>

<p align="center">
  <a href="https://registry.terraform.io/providers/SolarFactories/dependencytrack/latest"><img src="https://img.shields.io/badge/Terraform%20Registry-SolarFactories%2Fdependencytrack-5C4EE5?logo=terraform&logoColor=white" alt="Terraform Registry"></a>
  <a href="https://github.com/SolarFactories/terraform-provider-dependencytrack/releases"><img src="https://img.shields.io/badge/Provider%20Version-%3E%3D%201.18.0-blue?logo=terraform&logoColor=white" alt="Provider Version"></a>
  <a href="https://www.terraform.io"><img src="https://img.shields.io/badge/Terraform-%3E%3D%201.0-844FBA?logo=terraform&logoColor=white" alt="Terraform"></a>
  <a href="https://dependencytrack.org"><img src="https://img.shields.io/badge/DependencyTrack-4.11%E2%80%934.13-1DB954?logo=owasp&logoColor=white" alt="DependencyTrack"></a>
  <a href="https://opensource.org/licenses/MPL-2.0"><img src="https://img.shields.io/badge/License-MPL%202.0-brightgreen?logo=open-source-initiative&logoColor=white" alt="License: MPL 2.0"></a>
  <a href="https://github.com/hashicorp/hcl"><img src="https://img.shields.io/badge/Language-HCL-7B42BC?logo=hashicorp&logoColor=white" alt="HCL"></a>
</p>

<p align="center">
  A reusable, production-ready Terraform module for managing an <a href="https://dependencytrack.org">OWASP DependencyTrack</a> instance<br/>using the <a href="https://registry.terraform.io/providers/SolarFactories/dependencytrack/latest">SolarFactories/dependencytrack</a> provider.
</p>

---

## 📁 Module Structure

```
.
├── versions.tf          # Provider & Terraform version constraints
├── projects.tf          # 📦 Projects
├── teams.tf             # 👥 Teams, permissions & ACL mappings
├── users.tf             # 🧑 Managed users, team memberships & permissions
├── policies.tf          # 📜 Policies, conditions & project assignments
├── repositories.tf      # 🗄️  Package repositories
├── oidc.tf              # 🔐 OIDC groups & team mappings
├── tags.tf              # 🏷️  Tags (API v4.13+)
├── config.tf            # ⚙️  Server config properties
└── examples/
    └── complete/        # Full working example
```

---

## 🧩 Managed Resources

| Icon | File | Resources | Description |
|:----:|------|-----------|-------------|
| 📦 | `projects.tf` | `dependencytrack_project` | Applications, libraries, containers |
| 👥 | `teams.tf` | `dependencytrack_team` · `_team_permissions` · `_acl_mapping` | Groups with shared permissions & project ACLs |
| 🧑 | `users.tf` | `dependencytrack_user` · `_user_team` · `_user_permission` | Local user accounts, memberships & permissions |
| 📜 | `policies.tf` | `dependencytrack_policy` · `_policy_condition` · `_policy_project` | Compliance policies with conditions |
| 🗄️ | `repositories.tf` | `dependencytrack_repository` | Maven, NPM, PyPI, NuGet, etc. |
| 🔐 | `oidc.tf` | `dependencytrack_oidc_group` · `_oidc_group_mapping` | SSO group → team mappings |
| 🏷️ | `tags.tf` | `dependencytrack_tag` | Reusable tags (API v4.13+) |
| ⚙️ | `config.tf` | `dependencytrack_config_property` | Server-level settings |

---

## 🔧 Requirements

| Name | Version |
|------|---------|
| ![Terraform](https://img.shields.io/badge/-Terraform-844FBA?logo=terraform&logoColor=white&style=flat-square) | `>= 1.0` |
| ![DependencyTrack](https://img.shields.io/badge/-DependencyTrack-1DB954?logo=owasp&logoColor=white&style=flat-square) | `>= 4.11` (tags & collections require 4.13) |
| ![Provider](https://img.shields.io/badge/-SolarFactories%2Fdependencytrack-5C4EE5?logo=terraform&logoColor=white&style=flat-square) | `>= 1.18.0` |

---

## 🚀 Quick Start

```hcl
# 1. Configure the provider in your root module
provider "dependencytrack" {
  host = "https://dtrack-api.example.com"
  key  = "OS_ENV"  # reads DEPENDENCYTRACK_API_KEY env var
}

# 2. Call the module
module "dependencytrack" {
  source = "path/to/this/module"

  projects = {
    my_app = {
      name        = "My Application"
      description = "Main production app"
      tags        = ["production"]
    }
  }

  teams = {
    security = {
      name         = "Security Team"
      permissions  = ["VIEW_PORTFOLIO", "VULNERABILITY_ANALYSIS"]
      project_acls = ["my_app"]
    }
  }

  policies = {
    critical_vulns = {
      name      = "Block Critical Vulns"
      operator  = "ANY"
      violation = "FAIL"
      conditions = [{
        subject  = "SEVERITY"
        operator = "IS"
        value    = "CRITICAL"
      }]
      projects = ["my_app"]
    }
  }
}
```

> 💡 See [`examples/complete/`](examples/complete/) for a full working example with all resource types.

---

## 📥 Inputs

### 📦 Projects

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `projects` | Map of projects to create | `map(object({...}))` | `{}` |

<details>
<summary>Project object attributes</summary>

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `name` | `string` | ✅ | Name of the project |
| `description` | `string` | — | Description |
| `version` | `string` | — | Version string |
| `classifier` | `string` | — | Classifier (default: `APPLICATION`) |
| `active` | `bool` | — | Active state (default: `true`) |
| `parent` | `string` | — | UUID of parent project |
| `tags` | `list(string)` | — | Tag names to assign |
| `group` | `string` | — | Namespace / group / vendor |

</details>

### 👥 Teams

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `teams` | Map of teams with permissions and ACLs | `map(object({...}))` | `{}` |

<details>
<summary>Team object attributes</summary>

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `name` | `string` | ✅ | Team name |
| `permissions` | `list(string)` | — | Permission names (e.g. `BOM_UPLOAD`, `VIEW_PORTFOLIO`) |
| `project_acls` | `list(string)` | — | Project keys from `var.projects` to grant access |

</details>

### 🧑 Users

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `users` | Map of managed user accounts | `map(object({...}))` | `{}` |

<details>
<summary>User object attributes</summary>

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `username` | `string` | ✅ | Username |
| `fullname` | `string` | ✅ | Full name |
| `email` | `string` | ✅ | Email address |
| `password` | `string` | — | Initial password (sensitive) |
| `force_password_change` | `bool` | — | Force password change on next login |
| `suspended` | `bool` | — | Account suspended |
| `teams` | `list(string)` | — | Team keys from `var.teams` |
| `permissions` | `list(string)` | — | Direct permission names |

</details>

### 📜 Policies

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `policies` | Map of compliance policies | `map(object({...}))` | `{}` |

<details>
<summary>Policy object attributes</summary>

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `name` | `string` | ✅ | Policy name |
| `operator` | `string` | ✅ | Condition operator: `ALL` or `ANY` |
| `violation` | `string` | ✅ | Violation state: `ERROR`, `WARN`, `INFO`, `FAIL` |
| `conditions` | `list(object)` | — | Policy conditions (see below) |
| `projects` | `list(string)` | — | Project keys from `var.projects` |

**Condition object:**

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `subject` | `string` | ✅ | Condition subject |
| `operator` | `string` | ✅ | Condition operator |
| `value` | `string` | ✅ | Value to compare |

</details>

### 🗄️ Repositories

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `repositories` | Map of package repositories | `map(object({...}))` | `{}` |

<details>
<summary>Repository object attributes</summary>

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `type` | `string` | ✅ | Type: `MAVEN`, `NPM`, `PYPI`, `NUGET`, `GEM`, `GITHUB`, etc. |
| `identifier` | `string` | ✅ | Repository identifier |
| `url` | `string` | ✅ | Repository URL |
| `enabled` | `bool` | — | Enabled (default: `true`) |
| `internal` | `bool` | — | Internal repo (default: `false`) |
| `username` | `string` | — | Auth username |
| `password` | `string` | — | Auth password (sensitive) |

</details>

### 🔐 OIDC Groups

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `oidc_groups` | Map of OIDC groups with team mappings | `map(object({...}))` | `{}` |

<details>
<summary>OIDC group object attributes</summary>

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `name` | `string` | ✅ | OIDC group name |
| `teams` | `list(string)` | — | Team keys from `var.teams` |

</details>

### ⚙️ Config & 🏷️ Tags

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `config_properties` | Map of server config properties | `map(object({...}))` | `{}` |
| `tags` | List of tag names to create (API v4.13+) | `list(string)` | `[]` |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| `project_ids` | `map` — project keys → DependencyTrack UUIDs |
| `projects` | `map` — full project resource objects |
| `team_ids` | `map` — team keys → UUIDs |
| `user_ids` | `map` — user keys → usernames |
| `policy_ids` | `map` — policy keys → UUIDs |
| `repository_ids` | `map` — repository keys → UUIDs |
| `oidc_group_ids` | `map` — OIDC group keys → UUIDs |
| `tag_ids` | `map` — tag names → IDs |

---

## 🔑 Provider Authentication

The provider must be configured in your **root module** (not inside the child module). Three auth methods are supported:

<details>
<summary><strong>API Key</strong> (most common)</summary>

```hcl
provider "dependencytrack" {
  host = "https://dtrack-api.example.com"
  key  = "OS_ENV"  # reads DEPENDENCYTRACK_API_KEY env var
}
```

</details>

<details>
<summary><strong>Bearer Token</strong></summary>

```hcl
provider "dependencytrack" {
  host = "https://dtrack-api.example.com"
  auth = {
    type   = "BEARER"
    bearer = var.bearer_token
  }
}
```

</details>

<details>
<summary><strong>mTLS + API Key</strong></summary>

```hcl
provider "dependencytrack" {
  host    = "https://dtrack-api.example.com"
  key     = "OS_ENV"
  root_ca = file("${path.module}/ca.pem")
  mtls = {
    key_path  = "/opt/client.key"
    cert_path = "/opt/client.crt"
  }
}
```

</details>

---

## 📋 Compatibility

| Component | Supported Versions |
|-----------|-------------------|
| ![Terraform](https://img.shields.io/badge/-Terraform-844FBA?logo=terraform&logoColor=white&style=flat-square) | `1.0` — `1.14` |
| ![DependencyTrack](https://img.shields.io/badge/-API-1DB954?logo=owasp&logoColor=white&style=flat-square) | `4.11.7` · `4.12.7` · `4.13.0` — `4.13.6` |
| ![Provider](https://img.shields.io/badge/-Provider-5C4EE5?logo=terraform&logoColor=white&style=flat-square) | `>= 1.18.0` |

> **Note:** Tags (`dependencytrack_tag`) and project collection logic require API **v4.13+**.

---

## 📄 License

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg?style=for-the-badge)](https://opensource.org/licenses/MPL-2.0)
