variable "image" {
  default = "k8s-image-1.0"
}

variable "flavor" {
  default = "k8s-flaver-test"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "pool" {
  default = "public"
}

variable "name" {
  default = "terraform-k8s-test"
}