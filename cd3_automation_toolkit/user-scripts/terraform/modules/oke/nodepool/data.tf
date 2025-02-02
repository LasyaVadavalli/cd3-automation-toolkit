// Copyright (c) 2021, 2022, Oracle and/or its affiliates.

#############################
## Data Block - Nodepool
## Create Nodepool and nodes
#############################

locals {
  nodepool_nsg_ids = var.worker_nsg_ids != null ? flatten(tolist([for nsg in var.worker_nsg_ids : (length(regexall("ocid1.networksecuritygroup.oc1*", nsg)) > 0 ? [nsg] : data.oci_core_network_security_groups.network_security_groups_workers[nsg].network_security_groups[*].id)])) : null
  pod_nsg_ids = var.pod_nsg_ids != null ? flatten(tolist([for nsg in var.pod_nsg_ids : (length(regexall("ocid1.networksecuritygroup.oc1*", nsg)) > 0 ? [nsg] : data.oci_core_network_security_groups.network_security_groups_pods[nsg].network_security_groups[*].id)])) : null
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}


data "oci_core_vcns" "oci_vcns_nodepools" {
  for_each       = { for vcn in var.vcn_names : vcn => vcn }
  compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id
  display_name   = each.value
}

data "oci_core_subnets" "oci_subnets_pods" {
  for_each       = { for subnet in [var.pod_subnet_ids] : subnet => subnet if var.pod_subnet_ids != null}
  compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id
  display_name   = each.value
  vcn_id         = data.oci_core_vcns.oci_vcns_nodepools[var.vcn_names[0]].virtual_networks.*.id[0]
}

data "oci_core_subnets" "oci_subnets_workers" {
  for_each       = { for subnet in [var.subnet_id] : subnet => subnet if var.subnet_id != null}
  compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id
  display_name   = each.value
  vcn_id         = data.oci_core_vcns.oci_vcns_nodepools[var.vcn_names[0]].virtual_networks.*.id[0]
}

data "oci_core_network_security_groups" "network_security_groups_pods" {
  for_each       = var.pod_nsg_ids != null ? { for nsg in var.pod_nsg_ids : nsg => nsg } : {}
  compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id
  display_name   = each.value
  vcn_id         = data.oci_core_vcns.oci_vcns_nodepools[var.vcn_names[0]].virtual_networks.*.id[0]
}

data "oci_core_network_security_groups" "network_security_groups_workers" {
  for_each       = var.worker_nsg_ids != null ? { for nsg in var.worker_nsg_ids : nsg => nsg } : {}
  compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id
  display_name   = each.value
  vcn_id         = data.oci_core_vcns.oci_vcns_nodepools[var.vcn_names[0]].virtual_networks.*.id[0]
}
