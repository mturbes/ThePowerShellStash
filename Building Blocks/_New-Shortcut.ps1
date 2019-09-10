function Set-Shortcut
{

  param(
    [String] $TargetPath,
    [String] $ShortcutPath,
    [String] $Iconlocation = $null,
    [String] $Arguments = $null
  )

  Write-Host 'Creating shortcut ' $ShortcutPath ' to ' $TargetPath '..'

  $W                   = New-Object -ComObject Wscript.Shell
  $Shortcut            = $w.CreateShortcut($ShortcutPath) 
  $Shortcut.TargetPath = $TargetPath
  if ( $Arguments )
  { $shortcut.Arguments  = $Arguments }
  if ( $Iconlocation )
  { $Shortcut.IconLocation = $Iconlocation }
  $Shortcut.save()
}