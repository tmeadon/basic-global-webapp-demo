param location string = 'uksouth'

var randomString = uniqueString(resourceGroup().id)

resource database 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: randomString
  location: 'eastus'
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard' 
    locations: [
      {
        locationName: 'eastus'
        failoverPriority: 0
      }
    ]
    enableFreeTier: true
  }
  
  resource db 'sqlDatabases' = {
    name: 'work-experience'
    properties: {
      resource: {
        id: 'work-experience'
      }
      options: {
        throughput: 400
      }
    }
    
    resource students 'containers' = {
      name: 'students'
      properties: {
        resource: {
          id: 'students'
          partitionKey: {
            paths: [
              '/id'
            ]
          }
        }
      }
    } 
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: randomString
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }

  resource blobService 'blobServices' = {
    name: 'default'
    
    resource webContainer 'containers' = {
      name: '$web'
      properties: {
        publicAccess: 'Container'
      }
    }
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: randomString
  location: 'global'
  sku: {
    name: 'Standard_Verizon'
  }

  resource endpoint 'endpoints' = {
    name: randomString
    location: 'global'
    properties: {
      originHostHeader: '${storage.name}.z33.web.${environment().suffixes.storage}'
      isHttpAllowed: true
      isHttpsAllowed: true
      queryStringCachingBehavior: 'IgnoreQueryString'
      origins: [
        {
          name: 'origin1'
          properties: {
            hostName: '${storage.name}.z33.web.${environment().suffixes.storage}'
          }
        }
      ]
    }
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: randomString
  location: location
  kind: 'linux'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: randomString
  location: location
  // kind: 'functionapp'
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET|6.0'
      cors: {
        allowedOrigins: [
          '*'
        ]
      } 
    }
  }

  resource appsettings 'config' = {
    name: 'appsettings'
    properties: {
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      CosmosConnectionString: database.listConnectionStrings().connectionStrings[0].connectionString
      CosmosDatabaseName: database::db.name
      StudentsContainerName: database::db::students.name
    }
  }
}

output apiBaseUrl string = functionApp.properties.defaultHostName
output baseName string = randomString
