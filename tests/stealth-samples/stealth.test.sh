#set -x
# pushd cfc; tsc ; popd
export cfc_cmd="cfc/bin/cfc"  # "cfc"
deploy_org_name="si1"
deply_org_system_hash="0044"
tempCloud="azure"
tempSubscriptionName="CF-Test"
tempSampleName="stealth"
#
script_folder=$(dirname $0)
deploy_folder="temp/${deploy_org_name}/"
export deploy_org="${deploy_folder}${deploy_org_name}.org.yaml"
deploy_org_artifacts_staging="${deploy_folder}.deploy/.artifacts/artifacts/${deploy_org_name}stuff00441001/artifacts/scripts"
export deploy_ps1="${deploy_folder}${deploy_org_name}.org.ps1"
# append explicit .yaml to deploy_org for successful file exists check
deploy_custom_org="${deploy_folder}.status/custom.org.yaml"
set -x
$cfc_cmd info
if [ ! -f "$deploy_org" ]; then
  # extract sample
  $cfc_cmd init "${deploy_org}" --cloud "${tempCloud}" --sample "${tempSampleName}" --subscription "${tempSubscriptionName}"
  # apply organization/environment customizations prior to compile/deploy
  $cfc_cmd update "${deploy_org}" --organization "$script_folder/${tempSampleName}.org.yaml" --environment "$script_folder/${tempSampleName}.env.yaml"
fi
if [ ! -f "$deploy_ps1" ]; then
  # prototype of PowerShell script to create managed identity automation RunAsAccount
  tempSubscriptionId=`az account show --subscription "${tempSubscriptionName}" --query '[id]' --output tsv`
  echo "#" > "${deploy_ps1}"
  echo "# https://docs.microsoft.com/en-us/azure/automation/create-run-as-account#create-account-using-powershell" >> "${deploy_ps1}"
  echo "# From Runas Administor PowerShell command prompt"  >> "${deploy_ps1}"
  echo "wget https://raw.githubusercontent.com/azureautomation/runbooks/master/Utility/AzRunAs/Create-RunAsAccount.ps1 -outfile Create-RunAsAccount.ps1"  >> "${deploy_ps1}"
  echo "\$subscriptionName=\"${tempSubscriptionName}\"" >> "${deploy_ps1}"
  echo "\$subscriptionId=\"${tempSubscriptionId}\"" >> "${deploy_ps1}"
  echo "\$resourceGroupName=\"${deploy_org_name}-shared-system-rg\"" >> "${deploy_ps1}"
  echo "\$automationAccountName=\"${deploy_org_name}-shared-${deply_org_system_hash}-system-automation\"" >> "${deploy_ps1}"
  echo "\$automationApplicationName=\"${deploy_org_name}-shared-${deply_org_system_hash}-system-automation\"" >> "${deploy_ps1}"
  echo "\$runPassword=\"Demo1234\"" >> "${deploy_ps1}"
  echo ".\Create-RunAsAccount.ps1 -ResourceGroup \$resourceGroupName -AutomationAccountName \$automationAccountName -SubscriptionId \$subscriptionId -ApplicationDisplayName \$automationApplicationName -SelfSignedCertPlainPassword \$runPassword -CreateClassicRunAsAccount \$false" >> "${deploy_ps1}"
  # partial 'az rest' replacement
  cp tests/stealth-samples/stealth.auto.sh ${deploy_folder}
fi
if [ "$1" == "prepare" ] ; then
  exit 1  # exit early for parameter file review prior to compile/deploy
fi
# compile and deploy parameters
$cfc_cmd compile "${deploy_org}" --logLevel 2
if [ "$1" == "compile" ] ; then
  exit 1  # exit early for parameter file review prior to deploy
fi
#
cp "${deploy_folder}.built/stealth.profile.yaml" "${deploy_org_artifacts_staging}"
deploy_cmd=`$cfc_cmd deploy "${deploy_org}" --path 1`
set +x
$deploy_cmd
if [ -f "${deploy_custom_org}" ]; then
  set -x
  # merge generated SAS token into deploy_org file
  $cfc_cmd update "${deploy_org}" --organization "${deploy_custom_org}"
  mv "${deploy_custom_org}" "${deploy_custom_org}.bak"
  # recompile and redeploy
  $cfc_cmd compile "${deploy_org}"
  # copy a generated file to the artifacts staging folders for download by custom manifests
  cp "${deploy_folder}.built/stealth.profile.yaml" "${deploy_org_artifacts_staging}"
  set +x
  $deploy_cmd
fi
#

