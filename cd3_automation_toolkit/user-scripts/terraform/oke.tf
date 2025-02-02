# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl


# cluster creation for oke
module "clusters" {
  source = "./modules/oke/cluster"
  for_each = var.clusters
  display_name = each.value.display_name 
  compartment_id = each.value.compartment_id != null ? (length(regexall("ocid1.compartment.oc1*", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartment_ocids[each.value.compartment_id]) : null
  network_compartment_id = each.value.network_compartment_id != null ? (length(regexall("ocid1.compartment.oc1*", each.value.network_compartment_id)) > 0 ? each.value.network_compartment_id : var.compartment_ocids[each.value.network_compartment_id]) : null
  vcn_names = [each.value.vcn_name]
  kubernetes_version = each.value.kubernetes_version
  is_kubernetes_dashboard_enabled = each.value.is_kubernetes_dashboard_enabled
  is_tiller_enabled = each.value.is_tiller_enabled
  cni_type = each.value.cni_type
  is_public_ip_enabled = each.value.is_public_ip_enabled
  nsg_ids = each.value.nsg_ids
  endpoint_subnet_id = each.value.endpoint_subnet_id
  is_pod_security_policy_enabled = each.value.is_pod_security_policy_enabled
  pods_cidr = each.value.pods_cidr
  services_cidr = each.value.services_cidr
  service_lb_subnet_ids = each.value.service_lb_subnet_ids
  defined_tags = each.value.defined_tags
  freeform_tags = each.value.freeform_tags
}

module "nodepools" {
  source = "./modules/oke/nodepool"
  for_each = var.nodepools
  tenancy_ocid = var.tenancy_ocid
  display_name = each.value.display_name
  availability_domain = each.value.availability_domain
  cluster_name = length(regexall("ocid1.cluster.oc1*", each.value.cluster_name)) > 0 ? each.value.cluster_name : merge(module.clusters.*...)[each.value.cluster_name]["cluster_tf_id"]
  compartment_id = each.value.compartment_id != null ? (length(regexall("ocid1.compartment.oc1*", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartment_ocids[each.value.compartment_id]) : null
  network_compartment_id = each.value.network_compartment_id != null ? (length(regexall("ocid1.compartment.oc1*", each.value.network_compartment_id)) > 0 ? each.value.network_compartment_id : var.compartment_ocids[each.value.network_compartment_id]) : null
  vcn_names = [each.value.vcn_name]
  node_shape = each.value.node_shape
  initial_node_labels = each.value.initial_node_labels
  kubernetes_version = each.value.kubernetes_version
  subnet_id = each.value.subnet_id
  size = each.value.size
  is_pv_encryption_in_transit_enabled = each.value.is_pv_encryption_in_transit_enabled
  cni_type = each.value.cni_type
  max_pods_per_node = each.value.max_pods_per_node
  pod_nsg_ids = each.value.pod_nsg_ids
  pod_subnet_ids = each.value.pod_subnet_ids
  worker_nsg_ids = each.value.worker_nsg_ids
  memory_in_gbs = each.value.memory_in_gbs
  ocpus = each.value.ocpus
  image_id = length(regexall("ocid1.image.oc1*", each.value.image_id)) > 0 ? each.value.image_id : var.oke_source_ocids[each.value.image_id]
  source_type = each.value.source_type
  boot_volume_size_in_gbs = each.value.boot_volume_size_in_gbs
  ssh_public_key = each.value.ssh_public_key!= null? (length(regexall("ssh-rsa*", each.value.ssh_public_key)) > 0 ? each.value.ssh_public_key : lookup(var.oke_ssh_keys, each.value.ssh_public_key, null)) : null
  node_defined_tags = each.value.node_defined_tags
  node_freeform_tags = each.value.node_freeform_tags
  nodepool_defined_tags = each.value.nodepool_defined_tags
  nodepool_freeform_tags = each.value.nodepool_freeform_tags
}

