function Get-ComputerModel 
{ 
  [CmdletBinding()] 
  Param 
  ( 
    #The Computername/IP Address of the remote computer. 
    [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true, 
        ValueFromPipeline=$true, 
    Position=0)] 
    [Alias('Name', 'IPv4Address', 'CN')] 
    [string[]]$Computername, 
 
    [Parameter(Mandatory=$False)] 
    [System.Management.Automation.PSCredential]$credential 
  ) 
 
  Begin 
  { 
  } 
  Process 
  { 
 
    $Computername | ForEach-Object { 
      $parms = @{} 
      if ($credential) { $parms.Add('Credential', $credential)} 
 
      $Results = @{"Status"="" 
        "Name"="$_" 
        "Manufacturer"="" 
      "Model"=""}      
 
      Write-Verbose -Message "Checking to see if $_ is online..." 
      If (Test-Connection -ComputerName $_ -Count 1 -Quiet -BufferSize 100 ) {        
        try { 
          Write-Verbose -Message "Running WMI query on $_" 
          $computerResults = Get-WMIObject -ComputerName $_ -class Win32_ComputerSystem @parms -ErrorAction Stop 
 
          $Results["Status"] = "Online" 
          $Results["Manufacturer"] = "$($computerResults.Manufacturer)" 
          $Results["Model"] = $($computerResults.Model) 
 
        } catch { 
          $Results["Status"] = "Failed: $($_.Exception.Message)" 
        } 
      } 
      Else { 
        $Results["Status"] = "Failed: $Computername is Offline." 
      } 
 
      return New-Object PSobject -Property $Results | Select-Object Name, Model, Manufacturer, Status 
    } 
 
 
  } 
  End 
  { 
  } 
}
<#

Author:
Version:
Version History:

Purpose:

#>