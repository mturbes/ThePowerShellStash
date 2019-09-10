function Get-SignedInUser
{
  param
  (
    [String[]]
    [Parameter()]
    $Computername = $null,
    [String[]]
    [Parameter()]
    $Session = $null
  )
  
  $DetermineIfLocked = {
    $currentuser = gwmi -Class win32_computersystem | Select-Object -ExpandProperty username
    $process = get-process logonui -ea silentlycontinue

    if( $process )
    { $status = 'Locked'  }
    else
    { $status = 'Unlocked'}

    $Return = [pscustomobject]@{
      Computer = $env:Computername
      Status = $status
      User = $currentuser
    }
    Write-Output $return
  }
  if ( $Computername )
  {
    Invoke-Command -ScriptBlock $DetermineIfLocked -ComputerName $Computername -ErrorAction SilentlyContinue
  }
  elseif ( $session )
  {
    Invoke-Command -ScriptBlock $DetermineIfLocked -Session $Session -ErrorAction SilentlyContinue
  }
}