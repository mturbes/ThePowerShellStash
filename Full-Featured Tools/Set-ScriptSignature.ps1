function Set-ScriptSignature
{
  [alias("sign")]
  param
  (
    [string]$Certificate,
    
    [switch]$ShowFileSelector,
    
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias("FilePath","Path","FullName")]
    [string[]] $ScriptPath
    
    #todo: add recursive parameter and check if directory
  )
  
  if ( $ShowFileSelector ) { 
    $ScriptPath = Show-FileSelector # If showing file selector, override ScriptPath if specified by user

  }
  
  #Get nearby scripts if no path provided
  if ( -not $ScriptPath ) {
    $ScriptPath = ( Get-ChildItem -Path $PSScriptRoot ).FullName | Where-Object { ( $_ -Like "*.ps1" ) -or ( $_ -like "*.psm1" ) }
  }
  
  $ScriptPath
  
  if ( -not $CertificatePath ) { 
    
    # Generate self signed cert if not exists
    if ( -not ( gci cert:\currentuser\my | ? subject -eq 'CN=Michael Turbes Enterprises' ) ) {
      Write-Host 'Generating Self-Signed Script'
      New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -Type CodeSigningCert -Subject "Michael Turbes Enterprises"
    }

    $Certificate = @( Get-ChildItem cert:\CurrentUser\My -codesigning )[0]
  } # End no certificate specified
  
  $Certificate
  
  $ScriptPath | ForEach-Object {
    $SetAuthenticodeSignature = @{
      FilePath = $_
      Certificate = $CertificatePath
      TimestampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll'
    }
    Set-AuthenticodeSignature @SetAuthenticodeSignature
  }
  
}
function Show-FileSelector
{
  
  [alias("Show-FileDialog")]
  param
  (
    [string]
    $filter #Example: PowerShell Scripts (*.ps1)|*.ps1|PowerShell Modules (*.psm1)|*.psm1
    #TODO: Parameter set with built-in filters
  )
  Add-Type -AssemblyName System.Windows.Forms
  
  $Prompt = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = $PSScriptRoot
    Filter = 'PowerShell Scripts (*.ps1)|*.ps1|PowerShell Modules (*.psm1)|*.psm1'
  }
  
  $null = $Prompt.ShowDialog()
  
  $prompt.FileName
}

# If this script isn't dot-sourced, run top function with all defaults
if ( $myinvocation.InvocationName ) {
  Set-ScriptSignature
}