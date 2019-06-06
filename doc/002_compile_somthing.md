# Compile Something

> You must have the [Core SDK](https://dotnet.microsoft.com/download) installed, giving you access to the `dotnet` tool.

## Instant Demo

Create a simple program:

```csharp
// Program.cs
namespace learn
{
    class Program
    {
        public static int Main(string[] args)
        {
            System.Console.WriteLine("Salutations");
            return 0;
        }
    }
}
```

Compile it with `dotnet build` and then run it using `dotnet Program.dll`.
It should happily output the greeting.

> From the [docs](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-msbuild)
> "The dotnet build command is equivalent to `dotnet msbuild -restore -target:Build`"
> For convenience we can use this from now on.

This might feel like a lot of magic happened. It did. Also I'll explain that and why this isn't an exe.


## Simple 'CSC' Compilation and Running on the .Net Full Framework

Compiling and running a simple program was a simple process on the full .NET framework
Running the standard full framework `csc.exe` on our `Program.cs` produces a simple .NET 4 Windows exe that just works if you run Program.exe at a console.

> I'm using powershell to make it easier to construct the arguments and experiment with different combinations.
> You can enter the commands directly if you prefer.

[csc_framework.ps1](https://github.com/t3hmun/AspCoreFromScratch/blob/master/002_compile_something/csc_framework.ps1)

```powershell
# Don't forget to replace `community` with the edition of VS you have installed. 
$csc="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\csc.exe"

# The nostdlib argument removes the mscorlib reference, we add it back in explicitly as a demonstration.
# csc automatically looks in C:\Windows\Microsoft.NET\Framework for references without full path not present in the current folder.
$mscorlib="-reference:mscorlib.dll"

# The deterministic parameter stops csc adding a guid or timestamp so outputs are always identical given the same inputs.
& $csc Program.cs -deterministic -noconfig -nostdlib $mscorlib
```

The `-noconfig` argument stops csc from using the default `csc.rsp` file that contains references to some of the most common framework libraries.

The same result is produced if `Program.cs -deterministic` are the only arguments because the defaults (csc.rsp and mscorlib) take care of everything.

Running the same build using the csc provided with the core SDK produces exactly the same [deterministic](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/deterministic-compiler-option) result (I compared the hashes of each Program.exe).

[csc_using_core.ps1](https://github.com/t3hmun/AspCoreFromScratch/blob/master/002_compile_something/csc_framework_using_core.ps1)

```powershell
# You can compile a framework exe using the csc that comes with the Core SDK.
# It produces identical output, only difference is it requires the full path of mscorlib.

# The Core SDK version of csc is a portable dll.
$csccore="C:\Program Files\dotnet\sdk\2.2.300\Roslyn\bincore\csc.dll"
# It must be run using the dotnet tool.
$dotnet="dotnet"
# It wont automagically find mscorlib, you must specify the full path. 
$mscorlibFullPath="-reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.dll"

# The deterministic parameter stops csc adding a guid or timestamp so outputs are always identical given the same inputs.
& $dotnet $csccore Program.cs -deterministic -noconfig -nostdlib $mscorlibFullPath
```

However you came here to learn about Core not .Net Full Framework...


## The Simple CSC eqivalen on Core

### Program.cs only

In order to output a Core file we must include references to Core dlls instead of full framework dlls.

[csc_core_using_core.ps1](https://github.com/t3hmun/AspCoreFromScratch/blob/master/002_compile_something/csc_core_using_core.ps1)

```powershell
# The Core SDK version of csc is a portable dll.
$csccore="C:\Program Files\dotnet\sdk\2.2.300\Roslyn\bincore\csc.dll"

# All Core DLLs can be retrieved from NuGet.
# The SDK install keeps the fallback folder handy so it doesn't have to restore the packagers from the internet.

# mscorlib isn't complete in core, its just a bunch of redirects to other libs.
$mscorlib="-reference:C:\Program Files\dotnet\sdk\NuGetFallbackFolder\microsoft.netcore.app\2.1.0\ref\netcoreapp2.1\mscorlib.dll"
# Runtime contains the fundamental primitive types such as System.Object and System.Int16
$runtime="-reference:C:\Program Files\dotnet\sdk\NuGetFallbackFolder\microsoft.netcore.app\2.1.0\ref\netcoreapp2.1\System.Runtime.dll"
$console="-reference:C:\Program Files\dotnet\sdk\NuGetFallbackFolder\microsoft.netcore.app\2.1.0\ref\netcoreapp2.1\System.Console.dll"

& dotnet $csccore Program.cs -noconfig -nostdlib $mscorlib $runtime $console
```

This time the `Program.exe` produced doesn't just work if you try to run it directly.
This is because the compiled output is a .NET Core Portable application, not a valid windows exe.
For this reason the default convention in the MSBuild script is to always output as `.dll` and not `.exe`, slightly less misleading.

The `dotnet` tool is used to run .NET Core portable applications. 
However if we try that now `dotnet Program.cs` it fails, complaining it can't find `hostpolicy.dll`.
Copy the entire contents of `C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.2.5` next to `Program.exe` and `dotnet Program.exe` should run successfully.
I'm going to draw the line here and say I don't understand what all of these files are doing.
What we do know is that these are the core files used to start-up and run Core applications, so they are always required.

## runtimeconfig.json

[Program.runtimeconfig.json](https://github.com/t3hmun/AspCoreFromScratch/blob/master/002_compile_something/Program.runtimeconfig.json)

```json
{
  "runtimeOptions": {
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "2.1.0"
    }
  }
}
```

Core uses this config to automatically use the appropriate framework from `C:\Program Files\dotnet\shared`, 
which means we don't have to copy all those files to run the program.

