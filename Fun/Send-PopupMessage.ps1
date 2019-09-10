function Send-Msg
{
  param
  (
    [String[]]
    $Computername,
    [string]
    $Msg
  )

  $ScriptBlock = {
    param
    (
      [string]
      $Msg
    )
    msg * /v /w $msg
  }

  if ($ComputerName)
  {
    Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $computername -ArgumentList $Msg
  }
  else
  {
    Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $Msg
  }
}