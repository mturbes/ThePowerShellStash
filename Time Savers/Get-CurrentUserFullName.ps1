function Get-CurrentUserFullName
{
  Get-WMIObject Win32_UserAccount | where caption -eq ( whoami ) | select FullName
}