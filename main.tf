terraform {
  required_providers {
    okta = {
      source = "okta/okta"
      version = "~> 3.22.1"
    }
  }
}

# Configure the Okta Provider
provider "okta" {
  org_name  = "dev-221567"
  base_url  = "okta.com"
  api_token = "************"
}

#Create user
resource "okta_user" "testUser" {
  first_name           = "John"
  last_name            = "Smith"
  login                = "example@example.com"
  email                = "example@example.com"
  password 			   = "Welcome@123"
}

#Read group
data "okta_group" "TestGroup" {
  name = "Test"
}

#Add user to group
resource "okta_user_group_memberships" "testUser_group" {
  user_id = okta_user.testUser.id
  groups = [
   data.okta_group.TestGroup.id,
  ]
  depends_on = [
   okta_user.testUser,data.okta_group.TestGroup
  ]
}
#add custom attribute
resource "okta_user_schema_property" "dob_extension" {
  index  = "date_of_birth"
  title  = "Date of Birth"
  type   = "string"
  master = "PROFILE_MASTER"
}
resource "okta_admin_role_custom" "example" {
  label       = "AppAssignmentManager"
  description = "This role allows app assignment management"
  permissions = ["okta.apps.assignment.manage"]
}


resource "okta_user_admin_roles" "test" {
  user_id     = okta_user.testUser.id
  admin_roles = [
    "READ_ONLY_ADMIN",
  ]
  depends_on = [
   okta_admin_role_custom.example
  ]
}
data "okta_group" "example" {
  name = "Everyone"
}
resource "okta_policy_signon" "example" {
  name            = "example"
  status          = "ACTIVE"
  description     = "Example"
  groups_included = [data.okta_group.example.id,
  ]
}
resource "okta_policy_signon" "test" {
  name = "Example Policy"
  status = "ACTIVE"
  description = "Example Policy"
}

data "okta_behavior" "new_city" {
  name = "New City"
}

resource "okta_policy_rule_signon" "example" {
  access = "CHALLENGE"
  authtype = "RADIUS"
  name = "Example Policy Rule"
  network_connection = "ANYWHERE"
  policy_id = okta_policy_signon.example.id
  status = "ACTIVE"
  risc_level = "ANY"
  behaviors = [data.okta_behavior.new_city.id]
  mfa_prompt= "SESSION"
}


