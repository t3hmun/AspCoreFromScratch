# ASP


## The Default Empty Program

Lets actually make a web something.

```bash
dotnet new
```

This gives up many options.
Lets go for the empty asp project.

```
dotnet new web
dotnet run
```

Open your browser to `localhost:5000` or whatever it says in the console and see the hello world message.
You successfully made a server.


## dotnet run

Lets break [dotnet run](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-run?tabs=netcore21) down.

Firstly it runs a package restore.
That can be done manually using `dotnet restore`, which is the equivalent of `dotnet msbuild -target:restore`.
This creates a long json file that allows the build to find all the dependencies included via `<PackageReference>` nodes in the csproj.
This is the same as `nuget restore`, NuGet is fully built into msbuild so no need for the separate tool.

Secondly it does the build, equivalent to `dotnet msbuild -target:build`.
The process involves calling the compiler (csc) and then copying the `dll`, `pdb`, `deps.json` and `runtimeconfig.json` files to the output.

Finally it runs the compiled Core application, you can do this by calling `dotnet exec` on it or just `dotnet`. 
By default `dotnet run` uses the configuration with the project name in `properties/launchSettings.json`, 
which sets the `ASPNETCORE_ENVIRONMENT` to `Development`.
We'll look at where this configuration is read later.

> `dotnet exec` is an undocumented internal thing so you probably should only use `dotnet` by itself to run programs.


## Cut Down to Minimal

While the empty ASP Core project doesn't do much it isn't a minimal example.
It isn't the simple 5 line csproj that ended the [csproj article](./1_csproj.md).

The following files can be deleted, we'll add them back when we find the useful:

```
Properties/launchSettings.json
appsettings.Development.json
appsettings.json
```

Also in the csproj the reference to `Razor.Design` can be removed and `<AspCoreHostingModel>` node can be deleted.

> `<AspCoreHostingModel>` is a ASP Core `2.2` feature.

Removing the `AspCoreHostingModel` node causes it to default to `OutOfProcess`.
The `InProcess` options causes it to use IIS instead of Kestrel as a host.
If we want the option of running on Linux, full IIS in process hosting is not a choice.

Finally lets make sure that the `netcoreapp` version is `2.1` and not something newer.
[Version 2.1 is in LTS](https://dotnet.microsoft.com/platform/support/policy/dotnet-core).
If you use `2.2` you will be forced to upgrade the application to `3` at the end of 2019 because Microsoft will stop security patches.

We can still `dotnet run` the application and everything runs fine.

## Should We Delete the .cs Files and Start from Scratch

It is possible to delete those basic files and write the program up line by line.
However there are many conventions and assumptions that are strongly encouraged in the ASP world.
Although technically optional most tutorials and help assume these defaults as an essential part of ASP Core. 
In my opinions it is better to start from that position and tear things back to see how they were formed.

## The Default Program.cs and Startup.cs

These 2 default code files may look simple but there is a lot going on.
`WebHostBuilder` is the main orchestrator, everything is done through it.
It is used to gather configuration, configure and initialise the server passing on the configuration for the application pipeline.

The configuration of the application pipeline is all contained within the `Startup` class, which is fully executed when the `WebHost` is started.

We'll go as far as looking inside the source of `WebHostBuilder` and `WebHost` but we certainly wont doing anything without them.
`WebHost` is the front ASP abstractions that make it possible to swap Kestrel for IIS or any other method of serving.

> There is a further abstraction called `GenericHost` [but it isn't relevant yet](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/host/generic-host?view=aspnetcore-2.1):
> _Generic Host will replace Web Host in a future release and act as the primary host API in both HTTP and non-HTTP scenarios._

## Program.cs

The default program.cs looks simple but `CreateDefaultBuilder` [does quite a lot](https://github.com/aspnet/AspNetCore/blob/release/2.1/src/DefaultBuilder/src/WebHost.cs), thigs that are all worth being explicitly aware of.
Give it a read, understand that all the basic loading of settings and server set-up is done there.
Its function is actually [neatly documented](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/host/web-host?view=aspnetcore-2.1).

Now we'll delete that and configure it ourselves.

```csharp
public static IWebHostBuilder CreateWebHostBuilder(string[] args)
{
    var builder = new WebHostBuilder();
    builder.UseKestrel();
    builder.UseStartup<Startup>();
    return builder;
}
```
