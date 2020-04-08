<#
.SYNOPSIS
    Suspend or Resume an Azure Analysis Services server according to a schedule using Azure Automation.

.DESCRIPTION
    This Azure Automation runbook enables you to suspend or Resume your Analysis Server.
    The runbook is based on the new AZ powershell cmdlets
	
.PARAMETER resourceGroup
    Name of the resource group to which the server is assigned.

.PARAMETER azureRunAsConnectionName
    Azure Automation Run As account name. 

.PARAMETER AzureAnalysisServer
    Azure Analysis Services server name.

.PARAMETER State
   The desired state Suspend or Resume


.NOTES
    Author: Erwin de Kreuk
    Last Update: March 2020
#>    

param(
         # Name of Azure Analysis Server
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $AzureAnalysisServer,

        # Name of ResourceGroup
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroup ,

        # State  Suspend or Resume
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $State = "<Suspend_Resume>" ,

        # Credentials for $SqlServerName stored as an Azure Automation credential asset
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string] $azureRunAsConnectionName = "AzureRunAsConnection"
    )

#set timestamp
filter timestamp {"[$(Get-Date -Format G)]: $_"}
 
Write-Output "Script started." | timestamp
 
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#Authenticate with Azure Automation Run As account (service principal)

$runAsConnectionProfile = Get-AutomationConnection -Name $azureRunAsConnectionName
Add-AzAccount -ServicePrincipal `
-TenantId $runAsConnectionProfile.TenantId `
-ApplicationId $runAsConnectionProfile.ApplicationId `
-CertificateThumbprint ` $runAsConnectionProfile.CertificateThumbprint | Out-Null
Write-Output "Authenticated with Automation Run As Account." | timestamp

# Get the server object
$asSrv = Get-AzAnalysisServicesServer -ResourceGroupName $resourceGroup -Name $AzureAnalysisServer
Write-Output "AAS server name: $($asSrv.Name)" | timestamp
Write-Output "Current AzureAnalysisServer status: $($asSrv.State), sku: $($asSrv.Sku.Name)" | timestamp
 
Write-Output "AzureAnalysisServer set to status: $State" | timestamp


 if ($State -eq "Resume")
{
        Write-Output "Check if AzureAnalysisServer is paused .." | timestamp
        if($asSrv.State -eq "Paused")
        {
            Write-Output "AzureAnalysisServer was paused. Resuming!" | timestamp
            $asSrv | Resume-AzAnalysisServicesServer 
            Write-Output "AzureAnalysisServer resumed." | timestamp
             $asSrv = Get-AzAnalysisServicesServer -ResourceGroupName $resourceGroup -Name $AzureAnalysisServer
            Write-Output "Current AzureAnalysisServer sate: $($asSrv.State), sku: $($asSrv.Sku.Name)" | timestamp
        }
        else
        {
            Write-Output "AzureAnalysisServer already resumed. Exiting..." | timestamp
        }
}
if ($State -eq "Suspend") 
{       
        if($asSrv.State -ne "Paused")
        {
            Write-Output "AzureAnalysisServer not paused. Pausing!" | timestamp
            $asSrv | Suspend-AzAnalysisServicesServer 
            Write-Output "Server paused." | timestamp
            $asSrv = Get-AzAnalysisServicesServer -ResourceGroupName $resourceGroup -Name $AzureAnalysisServer
            Write-Output "Current AzureAnalysisServer sate: $($asSrv.State), sku: $($asSrv.Sku.Name)" | timestamp
        }
        else
        {
            Write-Output "AzureAnalysisServer paused already. Exiting..." | timestamp
        }
}

If ($State -ne "Resume"  -And $State -ne "Suspend")
        {
            Write-Output "No valid input inputstate:  $State. Exiting..." | timestamp
        }

Write-Output "Script finished." | timestamp