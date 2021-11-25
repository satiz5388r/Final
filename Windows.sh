provider "azurerm" {
  version = "=2.8.0"
  features {}
}

#create the resource group
resource "azurerm_resource_group" "rg" {
    name = "ateam-resource-group"
    location = "East Us"
}
#create the virtual network
resource "azurerm_virtual_network" "vnet1" {
    resource_group_name = azurerm_resource_group.rg.name
    location = "East Us"
    name = "dev"
    address_space = ["10.0.0.0/16"]
}

#create a subnet within the virtual network
resource "azurerm_subnet" "subnet1" {
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    name = "devsubnet"
    address_prefixes = ["10.0.0.0/24"]
}

##create the network interface for the VM
resource "azurerm_public_ip" "pub_ip" {
    name = "vmpubip"
    location = "East Us"
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "vmnic" {
    location = "EastUs"
    resource_group_name = azurerm_resource_group.rg.name
    name = "vmnic1"

    ip_configuration {
        name = "vmnic1-ipconf"
        subnet_id = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.pub_ip.id
    }
}
##end creating network interface for the VM


##create the actual VM
resource "azurerm_windows_virtual_machine" "devvm" {
    name = "development-vm"
    location = "East US"
    size = "Standard_A1_v2"
    admin_username = "Satiz"
    admin_password = "Satiz5388"
    resource_group_name = azurerm_resource_group.rg.name

    network_interface_ids = [azurerm_network_interface.vmnic.id]
    
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

}
