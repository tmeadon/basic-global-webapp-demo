# Global Static Site Demo

This contains the code and infrastructure definitions for a demo I put together to show a group of work experience students how globally available static websites can be rapidly built and deployed to Azure.  This was thrown together quite quickly and could therefore be buggy.  There are also clear best practices that have not been followed, such as using Key Vault for app secrets - this is suitable for a _demo only_.

Requirements to run this:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [.NET 6.0 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)
- Bicep CLI (`az bicep install`)
- [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)

To deploy:

1. Connect to your desired Azure subscription - `az login`
2. Make `deploy.sh` executable - `chmod +x deploy.sh`
3. Run `deploy.sh`

The script will deploy infrastructure and copy website and API binaries to the relevant locations.  The site will then be available via the CDN endpoint or at the storage account's static website URL.  To add students to the database, add the followng record to the `students` Cosmos DB collection:

```json
{
    "id": "1",
    "students": [
        "names",
        "of",
        "students"
    ]
}
```
