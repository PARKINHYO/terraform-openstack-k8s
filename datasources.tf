data "openstack_networking_network_v2" "tf_k8s" {
  name = var.pool
}

data "openstack_compute_instance_v2" "tf_k8s" {
  id = openstack_compute_instance_v2.tf_k8s.id
}