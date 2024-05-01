variable "subscription_id" {
  type = string
  default = "" 
}

variable "tenant_id" {
  type = string
  default = "" 
}

variable "client_id" {
  type = string
  default = "" 
}

variable "client_secret" {
  sensitive = true
  type = string
  default = "" 
}

source "azure-arm" "am-image" {
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  managed_image_name                = "am-image-v1"
  managed_image_resource_group_name = "am-packer-rg"
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2019-Datacenter"
  location                          = "westeurope"
  os_type                           = "Windows"
  vm_size                           = "Standard_B4ms"
  winrm_insecure                    = "true"
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = "true"
  winrm_username                    = "packeradmin"
}

build {
  sources = ["source.azure-arm.am-image"]

  provisioner "powershell" {
    inline = ["Add-WindowsFeature Web-Server", "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }", "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }", "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit", "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }

}
