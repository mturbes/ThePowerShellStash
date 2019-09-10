function Set-EnvironmentVariable
{
  [ CmdletBinding() ]
  [ Alias( 'senv' ) ]
  Param
  (
    [ Parameter ( Position = 0 ) ]
    [ ValidateNotNull ( ) ]
    [ ValidateNotNullOrEmpty ( ) ]
    [ String ]
    $Name,

    [ Parameter ( Position = 1 ) ]
    [ ValidateNotNull ( ) ]
    [ AllowEmptyString ( ) ]
    [ String ]
    $Value,
    
    [ Parameter ( Position = 2 ) ]
    [ AllowNull ( ) ]
    [ ValidateSet ( "Machine", "User" ) ]
    [ Alias ( "Type" ) ]
    $Scope = "Machine",

    [ Parameter( ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true ) ]
    [ Alias ( "Computer","Host","Hostname" ) ]
    [ String[] ]
    $Computername = $env:COMPUTERNAME
  )

  Begin
  {
    $ScriptBlock = {
      param
      (
        [String]
        $Name,
        
        [String]
        $Value,
          
        [String]
        $Scope
      )
      [Environment]::SetEnvironmentVariable( $Name, $Value, $Scope )
    }
  }
  Process
  {
    Write-Verbose "Setting $Scope variable $Name to $Value on computer $Computername.."
      
    Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $Computername -ArgumentList $Name,$Value,$Scope
  }
  End
  {
  }
}