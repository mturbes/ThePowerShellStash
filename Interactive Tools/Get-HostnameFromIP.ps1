function Get-HostnameFromIpAddress
{
  param
  (
    [String[]]
    $IpAddress
  )

  foreach ($ip in $IpAddress) 
  { 
    $Hostname = [System.Net.Dns]::gethostentry($ip)
    $Output = [PSCUSTOMOBJECT]@{
      IP = $ip
      Host = $Hostname
    }
    $Output
  } 
}