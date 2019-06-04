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

This might feel like a lot of magic happed. It did. Also I'll explain that and why this isn't an exe.


## The 'Simple' CSC Equivalent On .NET Framework

If we run the standard full framework `csc.exe` on our `Program.cs` we get a simple .NET 4 Windows exe that just works if you run Program.exe at a console.

I'm using powershell because it makes it easier to construct the arguments and experiment with them.

[csc_framework.ps1](https://github.com/t3hmun/AspCoreFromScratch/blob/master/002_compile_something/csc_framework.ps1)

```powershell
# Don't forget to replace `community` with the edition of VS you have installed. 
$csc="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\csc.exe"

# The nostdlib argument removes the mscorlib reference, we add it back in explicitly as a demonstration.
# csc automatically looks in C:\Windows\Microsoft.NET\Framework for dlls without full path not present in the current folder.
$mscorlib="-reference:mscorlib.dll"

# The deterministic parameter stops csc adding a guid or timestamp so outputs are always identical given the same inputs.
& $csc Program.cs -deterministic -noconfig -nostdlib $mscorlib
```

The `-noconfig` argument stops csc from using the default `csc.rsp` file that contains refrences to some of the most common framework libararies.

If we skip all the arguments I added after `-deterministic` we get the same result as the defaults take care of everything.

We can run the same build using the csc provided with the core SDK and get exactly the same [deterministic](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/deterministic-compiler-option) result (I compared the hashes of each Program.exe).

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


## The Simple CSC eqivalen on Core

In order to output a Core file we must include Core references.

read nate hostpolicy