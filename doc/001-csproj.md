# Write a Simple Core csproj

2019-26-05 [ASP.NET Core 2.2, MSBuild, ASP, Core, csproj]

It would be neat if the first from scratch example was a single `.cs` file and a call to `csc.exe` the C# compiler.
I'm tempted to try this one day but the the long list parameters required for ASP.NET Core gets rather unwieldy (I guess).

So we'll start with a `.csproj` file (I'll explain the hidden magic), and that requires you to know about MSBuild...

## Primer on MSBuild

Like most Microsoft dev projects Core uses MSBuild to automate the build process.
There are many parts ot that such as the parameters passed to `csc.exe` and copying the copying of the correct dlls* and debug files to the output.

> *The _correct dlls_ is complicated because Core now uses the [Runtime Package Store](https://docs.microsoft.com/en-us/dotnet/core/deploying/runtime-store) and on top of that there is all the conficting dependant version shennigans that we'll get into later.

> Early verions of Core attemtped use `dotnet.exe` with the now depreciated `project.json` instead of MSBuild but that is history.
> The monster called MSBuild rules all. `dotnet.exe` is now a convenience wrapper on MSBuild with handy features.

MSBuild does a huge amount of magic for us making builds easy*.
There are 2 decent walthroughs by Microsoft that give you a practical rundown of MSBuild, 
[Using MSBuild](https://docs.microsoft.com/en-us/visualstudio/msbuild/walkthrough-using-msbuild?view=vs-2019) and 
[Create an MSBuild project file from scratch](https://docs.microsoft.com/en-us/visualstudio/msbuild/walkthrough-creating-an-msbuild-project-file-from-scratch?view=vs-2019).
A scan of those 2 walkthoughs should suffice to tach you the essential basics.


> *Like many people I've engaged in violent brawls with MSBuild in the past, but with a bit of perseverence you can win/survive.


## The csproj

### A very long 2 line build script

Hopefully by now you realise that a `.csproj` is a MSBuild project file.

Lets start by creating a very simple project file, `anything.csproj` in its own folder.

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
</Project>
```

Now some people might not be familiar with this kind of MsBuild file.
This is the new simplified SDK style format.

There are a [bunch](https://github.com/dotnet/project-system/issues/628) [of](https://github.com/dotnet/project-system/issues/40) [issues](https://github.com/microsoft/msbuild/issues/699) on GitHub where you can see the evolution of this change. 

Open any command line at the location of the new `.csproj` and run MSBuild.

> __Finding MSBuild__: MSBuild likes to play hide and seek.
> Since 2019 the official MSBuild is a part of Visual Studio living with it, there is no official separate MSBuild installer anymore.
> A normal location it might be found: `/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/MSBuild.exe`.
> One way to get it without Visual Studio is to get the JetBrains fork from [http://jb.gg/msbuild](http://jb.gg/msbuild), you can read about it [here](https://blog.jetbrains.com/dotnet/2018/04/13/introducing-jetbrains-redistributable-msbuild/).
> I trust JetBrains, they know what they are doing.
> You could put MsBuild in path for convenience but keep in mind that there will probably be some wierd build in the future that gets upset by this.

MSBuild it automatically finds the `.proj`, tries running it then crashes because `TargetFramework` is required.
However this is interesting because a lot happens before the error.
When I run `MSBuild.exe -preprocess:monster.txt` I end up with __little over 12 thousand lines__ of msbuild mayhem.

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

Run `MSBuild.exe`.
Now we have an error message telling us to run NuGet restore.
This is significant in that it points out that NuGet is an essential part of the build process, even though we have no packages yet.

So, do a `NuGet restore anything.csproj`

> You may need to download [Nuget.exe](https://www.nuget.org/downloads) and put it in path on your machine.
> It is a handy tool to have in path.

Now when we run MSBuild ([result](https://gist.github.com/t3hmun/f7ea75dcb37a6a5c1237efceb12d8bee)) it complains that there is no code with a main function.
In this result you can see it called the C# compiler and passed in all the netcore libraries.
This is what the `TargetFramework` does.

I highly suspect our project with no code does not need all those references.

The [Additions to the csproj format for .NET Core](https://docs.microsoft.com/en-us/dotnet/core/tools/csproj) page does even more explining as to whats changed, there is quite a lot.
The most obvious point is [that you no longger have to include `.cs` files](https://docs.microsoft.com/en-us/dotnet/core/tools/csproj#default-compilation-includes-in-net-core-projects) in the project, they are included automatically.

Finaly we can move on to writing code.
Our build script / project file is only 5 lines long, nice and simple.