variable "ami_id" {
  type    = string
  default = "ami-0e001c9271cf7f3b9"
  
}


variable "jar_version" {
  type    = string
  default = "3.2.0"
}

locals {
  app_name = "pet-clinic-java"
}

source "amazon-ebs" "java" {
  ami_name      = "packer-${local.app_name}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ubuntu"

  access_key = "XXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXX"
  
  tags = {
    Env  = "dev"
    Name = "packer-${local.app_name}"
  }
}

build {

  sources = ["source.amazon-ebs.java"]

  provisioner "shell" {
    script = "./java.sh"
  }

  provisioner "file" {
    source      = "../petclinicjar/spring-petclinic-${var.jar_version}.jar"
    destination = "/opt/deployment/app.jar"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
