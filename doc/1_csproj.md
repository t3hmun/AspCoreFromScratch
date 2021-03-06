# Write a Simple Core csproj

2019-26-05 [ASP.NET Core 2.2, MSBuild, ASP, Core, csproj]

It would be neat if the first from scratch example was a single `.cs` file and a call to `csc.exe` the C# compiler.
I'm tempted to try this one day but the the long list parameters required for ASP.NET Core gets rather unwieldy (I guess).

So we'll start with a `.csproj` file (I'll explain the hidden magic), and that requires you to know about MSBuild...

## Primer on MSBuild

Like most Microsoft dev projects Core uses MSBuild to automate the build process.
There are many parts ot that such as the parameters passed to `csc.exe` and copying the copying of the correct dlls* and debug files to the output.

> *The _correct dlls_ is complicated because Core now uses the [Runtime Package Store](https://docs.microsoft.com/en-us/dotnet/core/deploying/runtime-store) and on top of that there is all the conflicting dependant version shenanigans that we'll get into later.

> Early versions of Core attempted use `dotnet.exe` with the now depreciated `project.json` instead of MSBuild but that is history.
> The monster called MSBuild rules all. The build functionality of `dotnet.exe` is now a convenience wrapper on MSBuild with handy features.

MSBuild does a huge amount of magic for us making builds easy*.
There are 2 decent walkthroughs by Microsoft that give you a practical run-down of MSBuild, 
[Using MSBuild](https://docs.microsoft.com/en-us/visualstudio/msbuild/walkthrough-using-msbuild?view=vs-2019) and 
[Create an MSBuild project file from scratch](https://docs.microsoft.com/en-us/visualstudio/msbuild/walkthrough-creating-an-msbuild-project-file-from-scratch?view=vs-2019).
A scan of those 2 walkthoughs should suffice to teach you the essential basics.

> *Like many people I've engaged in violent brawls with MSBuild in the past, but with a bit of perseverence you can come to an understanding.


### Getting MSBuild

The easiest thing is to use the MSBuild that comes with the [Core SDK](https://dotnet.microsoft.com/download).
The Core SDK installs the `dotnet` tool into path, which gives you access to MSBuild by typing `dotnet msbuild`.
The versions of MSBuild and Roslyn installed in the SDK (`C:\Program Files\dotnet\sdk`) are not normal Windows exes,
they are magical Core portable binaries so need the `dotnet` tool to run them.
We'll talk about the magic later.

It is handly to have the normal exe versions of MSBuild and Roslyn for comparing core to how things work on the full framework.
Microsoft have stopped distributing the normal `MSBuild.exe` and Roslyn `csc.exe` separately from Visual Studio.
The normal locations are now `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe`
and `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn`.

If you want the exe versions without installing Visual Studio the can download it from JetBrains [http://jb.gg/msbuild](http://jb.gg/msbuild), you can read about it [here](https://blog.jetbrains.com/dotnet/2018/04/13/introducing-jetbrains-redistributable-msbuild/).


## The csproj


### A Very Long 2 Line Build Script


Hopefully by now you realise that a `.csproj` is a MSBuild project file, a build script.

Lets start by creating a very simple project file, `anything.csproj` in its own folder.

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
</Project>
```

Now some people might not be familiar with this kind of MsBuild file.
This is the new simplified SDK style format.

There are a [bunch](https://github.com/dotnet/project-system/issues/628) [of](https://github.com/dotnet/project-system/issues/40) [issues](https://github.com/microsoft/msbuild/issues/699) on GitHub where you can see the evolution of this change. 

Open any command line at the location of the new `.csproj` and run `dotnet msbuild`.

MSBuild it automatically finds the `.proj`, tries running it then crashes because `TargetFramework` is required.
However this is interesting because a lot happens before the error.
When I run `dotnet msbuild -preprocess:monster.txt` I end up with __little over 12 thousand lines__ of msbuild mayhem.

> The [-preprocess arg](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019#preprocess) aggregates all the imported files into one giant project file for us.
> This can be useful for tracking down rogue properties and arguments used deep in build.

The SDK element creates the equivalent of:

```xml
<Project>
    <Import Project="Sdk.props" Sdk="Microsoft.NET.Sdk" />

<!-- The contents of your original project file would be here -->

    <Import Project="Sdk.targets" Sdk="Microsoft.NET.Sdk" />
</Project>
```

The sdk files are automatically resolved, see [How to: Use MSBuild project SDKs](https://docs.microsoft.com/en-us/visualstudio/msbuild/how-to-use-project-sdk?view=vs-2019) for further info.

You can try reading the `sdk.props` and `sdk.targets` but it is not easy to follow the trail of referenced files.
It makes more sense to have a peek at the monster.txt output. 

Before you close monster.txt in horror, note that the `DefaultTargets` has been set as `build`.
I have not discovered what set our default target for us, but its good to know.


### A Complete 5 Line Build Script


Now let's try making the csproj more complete:

```
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>netcoreapp2.1</TargetFramework>
  </PropertyGroup>
</Project>
```

> We are using `netcoreapp2.1` not `2.2` for a good reason. 
> 2.1 is LTS, 3 years of updates, 2.2 is only guaranted to have 3 months security updates after the release of Core 3. 
> The next version is a major version so upgading may require serious effort. 
> There is no point in dooming a current project to insecurity unless you absolutely require a new feature.

Run `dotnet msbuild`.
Now we have an error message telling us to run NuGet restore.
This is significant in that it points out that NuGet is an essential part of the build process, even though we have no packages yet.

So, do a `dotnet restore`

> `dotnet restore` runs the `restore` msbuild target.
> Since 2017 NuGet has been integrated into MSBuild making the [pack and restore targets](https://docs.microsoft.com/en-us/nuget/reference/msbuild-targets) always available. 
> You can still run [nuget.exe](https://www.nuget.org/downloads) manually, specifying the project as an argument, same result.

It might not look like nuget has anything to restore but it actually produces a long list of framework packages in a json file:

The [Nuget Restore](https://docs.microsoft.com/en-us/nuget/tools/cli-ref-restore) docs say: "_When used with NuGet 4.0+ and the PackageReference format, generates a `<project>.nuget.props` file, if needed, in the obj folder. (The file can be omitted from source control.)_"
The PackageReference format consists of `<PackageReference>` elements, which you'll find aplenty in monster.txt, the core framework libs specifically.

Now when we run MSBuild ([result](https://gist.github.com/t3hmun/f7ea75dcb37a6a5c1237efceb12d8bee)) it complains that there is no code with a main function.
In this result you can see it called the C# compiler and passed in all the netcore libraries.


The [Additions to the csproj format for .NET Core](https://docs.microsoft.com/en-us/dotnet/core/tools/csproj) page explains more of the things the new style projects magically do.
The most obvious point is [that you no longer have to include `.cs` files](https://docs.microsoft.com/en-us/dotnet/core/tools/csproj#default-compilation-includes-in-net-core-projects) in the project, they are included automatically (by included we mean passed onto the compiler to be built).

Finaly we can move on to writing code.
Our build script / project file is only 5 lines long, nice and simple.