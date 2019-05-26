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


Hopefullyby now you realise that a `.csproj` is a MSBuild project file.
The `.csproj` should be a full set of instuctions on how to build the project,
however there are a large amount of magical assumtions baked into MSBuild, I'll point htem out as we go along.

`test.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
</Project>
```

Now `MSBuild test.csproj` and see an actually helpful error - you need a `TargetFramework`.

> MSBuild likes to play hide and seek.
> Since 2019 the official MSBuild is a part of Visual Studio living with it, there is no official separate MSBuild installer anymore.
> A normal location it might be found: `/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/MSBuild.exe`.
> One way to get it without Visual Studio is to get the JetBrains fork from [http://jb.gg/msbuild](http://jb.gg/msbuild), you can read about it [here](https://blog.jetbrains.com/dotnet/2018/04/13/introducing-jetbrains-redistributable-msbuild/).
> I trust JetBrains, they know what they are doing.
> You could put MsBuild in path for convenience but keep in mind that there will probably be some wierd build in the future that gets upset by this.

