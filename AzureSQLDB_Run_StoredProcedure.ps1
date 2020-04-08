    param(
         # Fully-qualified name of the Azure DB server
        [parameter(Mandatory=$true)]
       
        [string] $AzureSQLServerName = "<DBSERVER>",

        # Name of database
        [parameter(Mandatory=$true)]
       
        [string] $AzureSQLDatabaseName = "<DBNAME>",
        
        # Name of Procedure  "exec dbo.xxxxxxxx"
        [parameter(Mandatory=$true)]
       
        [string] $ProcedureName = "exec  <name>",


        # Credentials for $SqlServerLogin stored as an Azure Automation credential asset
        [parameter(Mandatory=$true)]
      
         [string] $SqlCredential 
    )
$Credential = Get-AutomationPSCredential -Name $SqlCredential
$AzureSQLServerName = $AzureSQLServerName + ".database.windows.net" 

$SQLOutput = $(Invoke-Sqlcmd -ServerInstance $AzureSQLServerName -Username $Credential.UserName -Password $Credential.GetNetworkCredential().Password -Database $AzureSQLDatabaseName -Query $ProcedureName -QueryTimeout 65535 -ConnectionTimeout 60 -Verbose) 4>&1 

Write-Output $SQLOutput​