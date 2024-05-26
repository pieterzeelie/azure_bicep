$templateFile = 'main.bicep'
$templateParameterFile = 'azuredeploy.parameters.json'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "deploymentscript-$today"

New-AzResourceGroupDeployment 
-ResourceGroupName $resourceGroupName 
-Name $deploymentName 
-TemplateFile $templateFile 
-TemplateParameterFile $templateParameterFile