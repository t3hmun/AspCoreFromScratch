# Compile Somthing

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


## The 'Simple' CSC Eqiuvalent

If we run the stan