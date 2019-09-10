function Force-LogOffAllUsers
{
  param
  (
    [String[]]
    [Parameter(Mandatory)]
    $ComputerName
  )
  
  Invoke-Command -ScriptBlock {(gwmi win32_operatingsystem).Win32Shutdown(4)} -ComputerName $computername
  
}