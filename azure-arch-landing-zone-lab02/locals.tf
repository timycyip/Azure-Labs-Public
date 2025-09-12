# Local variables for Azure Landing Zone Application
locals {
  # Location is now controlled by the variable instead of randomization
  tags = merge(var.tags, {
    Purpose    = "Azure Landing Zone Application"
    Component  = var.application_name
    CreatedOn  = formatdate("YYYY-MM-DD", timestamp())
  })
}
