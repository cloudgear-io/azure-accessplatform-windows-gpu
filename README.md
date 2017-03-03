# Deploy a Windows NV VM.
# **WIP** [Check releases](https://github.com/Azure/azure-accessplatform-windows-gpu/tags)
* [Prereqs](#prereqs)
* [Credits](#credits)
* [Deploy and Visualize](#deploy-and-visualize)
* [PCoIP with Teradici and NVIDIA GRID Management on Azure for M60 Visualizations](#pcoip-with-teradici-and-nvidia-grid-management-on-azure-for-m60-visualizations)
* [MSFT OSCC](#msft-oscc)
* [Reporting Bugs](#reporting-bugs)
* [Patches and pull requests](#patches-and-pull-requests)
* [Optional Usage of Operational Management Suite](#optional-usage-of-operational-management-suite)

#### Prereqs
**Obtain a Trial License Activation Code For the Teradici Windows Graphics Agent from [here](http://connect.teradici.com/cas-trial) to put in the template parameter**

* NVIDIA GRID 4.1 (369.71) with Azure Driver (Defaulted) and working
* All software installers and sample data are in D:\ and system installers like Teradici, Azure NVIDIA GRID Driver installers are in D:\DownloadInstallers

#### Credits
* The NVIDIA GRID 4.1 (369.71) with "Azure" Driver silent install works with certificate force trust - Thanks to [Mathieu Rietman](https://github.com/MathieuRietman)'s [commit on fork for the -f option](https://github.com/MathieuRietman/azure-accessplatform-windows-gpu/commit/a6bc42bc6936a75200f4d968d31ae0de00fe4e97)
* Dynamic Disk Selection with take function is as per the [Azure quickstart template](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-dynamic-data-disks-selection)

#### Deploy and Visualize
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-accessplatform-windows-gpu%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-accessplatform-windows-gpu%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

#### PCoIP with Teradici and NVIDIA GRID Management on Azure for M60 Visualizations
* PCoIP Client Download for Windows is [here](http://teradici.com/swclient-windows)
* For GRID server interfaces for GPU management, please view [the grid software management sdk user guide](https://tdcm16sg112leo8193ls102.blob.core.windows.net/tdcm16sg112leo8193ls102/367.43-369.17-grid-software-management-sdk-user-guide.pdf)
* nView needs to be enabled manually. [User Guide](http://www.nvidia.com/content/quadro/pdf/nView-user-guide.pdf)
* Collection of the user dumps for the NVIDIA Display Driver 369.71  from within the VM on Display Driver Crash if occurs.
 * Details are [here](http://nvidia.custhelp.com/app/answers/detail/a_id/3335/~/tdr-(timeout-detection-and-recovery)-and-collecting-dump-files) 
* PCoIP RC Agent Log Collection (2.7.0.4060) from the Teradici System Tray (right click Teradici Icon on System Tray) and collect Agent Logs (from the pop-up).
 * PCoIP RC Agent 2.7.0.4060 uses Multiple PCoIP encoding.
* The PCOIP Agent Logs (v1.10.*) from the Office Client machine of the end-user from <code>C:\Users<user_name>\AppData\Local\Teradici\PCoIPClient\logs</code>

#### MSFT OSCC
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

#### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/Azure/azure-accessplatform-windows-gpu/issues)

#### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.

#### Optional Usage of Operational Management Suite
**OMS Setup (for mostly Security, compliance and backup in this case) is optional and the OMS Workspace Id and OMS Workspace Key can either be kept blank or populated post the steps below.**

[Create a free account for MS Azure Operational Management Suite with workspaceName](https://login.mms.microsoft.com/signin.aspx?signUp=on&ref=ms_mms)

* Provide a Name for the OMS Workspace.
* Link your Subscription to the OMS Portal.
* Depending upon the region, a Resource Group would be created in the Sunscription like "mms-weu" for "West Europe" and the named OMS Workspace with portal details etc. would be created in the Resource Group.
* login to https://<<OMSWorkspaceName>>.portal.mms.microsoft.com 
* Add The solutions "Agent Health", "Backup", "Security & Compliance", "Activity Log Analytics" and "Protection & Recovery"  Solutions from the "Solutions Gallery" of the OMS Portal of the workspace.
* Logon to the OMS Workspace and Go to -> Settings -> "Connected Sources"  -> "Windows Servers" -> Obtain the Workspace ID like <code>ba1e3f33-648d-40a1-9c70-3d8920834669</code> and the "Primary and/or Secondary Key" like <code>xkifyDr2s4L964a/Skq58ItA/M1aMnmumxmgdYliYcC2IPHBPphJgmPQrKsukSXGWtbrgkV2j1nHmU0j8I8vVQ==</code>
* While Deploying the Template just the WorkspaceID and the Key are to be mentioned and all will be registered. **The Windows Agent is already available in the VM once WorkspaceID and Key are put in during Template deployment**.

![OMS Container](https://docs.microsoft.com/en-us/azure/log-analytics/media/log-analytics-windows-agents/oms-direct-agent-connected-sources.png)

* Then one can login to https://<<OMSWorkspaceName>>.portal.mms.microsoft.com  and monitor VM and use Log Analytics and if Required perform automated backups using the corresponding Solutions for OMS.
 * Or if the OMS Workspace and the Machines are in the same subscription, one can just connect the VM sources manually to the OMS Workspace as Data Sources.
