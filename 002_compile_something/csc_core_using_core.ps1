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