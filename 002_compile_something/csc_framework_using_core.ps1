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