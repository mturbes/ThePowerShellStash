function Enable-RDP
{
  Param
  ( 
    [string[]]$computerName 
  )
  
  $sb = {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
  }
  
  if ( $computerName ) 
  {
    foreach ($Computer in $Computername)
    {
      Invoke-Command -ScriptBlock $sb -ComputerName $Computer
    }
  }
  else
  {
    Invoke-Command -ScriptBlock $sb
  }
}