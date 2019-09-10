function Get-PendingReboot
{

  param
  (
    [String[]]
    $ComputerName = 'localhost'
  )
  $ScriptBlock = {
    $CBSRebootPending   = ( Get-ChildItem "HKLM:Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ea sil     ) -ne $null
    $WinUpdatePending   = ( Get-Item "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ea sil         ) -ne $null
    $FileRenamePending  = ( Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ea sil ) -ne $null
  
    $RestartPending     = $CBSRebootPending -or $FileRenamePending -or $WinUpdatePending
    $LoggedInUser       = ( Get-WmiObject -Class win32_computersystem ).UserName
  
    [pscustomobject]@{
      ComputerName      = $env:COMPUTERNAME
      CBSPending        = $CBSRebootPending
      WinUpdatePending  = $WinUpdatePending
      FileRenamePending = $FileRenamePending
      RestartPending    = $RestartPending
      LoggedInUser      = $LoggedInUser
      Rebootable        = ( $RestartPending -eq $true ) -and ( $LoggedInUser -eq $null )
    }
  }
  
  Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName
}