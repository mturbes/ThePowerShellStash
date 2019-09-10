function Fix-Office 
{
  param
  (
    [String[]]
    $ComputerName = $null,
  
    [Switch]
    $MailProfiles,
    
    [Switch]
    $Credentials
  )
  $FixScript = {
    param
    (
      [String[]]
      $ComputerName = $null,
      [Bool]
      $MailProfiles,
      [Bool]
      $Credentials
    )
    $PatternSID    = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
    $ProfileList   = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} | 
    Select  @{name="SID";expression={$_.PSChildName}}, 
    @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
    @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
 
    $LoadedHives   = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}
 
    $UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username
 
    Foreach ($item in $ProfileList) {
      IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
      }
    
      write-host $($item.Username) -ForegroundColor Cyan
      if($MailProfiles)
      {
        Remove-Item -Path "registry::HKEY_USERS\$($Item.SID)\Software\Microsoft\Office\16.0\Outlook\Profiles\*" -Recurse -Verbose -ErrorAction SilentlyContinue -Force
        Remove-Item -Path "registry::HKEY_USERS\$($Item.SID)\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\profiles\*" -Recurse -Verbose -ErrorAction SilentlyContinue -Force
      }
      if ($Credentials)
      {
        Remove-Item -Path "registry::HKEY_USERS\$($Item.SID)\Software\Microsoft\Office\16.0\Common\Identity" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
      }
    
      IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
      }
    }
    if($Credentials)
    {
      $users = (Get-ChildItem C:\users).Name
      foreach ($User in $Users)
      {
        Write-Host $user -ForegroundColor Cyan
        Remove-Item -Path "C:\users\$user\AppData\Local\Microsoft\Credentials" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\users\$user\AppData\Roaming\Microsoft\Credentials" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
      }
    }
    $cscript = 'C:\Windows\System32\cscript.exe'
    $ospp = '"c:\program files (x86)\microsoft office\office16\ospp.vbs"'
    $tempfile = New-TemporaryFile

    Start-Process -FilePath $cscript -ArgumentList "$ospp /dstatus" -NoNewWindow -RedirectStandardOutput $tempfile.FullName -Wait

    $output = Get-Content -Path $tempfile.FullName

    if ( $output -like "*No installed product keys detected*" )
    {
      'No installed product keys detected..'
    }
    else
    {
      foreach ($Line in $Output)
      {
        if ( $line -like 'LICENSE NAME:*' )
        {
          Write-Host $Line
        }
        if ( $Line -like 'Last 5 characters of installed product key:*' )
        {
          $pkey = $line.Substring($line.Length - 5)
          "Removing license key $pkey.."
          Start-Process -FilePath $cscript -ArgumentList "$ospp /unpkey:$pkey"
          "Done!"
        }
      }
    }

    Remove-Item -Path $tempfile.FullName
  }
  if ($ComputerName)
  {
    Invoke-Command -ScriptBlock $FixScript -ComputerName $computername -ArgumentList $computername,$MailProfiles,$Credentials
  }
  else
  {
    Invoke-Command -ScriptBlock $FixScript -ArgumentList $computername,$MailProfiles,$Credentials
  }
}