# Configure the vSphere provider
provider "vsphere" {
  user           = var.user
  password       = var.password
  vsphere_server = var.vsphere_server


  # If you're using a self-signed SSL certificate, set this to true
  allow_unverified_ssl = true
}


# Get the Datacenter
data "vsphere_datacenter" "dc" {
  name = var.data_center
}


data "vsphere_compute_cluster" "cluster" {
  name                      = var.cluster
  datacenter_id             = "${data.vsphere_datacenter.dc.id}"
}


# Get the Datastore
data "vsphere_datastore" "datastore" {
  name          = var.workload_datastore
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


#data "vsphere_datastore" "iso_datastore" {
#  name          = "pure-ds01"
#  datacenter_id = data.vsphere_datacenter.dc.id
#}


#data "vsphere_datastore_cluster" "my_datastore_cluster" {
# name          = "pure01"  # Name of your Datastore Cluster
# datacenter_id = "${data.vsphere_datacenter.dc.id}"  # Datacenter ID where the datastore cluster resides
#}


# Get the Network
data "vsphere_network" "network" {
  name          = var.vmnet
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


# Get the VM Template
data "vsphere_virtual_machine" "template" {
  name          = "Oracle8-Template"  # The name of your Linux VM template (e.g., "Ubuntu_Template")
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


output "template_guest_id" {
  value = data.vsphere_virtual_machine.template.guest_id
}


output "template_id" {
  value = data.vsphere_virtual_machine.template.id
  description = "The ID of the VM template being used for cloning."
}


resource "vsphere_virtual_machine" "vm" {
  name             = var.vmname           # Name of the new VM
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"  # Resource pool to use
  datastore_id     = "${data.vsphere_datastore.datastore.id}"  # Datastore where VM will be stored
  folder           = "misc-vms/pradeep"   # Folder location in vSphere
  num_cpus         = 2
  memory           = 4096
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"  # Guest OS type for Ubuntu
  scsi_type        = "${data.vsphere_virtual_machine.template.scsi_type}"  # SCSI type from template
  firmware         = "efi"  # Set firmware type to EFI


  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
  }


  disk {
    label                   = "disk0"
    size                    = "${data.vsphere_virtual_machine.template.disks.0.size}"
    thin_provisioned        = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }


  clone {
    template_uuid = data.vsphere_virtual_machine.template.id  # The template from which the VM is cloned
    customize {
      linux_options {
        host_name = "${var.vmname}"  # Set the hostname for the VM
        domain    = "local.lab"   # Set the domain
      }
      network_interface {
        ipv4_address = null  # Static IP address
        ipv4_netmask = null              # Network mask for the subnet
      }


    }
      
  }
}



# Output the IP address of the new VM
output "vm_ip" {
  value       = vsphere_virtual_machine.vm.guest_ip_addresses[0]
  description = "The IP address of the new VM"
}
