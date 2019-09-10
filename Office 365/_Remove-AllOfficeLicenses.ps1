$cscript = 'C:\Windows\System32\cscript.exe'
$ospp = '"c:\program files (x86)\microsoft office\office16\ospp.vbs"'
$tempfile = New-TemporaryFile

Start-Process -FilePath $cscript -ArgumentList "$ospp /dstatus" -NoNewWindow -RedirectStandardOutput $tempfile.FullName -Wait

$output = Get-Content -Path $tempfile.FullName

if ( $output -like "*No installed product keys detected*" )
{
  'No installed product keys detected..'
}
else
{
  foreach ($Line in $Output)
  {
    if ( $line -like 'LICENSE NAME:*' )
    {
      Write-Host $Line
    }
    if ( $Line -like 'Last 5 characters of installed product key:*' )
    {
      $pkey = $line.Substring($line.Length - 5)
      "Removing license key $pkey.."
      Start-Process -FilePath $cscript -ArgumentList "$ospp /unpkey:$pkey"
      "Done!"
    }
  }
}

Remove-Item -Path $tempfile.FullName
