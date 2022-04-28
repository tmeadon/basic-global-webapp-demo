global using Microsoft.Extensions.Configuration;
global using System;
global using System.Collections.Generic;
global using System.Threading.Tasks;
using System.IO;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(API.Startup))]

namespace API;

public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        builder.Services.AddSingleton<CosmosService>();
    }
}