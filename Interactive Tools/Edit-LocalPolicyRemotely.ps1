function Edit-LocalPolicyRemotely
{
  param
  (
    [String[]]
    $Computername
  )

  if ( $Computername -is [array] )
  {
    foreach ($Computer in $Computername)
    {
      Start-Process -FilePath 'gpedit.msc' -ArgumentList "/gpcomputer:`"$computer`""
    }
  }
  else
  {
    Start-Process -FilePath 'gpedit.msc' -ArgumentList "/gpcomputer:`"$computername`""
  }
}