function Get-UserProfileSize
{
  [ CmdletBinding() ]
  Param
  (
    [ Alias    ( "Computer","Host","Hostname"          ) ]
    [ String[] ] $Computername
  )

  $ScriptBlock = {
    $UserProfiles = Get-ChildItem -Path C:\users | Select-Object -ExpandProperty fullname

    foreach ($Profile in $UserProfiles)
    {
      $username = $profile | Split-Path -Leaf
  
      $data = Get-ChildItem $Profile -Recurse -Force -ErrorAction SilentlyContinue -Verbose | Measure-Object -Sum -Property Length -ErrorAction SilentlyContinue -Verbose
  
      [pscustomobject]@{
        Username    = $username
        Files       = $data.Count
        "Size (MB)" = [math]::Round( $data.Sum / 1MB , 3)
      }
    }
  }

  if($Computername)
  {
    foreach ($Computer in $Computername)
    {
      Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $Computer
    }
  }
  else
  {
    Invoke-Command -ScriptBlock $ScriptBlock
  }
}