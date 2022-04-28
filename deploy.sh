#!/bin/bash

# build apps
dotnet publish app/web -c Release
dotnet publish app/api -c Release

# zip up function app build
root=$(pwd)
cd app/api/bin/Release/net6.0/publish
zip -r $root/api.zip ./*
cd $root

# create resource group
group=$(az group create -n "work-experience-demo1" -l "uksouth" --query "name" -o tsv)

# deploy iac and capture baseName output
baseName=$(az deployment group create -g $group -f ./infra/main.bicep --query properties.outputs.baseName.value -o tsv)

# deploy api code
az functionapp deployment source config-zip -g $group -n $baseName --src ./api.zip

# deploy web app
az storage blob service-properties update --account-name $baseName --static-website  --index-document index.html
sasEnd=$(date -u -d "+1 hour" '+%Y-%m-%dT%H:%MZ')
sas=$(az storage container generate-sas --account-name $baseName -n '$web' --permissions dlrwc --expiry $sasEnd --output tsv)
azcopy sync './app/web/bin/Release/net6.0/publish/wwwroot' "https://$baseName.blob.core.windows.net/\$web?$sas" --recursive=true