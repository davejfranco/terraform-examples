variable user {}
variable password {}
variable domain {}
variable compute_endpoint {}
variable storage_endpoint {}

provider "oraclepaas" {
  version              = "~> 1.3"
  user                 = "${var.user}"
  password             = "${var.password}"
  identity_domain      = "${var.domain}"
  application_endpoint = "https://apaas.us.oraclecloud.com"
}

provider "opc" {
  version          = "~> 1.2"
  user             = "${var.user}"
  password         = "${var.password}"
  identity_domain  = "${var.domain}"
  storage_endpoint = "${var.storage_endpoint}"
}

resource "opc_storage_container" "accs-apps" {
  name = "my-accs-apps"
}

resource "opc_storage_object" "example-ruby-app" {
  name         = "app.zip"
  container    = "${opc_storage_container.accs-apps.name}"
  file         = "./app.zip"
  etag         = "${md5(file("./app.zip"))}"
  content_type = "application/zip;charset=UTF-8"
}

resource "oraclepaas_application_container" "example-ruby-app" {
  name              = "rubyWebApp"
  runtime           = "ruby"
  archive_url       = "${opc_storage_container.accs-apps.name}/${opc_storage_object.example-ruby-app.name}"
  subscription_type = "HOURLY"

  deployment {
    memory    = "1G"
    instances = 1
  }
}

output "web_url" {
  value = "${oraclepaas_application_container.example-ruby-app.web_url}"
}
