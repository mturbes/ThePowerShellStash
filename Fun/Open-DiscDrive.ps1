function Open-CDdrive
{
  param
  (
    [String]
    $Computername
  )
  
  $OpenCDdrive = {
    $sh = New-Object -ComObject "Shell.Application"
    $sh.Namespace(17).Items() | 
    Where-Object { $_.Type -eq "CD Drive" } | 
    ForEach-Object -Process { $_.InvokeVerb("Eject") }
  }
  
  if($Computername)
  {
    Invoke-Command -ScriptBlock $OpenCDdrive -ComputerName $Computername
  }
  else
  {
    Invoke-Command -ScriptBlock $OpenCDdrive
  }
}