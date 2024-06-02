$templateFile = 'main.bicep'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "sub-scope-$today"
$virtualNetworkName = 'rnd-vnet-001'
$virtualNetworkAddressPrefix = '10.0.0.0/24'

New-AzSubscriptionDeployment `
-Name $deploymentName `
-Location westus `
-TemplateFile $templateFile `
-virtualnetworkName $virtualNetworkName `
-virtualNetworkAddressPrefix $virtualNetworkAddressPrefix

New-AzSubscriptionDeployment @Parameters -verbose