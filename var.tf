variable "data_center"              {
  default = "sea"
}
variable "cluster"                  {
  default = "sea-c01"
}
variable "workload_datastore"       {
   default = "pure-ds01"
}
 
variable "user"                     {
    default = ""
}
variable "password"                 {
    default = ""
}
variable "vsphere_server"           {
    default = "10.196.101.139"
}
variable "vmname"{
    description = "The name of the virtual machine"
}
variable "vmnet"{
    default = "Vlan 204 Network"
}
