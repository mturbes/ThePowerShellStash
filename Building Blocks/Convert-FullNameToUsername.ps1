function Convert-FullNameToUsername
{
  param
  (
    [String[]]
    [Parameter(Mandatory,
        ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true)]
    $FullName,
    [switch]
    $OPS
  )
  process
  {
    if ( $OPS ) {
      $server = 'FPBSMBPRD007.OPS.LOCAL'
    } else { 
      $server = 'PBISFXPRD001.PREMIER.LOCAL'
    }
    
    $FirstName = $FullName.split(' ') | Select-Object -First 1
    $LastName  = $FullName.split(' ') | Select-Object -Last 1
    
    Get-ADUser -Filter { ( GivenName -eq $FirstName )  -and ( Surname -eq $LastName ) } -Properties 'SamAccountName' -Server $server |
    Select-Object -ExpandProperty 'SamAccountName'
  }
}