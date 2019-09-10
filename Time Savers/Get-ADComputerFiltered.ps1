function gadc
{
  param
  (
    [String]
    [Parameter(position=0,Mandatory)]
    [Alias("f")]
    $Filter
  )
  $filter = "*$Filter*"
  
  (Get-ADComputer -Filter { name -like $filter }).Name
}