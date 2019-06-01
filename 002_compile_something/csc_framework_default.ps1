# Dont forget to replace `community` with the edition of VS you have installed. 
$csc="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\csc.exe"

# The deterministic parameter stops csc adding a guid or timestamp so outputs are always identical given the same inputs.
& $csc Program.cs -deterministic