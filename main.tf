variable "subscription_id" {
    type = string
    default = "1f5046ce-75f3-4272-a595-42190a72b8c3"
    description = "tf-dev-subcription id"
}

variable "client_id" {
    type = string
    default = "43eb84a1-9ec0-4714-bfa3-b101f51230fd"
    description = "tf-dev-clientid"
}

variable "client_secret" {
    type = string
    default = "-Hd8Q~JNIiihmKOG1m6GRAUypMXyvS-EAFwtQbQ9"
    description = "tf-dev-client secret" 
}

variable "tenant_id" {
    type = string
    default = "4017a1e2-fe41-41e2-90c6-49337c8900b7"
    description = "tf-dev-tenentid"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }
}

provider "azurerm" {
  features {

  }
     subscription_id = var.subscription_id
     client_id = var.client_id
     client_secret = var.client_secret
     tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "tflabelrg101" {
    name = "tfrg101"
    location = "EAST US"
    tags = {
      "name" = "tf-dev-101"
    }
  }

resource "azurerm_virtual_network" "tflabelvnet101" {
      name = "tfvnet101"
      resource_group_name = azurerm_resource_group.tflabelrg101.name
      location = azurerm_resource_group.tflabelrg101.location
      address_space = ["10.70.0.0/16"]
  }
  

resource "azurerm_subnet" "tflabelwebsubnet101" {
  name = "tfwebsubnet101"
  resource_group_name = azurerm_resource_group.tflabelrg101.name
  virtual_network_name = azurerm_virtual_network.tflabelvnet101.name
  address_prefixes =  [ "10.70.1.0/24" ]
}  

resource "azurerm_subnet" "tflabelappsubnet101" {
   name = "tfappsubnet101"
   resource_group_name = azurerm_resource_group.tflabelrg101.name
   virtual_network_name = azurerm_virtual_network.tflabelvnet101.name
   address_prefixes = [ "10.70.2.0/24" ]
  
}

resource "azurerm_subnet" "tflabeldbsubnet101" {
   name = "tfdbsubnet101"
   resource_group_name = azurerm_resource_group.tflabelrg101.name
   virtual_network_name = azurerm_virtual_network.tflabelvnet101.name
   address_prefixes = [ "10.70.3.0/24" ]
  
}

resource "azurerm_public_ip" "tflabelwebpublicip101" {
   name = "tfwebpublicip"
   resource_group_name =  azurerm_resource_group.tflabelrg101.name
   location = azurerm_resource_group.tflabelrg101.location
   allocation_method = "Static"
  
}

resource "azurerm_network_interface" "tflabelwebnic101" {
    name = "tfwebnic"
    location = azurerm_resource_group.tflabelrg101.location
    resource_group_name = azurerm_resource_group.tflabelrg101.name
    ip_configuration {
        name = "external"
        subnet_id = azurerm_subnet.tflabelwebsubnet101.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.tflabelwebpublicip101.id       
    }
} 

resource "azurerm_linux_virtual_machine" "tflabelwebserver101" {
  name = "tfwebserver"
  resource_group_name = azurerm_resource_group.tflabelrg101.name
  location =  azurerm_resource_group.tflabelrg101.location
  size = "standard_F2"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tflabelwebnic101.id,  
  ]
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
   caching = "ReadWrite"
   storage_account_type = "Standard_LRS" 
  }
  source_image_reference {
     publisher = "canonical"
     offer = "Ubuntuserver"
     sku = "18.04-LTS"
     version = "latest"
     
  }
}

resource "azurerm_public_ip" "tflabelapppublicip101" {
   name = "tfapppublicip"
   resource_group_name =  azurerm_resource_group.tflabelrg101.name
   location = azurerm_resource_group.tflabelrg101.location
   allocation_method = "Static"
  
}

resource "azurerm_network_interface" "tflabelappnic101" {
    name = "tfappnic"
    location = azurerm_resource_group.tflabelrg101.location
    resource_group_name = azurerm_resource_group.tflabelrg101.name
    ip_configuration {
        name = "external"
        subnet_id = azurerm_subnet.tflabelappsubnet101.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.tflabelapppublicip101.id       
    }
} 

resource "azurerm_linux_virtual_machine" "tflabelappserver101" {
  name = "tfappserver"
  resource_group_name = azurerm_resource_group.tflabelrg101.name
  location =  azurerm_resource_group.tflabelrg101.location
  size = "standard_F2"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tflabelappnic101.id,  
  ]
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
   caching = "ReadWrite"
   storage_account_type = "Standard_LRS" 
  }
  source_image_reference {
     publisher = "canonical"
     offer = "Ubuntuserver"
     sku = "18.04-LTS"
     version = "latest"
     
  }
}



  
