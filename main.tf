provider "openstack" {

}

################################################################################
# network & first control plane -> kubeadm init
# resource name: tf_k8s
################################################################################

resource "openstack_compute_keypair_v2" "tf_k8s" {
  name       = var.name
  public_key = file("${var.ssh_key_file}.pub")
}

resource "openstack_networking_network_v2" "tf_k8s" {
  name           = var.name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf_k8s" {
  name            = var.name
  network_id      = openstack_networking_network_v2.tf_k8s.id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "tf_k8s" {
  name                = var.name
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.tf_k8s.id
}

resource "openstack_networking_router_interface_v2" "tf_k8s" {
  router_id = openstack_networking_router_v2.tf_k8s.id
  subnet_id = openstack_networking_subnet_v2.tf_k8s.id
}

resource "openstack_compute_flavor_v2" "tf_k8s" {
  name  = "k8s-type"
  ram   = "2048"
  vcpus = "2"
  disk  = "20"
  is_public = true
}

resource "openstack_networking_secgroup_v2" "tf_k8s" {
  name        = var.name
  description = "Security group for the Terraform example instances"
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_22" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_80" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_scheduler" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10259
  port_range_max    = 10259
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_controller_manager" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10257
  port_range_max    = 10257
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "tf_k8s_nodeport_svc" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.tf_k8s.id
}

resource "openstack_networking_floatingip_v2" "tf_k8s" {
  pool = var.pool
}

resource "openstack_compute_instance_v2" "tf_k8s" {
  name            = "${var.name}-control-plane"
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.tf_k8s.name
  security_groups = ["${openstack_networking_secgroup_v2.tf_k8s.name}"]

  network {
    uuid = openstack_networking_network_v2.tf_k8s.id
  }
}

resource "openstack_compute_floatingip_associate_v2" "tf_k8s" {
  floating_ip = openstack_networking_floatingip_v2.tf_k8s.address
  instance_id = openstack_compute_instance_v2.tf_k8s.id

  connection {
    host        = openstack_networking_floatingip_v2.tf_k8s.address
    user        = var.ssh_user_name
    private_key = file(var.ssh_key_file)
  }

  provisioner "file" {
    source      = "kubeadm.sh"
    destination = "/tmp/kubeadm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kubeadm.sh",
      "/tmp/kubeadm.sh",
    ]
  }

  depends_on = [
    openstack_networking_floatingip_v2.tf_k8s, 
    openstack_compute_instance_v2.tf_k8s
    ]
}

################################################################################
# worker node
# resource name: worker_node
################################################################################

resource "openstack_compute_instance_v2" "worker_node" {
  count           = var.worker_node_count
  name            = format("${var.name}-${var.worker_node_prefix}-%02d", count.index + 1)
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.tf_k8s.name
  security_groups = ["${openstack_networking_secgroup_v2.tf_k8s.name}"]

  network {
    uuid = openstack_networking_network_v2.tf_k8s.id
  }

  depends_on = [openstack_compute_floatingip_associate_v2.tf_k8s]
}

resource "openstack_networking_floatingip_v2" "worker_node" {
  count = var.worker_node_count
  pool  = var.pool
}

resource "openstack_compute_floatingip_associate_v2" "worker_node" {
  count       = var.worker_node_count
  floating_ip = openstack_networking_floatingip_v2.worker_node.*.address[count.index]
  instance_id = openstack_compute_instance_v2.worker_node.*.id[count.index]

  connection {
    host        = openstack_networking_floatingip_v2.worker_node.*.address[count.index]
    user        = var.ssh_user_name
    private_key = file(var.ssh_key_file)
  }

  provisioner "file" {
    source      = "worker_node.sh"
    destination = "/tmp/worker_node.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/worker_node.sh",
      "/tmp/worker_node.sh ${data.openstack_compute_instance_v2.tf_k8s.access_ip_v4}",
    ]
  }

  depends_on = [
    openstack_networking_floatingip_v2.worker_node, 
    openstack_compute_instance_v2.worker_node
    ]
}