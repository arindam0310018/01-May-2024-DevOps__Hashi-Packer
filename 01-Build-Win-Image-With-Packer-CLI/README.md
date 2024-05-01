# Build Windows Image with Packer CLI:-

Greetings my fellow Technology Advocates and Specialists.

This is __Chapter #1__ of my Packer Series.

In this Session, I will demonstrate __how to Automate image builds with Packer in Azure.__ 

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
| 2. For the purpose this blog post, we are building image for Windows using Packer. |

| __PRE-REQUISITES:-__ |
| --------- |
| 1. Azure Subscription. |
| 2. Azure Resource Group. |
| 3. Azure Service Principal - This will be used by Packer to Authenticate. |
| 4. Azure Service Principal having "Contributor" RBAC on Subscription or on the specific Resource Group where Packer will create Image. |
| 5. Download and Install Packer. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/z3wqhp0vvinperkruszp.jpg) |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/zsh3y63al6kau87i4x6u.jpg) |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kjg39eo9pv9jumjiy12z.jpg) |

| __UNDERSTAND PACKER TERMINOLOGY:-__ |
| --------- |
| Browse to the following link - https://developer.hashicorp.com/packer/docs/terminology |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/632s5z4uk3syzk51guq6.jpg) |

| __UNDERSTAND BUILDERS:-__ |
| --------- |
| Builders create machines and generate images from those machines for various platforms. |
| Browse to the following link - https://developer.hashicorp.com/packer/docs/builders |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/k8zz6d2ngbct84r2148x.jpg) |
| The type of builder, we will be using is __Plugin__. | 
| Click on "Plugin" (Refer the above screenshot) and it will redirect you to the following link - https://developer.hashicorp.com/packer/integrations |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5pcsw11vs4vtdknxiwjq.jpg) |
| Click on "Azure vX.X.X" (Refer the above screenshot) and it will redirect you to the following link - https://developer.hashicorp.com/packer/integrations/hashicorp/azure |
| The Azure ARM builder supports building Virtual Hard Disks (VHDs) and Managed Images in Azure Resource Manager. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/27hsaz93cbqdwu1p3nbo.jpg) |

| __PACKER TEMPLATE (am-packer-template-v1.pkr.hcl):-__ |
| --------- |
| This template builds a Windows Server 2019 VM, installs IIS, then generalizes the VM with Sysprep. | 
| The IIS install shows how you can use the PowerShell provisioner to run additional commands. | 
| The final Packer image then includes the required software install and configuration. |

```
source "azure-arm" "am-image" {
  subscription_id                   = "210e66cb-55cf-424e-8daa-6cad804ab604"
  tenant_id                         = "20516b3d-42af-4bd4-b2e6-e6b4051af72a"
  client_id                         = "54b7f78d-6b11-466c-8172-5934f104e779"
  client_secret                     = "xxxxxxxxxxxxxxxxxxxxxxx"
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

| __PACKER COMMANDS:-__ |
| --------- |
| Below follows the list of Packer commands. |
| __Note:-__ "C:\Packer" Contains the Packer executable and Packer HCL Template. |


| 1. Initialize Packer:- |
| --------- |

`.\packer.exe init C:\Packer\.
`

| 2. Format Packer Template:- |
| --------- |

`.\packer.exe fmt C:\Packer\.
`

| 3. Validate Packer:- |
| --------- |

`.\packer.exe validate C:\Packer\.
`

| 4. Build Packer:- |
| --------- |

`.\packer.exe validate C:\Packer\am-packer-template-v1.pkr.hcl
`

| __BELOW FOLLOWS ALL THE TROUBLESHOOTING STEPS:-__ |
| --------- |

| __ERROR #1:-__ |
| --------- |
| Unknown source type "azure-rm". The source "azure-rm" is unknown by Packer, and is most likely part of a plugin that is not installed. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6jjxshlr16dlb2dxhkcc.jpg) |
| __RESOLUTION:-__ |
| The Plugin was installed. |
| .\packer.exe plugins install github.com/hashicorp/azure |  
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dcr7diekbor1acgnbu50.jpg) |

| __PACKER IMAGE BUILD SUCCESFULLY COMPLETED:-__ |
| --------- |
| 1. Windows Image build execution with Packer completed successfully. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ixu1x10qy68pqexoutyn.jpg) |
| 2. During the time, Packer build runs, an actual Virtual machine with all required resources gets created in a temporary resource group. The Windows VM Image gets created from that Virtual machine and its related resources. Once the Image is created successfully, the virtual machine and all its related resources gets deleted. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yzak87hd6pzalxpo85o0.jpg) |
| 3. Finally, the Windows Image created using Packer. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ruwd3zga7b2a23wajgnf.jpg) |

__Hope You Enjoyed the Session!!!__

__Stay Safe | Keep Learning | Spread Knowledge__
