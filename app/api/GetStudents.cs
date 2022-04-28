using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace API.Functions
{
    public class GetStudents
    {
        private readonly CosmosService cosmosService;

        public GetStudents(CosmosService cosmosService)
        {
            this.cosmosService = cosmosService;
        }

        [FunctionName("GetStudents")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            try
            {
                log.LogInformation("Getting students from database");
                var students = await cosmosService.GetStudentsAsync();
                return new OkObjectResult(students);
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Error getting students from database");
                return new StatusCodeResult(500);
            }
        }
    }
}
