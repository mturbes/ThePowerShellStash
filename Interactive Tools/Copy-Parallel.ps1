workflow Copy-Parallel {
  param ([string[]]$ComputerName, [string]$SourcePath,[string]$TargetPath)
  foreach -parallel -throttlelimit 30 ($computer in $ComputerName) {
    InlineScript {
      try {
        $tmps = New-PSSession -ComputerName $using:computer
        Copy-Item -Path $using:SourcePath -Destination $using:Targetpath -ToSession $tmps -Verbose -Container -Recurse -Force
      } finally {
        Remove-PSSession -Session $tmps
      }
    }
  }
}