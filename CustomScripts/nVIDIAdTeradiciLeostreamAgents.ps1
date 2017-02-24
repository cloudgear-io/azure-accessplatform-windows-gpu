$dest = "D:\Downloadinstallers\"
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
$registryPath = "HKLM:\Software\Teradici\PCoIP\pcoip_admin"
$Name = "pcoip.max_encode_threads"
$value = "8"
$Date = Get-Date

New-Item -Path $dest -ItemType directory

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
wget $teradiciAgentUrl -OutFile $teradiciExePath
wget $leostreamAgentUrl -OutFile $leostreamExePath
Start-Sleep -s 360

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
    wget $softUrl -OutFile $softPath
    Write-Host "Get the Sample Block for OpendTect"
    $nlblockzip = "opendTect/F3_Demo_2016_training_v6.zip"
    $nlblockUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/{2}", $storageAcc, $conName, $nlblockzip)
    $nlblockName = "F3_Demo_2016_training_v6.zip"
    Write-Host "NL F3 Block download is from '$nlblockUrl'"
    $nlblockPath = [System.String]::Format("{0}{1}", $dest, $nlblockName)
    wget $nlblockUrl -OutFile $nlblockPath
    
  }
elseif ($softwareExeName -like '*STAR*') 
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $softwareUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/{2}", $storageAcc, $conName, $softwareExeName)
    $softwareName = "STAR-View+11.04.010_win64_intel15.0.exe"
    $softwarePath = [System.String]::Format("{0}{1}", $dest, $softwareName)
    $softUrl = [System.String]::Format("{0}",$softwareUrl)
    $softPath = [System.String]::Format("{0}",$softwarePath)
    wget $softUrl -OutFile $softPath
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
    wget $nvcerUrl -OutFile D:\Downloadinstallers\nvidia.zip
    Unzip "D:\Downloadinstallers\nvidia.zip" "D:\"
    certutil -f -addstore "TrustedPublisher" D:\nvidia.cer
    $nvidiaUrl = [System.String]::Format("{0}",$nvidiaazureURL)
    Write-Host "The NVIDIA Driver exe Url  is '$nvidiaUrl'"
    wget $nvidiaUrl -OutFile D:\Downloadinstallers\NVAzureDriver.zip
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
  wget $nvidiaUrl -OutFile $nvidiaExePath
  & $nvidiaExePath  /s
  Start-Sleep -s 60
  $NVIDIAfolder = [System.String]::Format("C:\NVIDIA\{0}", $nvidiaVer)
}

Write-Host "The NVIDIA Folder name is '$NVIDIAfolder'"
Set-Location $NVIDIAfolder
Set-ExecutionPolicy Unrestricted -force
.\setup.exe -s -noreboot -clean
Start-Sleep -s 180
& $teradiciExePath /S /NoPostReboot
Start-Sleep -s 90 
Write-Host "teradiciagent install over"
cd 'C:\Program Files (x86)\Teradici\PCoIP Agent\licenses\'
Write-Host "pre-activate"
.\appactutil.exe -served -comm soap -commServer https://teradici.flexnetoperations.com/control/trdi/ActivationService -entitlementID $license
Write-Host "activation over"

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
  Write-Host  "No Registry entry required ."
}

net stop nvsvc
Write-Host "Stopped NVIDIA Display Driver"
Start-Sleep -s 240
net start nvsvc
Write-Host "Starting NVIDIA Display Driver"
<#OMS Hook#>
if ($omsWorkSpaceId -and $omsWorkSpaceKey) {
  $omsAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/MMASetup-AMD64.exe", $storageAcc, $conName)
  $omsExeName = [System.IO.Path]::GetFileName($omsAgentUrl)
  $omsExePath = [System.String]::Format("{0}{1}", $dest, $omsExeName)
  wget $omsAgentUrl -OutFile $omsExePath
  Set-Location $dest
  Set-ExecutionPolicy Unrestricted -force
  .\MMASetup-AMD64.exe /Q:A /R:N /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=$omsWorkSpaceId  OPINSIGHTS_WORKSPACE_KEY=$omsWorkSpaceKey AcceptEndUserLicenseAgreement=1"
}

<# Reboot in 60 seconds #>

C:\WINDOWS\system32\shutdown.exe -r -f -t 60
Write-Host "end script"
