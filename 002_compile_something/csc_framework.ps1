# Dont forget to replace `community` with the edition of VS you have installed. 
$csc="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\csc.exe"

# The nostdlib argument removes the mscorlib reference, we add it back in explicitly as a demonstration.
# csc automatically looks in C:\Windows\Microsoft.NET\Framework for dlls without full path not present in the current folder.
$mscorlib="-reference:mscorlib.dll"

# The deterministic parameter stops csc adding a guid or timestamp so outputs are always identical given the same inputs.
& $csc Program.cs -deterministic -noconfig -nostdlib $mscorlib