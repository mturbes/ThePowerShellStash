# Turn proxy on or off in IE settings based on whether the current network connection is a domain network or not

function Refresh-IESettings
{
  $signature = @'
[DllImport("wininet.dll", SetLastError = true, CharSet=CharSet.Auto)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@

  $INTERNET_OPTION_SETTINGS_CHANGED   = 39
  $INTERNET_OPTION_REFRESH            = 37
  $type = Add-Type -MemberDefinition $signature -Name wininet -Namespace pinvoke -PassThru
  $a = $type::InternetSetOption(0, $INTERNET_OPTION_SETTINGS_CHANGED, 0, 0)
  $b = $type::InternetSetOption(0, $INTERNET_OPTION_REFRESH, 0, 0)
  return $a -and $b
}

while ( $True )
{
  $ProxyEnabled = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable).ProxyEnable
    
  if ( ( Get-NetConnectionProfile ).NetworkCategory -match 'DomainAuthenticated' )
  {
    if ( -not $ProxyEnabled )
    {
      Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1
      Refresh-IESettings
    }
  } else {
    if ( $ProxyEnabled -eq $True )
    {
      Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0
      Refresh-IESettings
    }
  }
  
  Start-Sleep -Seconds 10
}
