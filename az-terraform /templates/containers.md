

Notes

2021-08-09


reference resource-group module or service properties ?? ...

acr.param.json
lib\tf\az\templates\container-registry.param.json
    "rg_name": "module.resource-group.resource_group_name"
    "rg_location": "module.resource-group.resource_group_location"
            "rg_name": "module.containers_aks.resource_group_name",
            "rg_location": "module.containers_aks.resource_group_location",

    "rg_name": "[profile.service.property.resourceGroup]",
    "rg_location": "[profile.service.property.location]",

    ?  "acr_name": "[profile.service.property.acrName]",




https://www.terraform.io/docs/language/settings/backends/azurerm.html

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet


