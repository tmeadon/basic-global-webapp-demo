using Microsoft.Azure.Cosmos;


namespace API;

public class CosmosService
{
    private Container container;

    public CosmosService(IConfiguration config)
    {
        container = GetStudentsContainer();
    }

    private Container GetStudentsContainer()
    {
        var cosmosClient = new CosmosClient(Environment.GetEnvironmentVariable("CosmosConnectionString"));
        var database = cosmosClient.GetDatabase(Environment.GetEnvironmentVariable("CosmosDatabaseName"));
        return database.GetContainer(Environment.GetEnvironmentVariable("StudentsContainerName"));
    }

    public async Task<List<string>> GetStudentsAsync()
    {
        var response = await container.ReadItemAsync<StudentDoc>("1", new PartitionKey("1"));
        return response.Resource.students;
    }   
}

public class StudentDoc
{
    public string id { get; set; }
    public List<string> students { get; set; }
}