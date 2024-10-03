#
#az_subscription_id="b26ca35c-986a-4601-8b6b-dc9abbcdd105"
set -x
source temp/jal4o/.deploy/shared/.env
cf_resource_group="jal4o-shared-system-rg"
cf_automation_account="jal4o-shared-0044-system-automation"
#
# create RunAz automation account
az rest --method patch \
 --url "https://management.azure.com/subscriptions/${az_subscription_id}/resourceGroups/${cf_resource_group}/providers/Microsoft.Automation/automationAccounts/${cf_automation_account}?api-version=2020-01-13-preview" \
 --body "{\"identity\": {\"type\": \"SystemAssigned\"}}"
#