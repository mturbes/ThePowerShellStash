function New-FileSelector
{
  Add-Type -AssemblyName System.Windows.Forms
  
  $Prompt = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = $PSScriptRoot
    Filter = 'PowerShell Scripts (*.ps1)|*.ps1|PowerShell Modules (*.psm1)|*.psm1'
  }
  $null = $Prompt.ShowDialog()
  
  $prompt.FileName
}


