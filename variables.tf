variable "image" {
  default = "k8s-image-1.0.0"
}

variable "flavor" {
  default = "k8s-type"
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
  default = "tf-k8s"
}

variable "worker_node_count" {
  default = 1
}

variable "worker_node_prefix" {
  default = "worker"
}

variable "control_plane_private_ip" {
  default = "10.0.0.11"
}