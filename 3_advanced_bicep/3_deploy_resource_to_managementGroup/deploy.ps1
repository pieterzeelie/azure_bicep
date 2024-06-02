$managementGroupId = 'SecretRND'
$templateFile = 'main.bicep'
$today = Get-Date -Format 'MM-dd-yyyy'
$deploymentName = "mg-scope-$today"

New-AzManagementGroupDeployment `
-ManagementGroupId $managementGroupId `
-Name $deploymentName `
-Location westus `
-TemplateFile $templateFile