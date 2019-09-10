function Get-LastLoggedOnUser
{
  Param
  ( 
    [string[]]$computerName 
  )
  
  $sb = {
    $LastLoggedIn = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\MICROSOFT\WINDOWS\CurrentVersion\Authentication\LogonUI').LastLoggedOnDisplayName
    [pscustomobject]@{
      Hostname = $env:COMPUTERNAME
      LastLoggedIn = $LastLoggedIn
    }
  }

  if($computerName)
  {
    foreach ($Computer in $Computername)
    {
      Invoke-Command -ComputerName $Computer -ScriptBlock $sb
    }
  }
  else
  {
    Invoke-Command -ScriptBlock $sb
  }
}