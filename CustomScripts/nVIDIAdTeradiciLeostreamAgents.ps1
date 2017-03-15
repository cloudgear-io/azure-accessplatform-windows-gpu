$dest = "D:\Downloadinstallers\"
$opendtectloc="D:\OpendTect\"
$leostreamAgentVer = $args[0]
$teradiciAgentVer = $args[1]
$nvidiaVer = $args[2]
$storageAcc = $args[3]
$conName = $args[4]
$license = $args[5]
$nvidiaazureURL = $args[6]
$nvidiaazure = $args[7]
$softwareExeName = $args[8]
$omsWorkSpaceId = $args[9]
$omsWorkSpaceKey = $args[10]
$nuget4dockerVer = $args[11]
$registryPath = "HKLM:\Software\Teradici\PCoIP\pcoip_admin"
$Name = "pcoip.max_encode_threads"
$value = "8"
$Date = Get-Date

New-Item -Path $dest -ItemType directory
New-Item -Path $opendtectloc -ItemType directory


function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}


if ($softwareExeName -like '*OpendTect*')
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $softwareUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/{2}", $storageAcc, $conName, $softwareExeName)
     Write-Host "OpendTect download is from '$softwareUrl'"
    $softwareName = "OpendTect_Installer_win64.exe"
    $softwarePath = [System.String]::Format("{0}{1}", $dest, $softwareName)
    $softUrl = [System.String]::Format("{0}",$softwareUrl)
    $softPath = [System.String]::Format("{0}",$softwarePath)
    $opendTectGetResp = Invoke-WebRequest $softUrl -UseBasicParsing
    [io.file]::WriteAllBytes($softPath, $opendTectGetResp.Content)
    #Start-Sleep -s 60
    
    <# Download the large Sample block manually
    Write-Host "Get the Sample Block for OpendTect"
    $nlblockzip = "opendTect/F3_Demo_2016_training_v6.zip"
    $nlblockUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/{2}", $storageAcc, $conName, $nlblockzip)
    $nlblkurl = [System.String]::Format("{0}",$nlblockUrl)
    $nlblockName = "F3_Demo_2016_training_v6.zip"
    Write-Host "NL F3 Block download is from '$nlblockUrl'"
    $nlblockPath = [System.String]::Format("{0}{1}", $dest, $nlblockName)
    $nlblockGetResp = Invoke-WebRequest $nlblkurl -UseBasicParsing
    [io.file]::WriteAllBytes($nlblockPath, $nlblockGetResp.Content)#>
        
  }
else
{
    Write-Host "No Software Chosen for Install in NVs"
}

if ($nvidiaazure -match "Yes")
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $nvidiacerUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/nvidia.zip", $storageAcc, $conName)
    $nvcerUrl = [System.String]::Format("{0}",$nvidiacerUrl)
    $nvcerGetResp = Invoke-WebRequest $nvcerUrl -UseBasicParsing
    [io.file]::WriteAllBytes("D:\Downloadinstallers\nvidia.zip", $nvcerGetResp.Content)
    Unzip "D:\Downloadinstallers\nvidia.zip" "D:\"
    certutil -f -addstore "TrustedPublisher" D:\nvidia.cer
    $nvidiaUrl = [System.String]::Format("{0}",$nvidiaazureURL)
    Write-Host "The NVIDIA Driver exe Url  is '$nvidiaUrl'"
    $nvidiaGetResp = Invoke-WebRequest $nvidiaUrl -UseBasicParsing
    [io.file]::WriteAllBytes("D:\Downloadinstallers\NVAzureDriver.zip", $nvidiaGetResp.Content)
    Unzip "D:\Downloadinstallers\NVAzureDriver.zip" "D:\NVIDIAazure"
    $NVIDIAfolder = [System.String]::Format("D:\NVIDIAazure")
  }
else
{ 
	$nvidiaUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/{2}_grid_win10_server2016_64bit_international.exe", $storageAcc, $conName, $nvidiaVer)
	$nvidiaExeName = [System.IO.Path]::GetFileName($nvidiaUrl)
	$nvidiaExePath = [System.String]::Format("{0}{1}", $dest, $nvidiaExeName)
	Write-Host "The NVIDIDA exe download location is '$nvidiaExePath'"
	Write-Host "The NVIDIA Driver exe Url  is '$nvidiaUrl'"
	Write-Host "The NVIDIA exe name is '$nvidiaExeName'"
	$nvidiaExeGetResp = Invoke-WebRequest $nvidiaUrl -UseBasicParsing
	[io.file]::WriteAllBytes($nvidiaExePath, $nvidiaExeGetResp.Content)
	& $nvidiaExePath  /s
	Start-Sleep -s 120
	$NVIDIAfolder = [System.String]::Format("C:\NVIDIA\{0}", $nvidiaVer)
}

Write-Host "The NVIDIA Folder name is '$NVIDIAfolder'"
Set-Location $NVIDIAfolder
Set-ExecutionPolicy Unrestricted -force
.\setup.exe -s -noreboot -clean
Start-Sleep -s 360

if ($license) {
	$teradiciAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/PCoIP_agent_release_installer_{2}_graphics.exe", $storageAcc, $conName, $teradiciAgentVer)
	$teradiciExeName = [System.IO.Path]::GetFileName($teradiciAgentUrl)
	$teradiciExePath = [System.String]::Format("{0}{1}", $dest, $teradiciExeName)
	$leostreamAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/LeostreamAgentSetup{2}.exe", $storageAcc, $conName, $leostreamAgentVer)
	$leostreamExeName = [System.IO.Path]::GetFileName($leostreamAgentUrl)
	$leostreamExePath = [System.String]::Format("{0}{1}", $dest, $leostreamExeName)
	Write-Host "The Teradici Agent exe  Url  is '$teradiciAgentUrl'"
	Write-Host "The Teradici Agent exe name is '$teradiciExeName'"
	Write-Host "The Teradici Agent exe downloaded location is '$teradiciExePath'"
	Write-Host "The Leostream Agent exe Url is '$leostreamAgentUrl'"
	Write-Host "The Leostream Agent exe name is '$leostreamExeName'"
	Write-Host "The Leostream Agent exe downloaded location is '$leostreamExePath'"
	$teradiciAgentUrlGetResp = Invoke-WebRequest $teradiciAgentUrl -UseBasicParsing
	[io.file]::WriteAllBytes($teradiciExePath, $teradiciAgentUrlGetResp.Content)
	$leostreamAgentUrlGetResp = Invoke-WebRequest $leostreamAgentUrl -UseBasicParsing
	[io.file]::WriteAllBytes($leostreamExePath, $leostreamAgentUrlGetResp.Content)
	& $teradiciExePath /S /NoPostReboot
	Start-Sleep -s 240 
	Write-Host "teradiciagent install over"
	cd 'C:\Program Files (x86)\Teradici\PCoIP Agent\licenses\'
	Write-Host "pre-activate"
	.\appactutil.exe -served -comm soap -commServer https://teradici.flexnetoperations.com/control/trdi/ActivationService -entitlementID $license
	Write-Host "activation over"
	if ((($teradiciAgentVer -match "2.7.0.4060") -or ($teradiciAgentVer -like '*2.8*')) -and ($nvidiaVer -match "369.71"))
	{
		if ($teradiciAgentVer -match "2.7.0.4060")
		{
		  IF(!(Test-Path $registryPath))
			  {
			  New-Item -Path $registryPath -Force | Out-Null
			  New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
			  }
		  ELSE 
			  {
			  New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
			  }
		 }
		 else
		 { 
			Write-Host  "Agent 2.8 - No Registry entry required"
		 }

			<# NVIDIA driver kicking Only needed for 369.71 driver #>
			Write-Host "Driver kick needed for this NVIDIA graphics driver 369.71, kicking now..."
			Set-Location "C:\Program Files (x86)\Teradici\PCoIP Agent\GRID"
    
			Write-Host "Stopping NVIDIA Display Driver"
			net stop nvsvc
			Start-Sleep -s 90
    
			Write-Host "Disabling NVFBC capture"
			./NvFBCEnable -disable
			Start-Sleep -s 90
    
			Write-Host "Enabling NVFBC capture"
			./NvFBCEnable -enable
			Start-Sleep -s 90
    
			Write-Host "Starting NVIDIA Display Driver"
			net start nvsvc
			Start-Sleep -s 90
	}
	else
	{ 
		Write-Host  "Not 369.71."
	}

}


<#OMS Hook#>
if ($omsWorkSpaceId -and $omsWorkSpaceKey) {
	$omsAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/MMASetup-AMD64.exe", $storageAcc, $conName)
	$omsExeName = [System.IO.Path]::GetFileName($omsAgentUrl)
	$omsExePath = [System.String]::Format("{0}{1}", $dest, $omsExeName)
	$omsAgentUrlGetResp = Invoke-WebRequest $omsAgentUrl -UseBasicParsing
	[io.file]::WriteAllBytes($omsExePath, $omsAgentUrlGetResp.Content)
	Set-Location $dest
	Set-ExecutionPolicy Unrestricted -force
	.\MMASetup-AMD64.exe /Q:A /R:N /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=$omsWorkSpaceId  OPINSIGHTS_WORKSPACE_KEY=$omsWorkSpaceKey AcceptEndUserLicenseAgreement=1"
}

<#Install Docker EE for Windows Server 2016>
Install-PackageProvider -Name NuGet -MinimumVersion $nuget4dockerVer -Force
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
#set-executionpolicy remotesigned -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force#>

<# Reboot in 60 seconds #>

C:\WINDOWS\system32\shutdown.exe -r -f -t 120
Write-Host "end script"
