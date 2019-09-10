function Set-Title {
  param 
  (
    [string] $newtitle = 'Powershell, yo.'
  )
  $host.ui.RawUI.WindowTitle = $newtitle
}