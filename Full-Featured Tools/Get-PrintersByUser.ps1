function Get-PrintersByUser
{
  Param
  ( 
    [string[]]$computerName,
    [string[]]$Username
  )
  
  $sb = {
    param
    (
      [String]
      $Username
    )
    
    $tempfile1 = New-TemporaryFile
    $tempfile2 = New-TemporaryFile

    $RegistryProfileList = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*"
    $Profiles = Foreach ($Profile in (Get-ItemProperty $RegistryProfileList | Where {$_.PSChildName -Like "S-1-5-21*"})){ 
      [PSCustomObject]@{
        SID = ($Profile).PSChildName
        UserHive = "$(($Profile).ProfileImagePath)\ntuser.dat"
        Username = ($Profile).ProfileImagePath -replace ('.*\\')
      }
    }

    foreach ($Profile in $Profiles)
    {
      $null = reg load HKU\$($Profile.SID) $($Profile.UserHive)
      $UserHiveRoot = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$($Profile.SID)"
      
      if ( $username )
      {
        if ( $( $Profile.Username ) -eq $Username )
        {
          if ( ( Get-ChildItem "$UserHiveRoot\printers\Connections" -ErrorAction SilentlyContinue ) -ne $null )
          {
            ( ( Get-ChildItem "$UserHiveRoot\printers\Connections" -ErrorAction SilentlyContinue ).PSChildName ).Replace(',','\')
          }
        }
      }
      else
      {
        if ( ( Get-ChildItem "$UserHiveRoot\printers\Connections" -ErrorAction SilentlyContinue ) -ne $null )
        {
          ( ( Get-ChildItem "$UserHiveRoot\printers\Connections" -ErrorAction SilentlyContinue ).PSChildName ).Replace(',','\') | % {
            [pscustomobject]@{
              Username = $($Profile.Username)
              Printer  = $_
            }
          }
        }
      }
    }

    [gc]::Collect()
    Start-Process -FilePath 'reg' -ArgumentList "unload HKU\$($Profile.SID)" -RedirectStandardOutput $tempfile1 -RedirectStandardError $tempfile2 -NoNewWindow
  }
  
  if ( $computerName ) 
  {
    foreach ($Computer in $Computername)
    {
      Invoke-Command -ScriptBlock $sb -ComputerName $Computer -ArgumentList $Username
    }
  }
  else
  {
    Invoke-Command -ScriptBlock $sb -ArgumentList $Username
  }
}