[CmdletBinding()]
param (
    [Parameter( HelpMessage="Enter the Azure Cloud to connect to. Default is AzureCloud.")]
    [ValidateSet("AzureCloud", "AzureUSGovernment", "AzureGermanCloud", "AzureChinaCloud")]
    [string]
    $AzureEnvironment='AzureCloud',
    [Parameter( HelpMessage="Enter the parameters file name or path. For example '.\main.parameters.json'")]
    [string]
    $TemplateParameterFile='.\main.parameters.json'
)

# Determine if already connected to Azure
try {
  $connected = Get-AzSubscription
}
catch {
  Write-Host "Not connected to Azure and you will prompt you to connect to Azure" -ForegroundColor Green
  $result = Connect-AzAccount -Environment $AzureEnvironment
}
Write-Host ""
Write-Host "List of available subscriptions:" -ForegroundColor Green
(Get-AzSubscription).name
Write-Host ""
$subscriptionName = Read-Host -Prompt "Enter Subscription Name"
$result = Select-AzSubscription -SubscriptionName $subscriptionName
Write-Host ""
Write-Host "List of available Resource Groups:" -ForegroundColor Green
(Get-AzResourceGroup).ResourceGroupName
Write-Host ""
$resourceGroup = Read-Host -Prompt "Enter the Resource Group Name (where ARM template will be deployed into)"
$bicepFile = '.\main.bicep'
$mainParametersFiles = $TemplateParameterFile
New-AzResourceGroupDeployment `
  -Name vWAN `
  -ResourceGroupName $resourceGroup `
  -TemplateFile $bicepFile `
  -TemplateParameterFile $mainParametersFiles