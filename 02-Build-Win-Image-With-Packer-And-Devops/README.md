# Build Windows Image with Packer and Azure Devops:-

Greetings my fellow Technology Advocates and Specialists.

This is __Chapter #2__ of my Packer Series.

In this Session, I will demonstrate __how to Automate image builds with Packer in Azure using Azure Devops.__ 

I had the Privilege to talk on this topic in __ONE__ Azure Communities:-

| __NAME OF THE AZURE COMMUNITY__ | __TYPE OF SPEAKER SESSION__ |
| --------- | --------- |
| __Cloud Lunch and Learn - 2024__ | __Virtual__ |

| __EVENT ANNOUNCEMENTS:-__ |
| --------- |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/05pcqojwnxhjgjfu8yta.jpg) |

| __POINTS TO NOTE:-__ |
| --------- |
| 1. Cloud Provider is __Microsoft Azure__. |
| 2. CI/CD Platform is __Microsoft Azure Devops__. |
| 3. For the purpose this blog post, we are building image for Windows using Packer and Azure Devops. |

| __PRE-REQUISITES:-__ |
| --------- |
| 1. Azure Subscription. |
| 2. Azure Resource Group. |
| 3. Azure Service Principal - This will be used by Packer to Authenticate. |
| 4. Azure Service Principal having "Contributor" RBAC on Subscription or on the specific Resource Group where Packer will create Image. |
| 5. Azure DevOps Organisation and Project. |
| 6. Azure Resource Manager Service Connection in Azure DevOps. |
| 7. Key Vault with 4 Secrets stored - 1) Azure Subscription ID, 2) Azure Tenant ID, 3) Azure Service Principal Client ID, and 4) Azure Service Principal Secret. |

| __PACKER TEMPLATE (am-packer-template-v2.pkr.hcl):-__ |
| --------- |
| This template builds a Windows Server 2019 VM, installs IIS, then generalizes the VM with Sysprep. | 
| The IIS install shows how you can use the PowerShell provisioner to run additional commands. | 
| The final Packer image then includes the required software install and configuration. |

```
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

```

| __PIPELINE CODE SNIPPET:-__ |
| --------- |

| AZURE DEVOPS YAML PIPELINE (azure-pipelines-build-image-with-packer-v1.0.yml):- |
| --------- |

```
trigger:
  none

######################
# Declare Parameters:-
######################
parameters: 
- name: KVName
  displayName: Please Provide the Keyvault Name:-
  type: object
  default: ampockv
  values:
  - ampockv

######################
#DECLARE VARIABLES:-
######################
variables:
  ServiceConnection: amcloud-cicd-service-connection
  BuildAgent: windows-latest
  packerfile: '$(Build.SourcesDirectory)/Packer/am-packer-template-v2.pkr.hcl'
  envName: NonProd

#########################
# Declare Build Agents:-
#########################
pool:
  vmImage: $(BuildAgent)

###################
# Declare Stages:-
###################

stages:

- stage: BUILD_IMAGE_PACKER 
  jobs:
  - job: BUILD_IMAGE_PACKER 
    displayName: BUILD IMAGE PACKER
    steps:
################################        
# Download Keyvault Secrets:-
################################
    - task: AzureKeyVault@2
      displayName: Fetch all Secrets from Keyvault
      inputs:
        azureSubscription: '$(ServiceConnection)'
        KeyVaultName: '${{ parameters.KVName }}'
        SecretsFilter: '*'
        RunAsPreJob: false
####################################
# Build Windows Image with Packer:-
####################################
    - task: AzureCLI@2
      displayName: Build Image With Packer
      inputs:
        azureSubscription: $(ServiceConnection)
        scriptType: ps
        scriptLocation: inlineScript
        inlineScript: |
          packer
          packer plugins install github.com/hashicorp/azure
          packer build -var "client_id=$(clientId)" -var "client_secret=$(clientsecret)" -var "subscription_id=$(subsId)" -var "tenant_id=$(tenantId)" -on-error=abort -force $(packerfile)
          
```

| __TEST THE PIPELINE EXECUTION:-__ |
| --------- | 
| 1. Pipeline executed successfully. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t9kp4i7etgo8lvbl0md9.jpg) | 
| 2. Windows Image created successfully using Packer and Azure Devops. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/snj579cwncd4o85ntwga.jpg) |

__Hope You Enjoyed the Session!!!__

__Stay Safe | Keep Learning | Spread Knowledge__
