Import-Module PsBright -Function ping
# function Get-DNSBySamAccountName {
#     [CmdletBinding()]
#     param (
#         $prefix = 'SRV-'
#     )
#     begin {
#         # $Global:ControlHandler["Loading"].Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
#         # $Global:ControlHandler["Loading"].Enabled = $true
#         # $Global:ControlHandler["Loading"].Visible = $true
#         $Zone = ([System.DirectoryServices.ActiveDirectory.Domain]::getCurrentDomain()).Forest.name
#     }
#     process {
#         Get-ADComputer -Filter "DNSHostName -like `"$prefix`"" -Properties DNSHostName,IPv4Address -Server $Zone | %{
#             $ping = Ping $_.IPv4Address -ports 0 -loop 1
#             [PSCustomObject]@{
#                 FirstColValue = $_.DNSHostName
#                 NextValues    = $_.IPv4Address,"$($ping.ICMP) ms"
#                 Group         = $null
#                 Caption       = $_.SID.Value
#                 Status        = if ($ping.status -ne '100%') { 'Warn' } # defini la couleur si commance par : Warn, Info, Title
#                 Shadow        = $false # gris clair
#             }
#         }
#     }
#     end {
#         # $Global:ControlHandler["Loading"].Enabled = $false
#         # $Global:ControlHandler["Loading"].Visible = $false
#     }
# }
function Get-DnsByName {
    param (
        [string]$prefix = '^(SRV|P|V)-'
    )
    begin{
        # $Global:ControlHandler["Loading"].Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        # $Global:ControlHandler["Loading"].Enabled = $true
        # $Global:ControlHandler["Loading"].Visible = $true
        $Zone = ([System.DirectoryServices.ActiveDirectory.Domain]::getCurrentDomain()).Forest.name
    }
    process{
        
        $dns = Get-DnsServerResourceRecord -ComputerName $Zone -ZoneName $Zone -RRType A | ?{$_.hostname -match "$prefix.*"}
        
        $dns | %{
            $ping = Ping $_.RecordData.IPv4Address.IPAddressToString -ports 0 -loop 1
            [PSCustomObject]@{
                FirstColValue = $_.HostName + "." + $Zone
                NextValues    = $_.RecordData.IPv4Address.IPAddressToString,"$($ping.ICMP) ms"
                Group         = (($_.HostName -split ('\.'))[1..2] -join ('.'))
                Caption       = "infos Bulles"
                Status        = if ($ping.status -ne '100%') { 'Warn' } # defini la couleur si commance par : Warn, Info, Title
                Shadow        = $false # gris clair
            }
        }
    }
    end {
        # $Global:ControlHandler["Loading"].Enabled = $false
        # $Global:ControlHandler["Loading"].Visible = $false
    }
 }
function Get-Port2Ping {
    [Int16[]]$Ports = @()
    $Ports = 'Checkbox_SSH', 'Checkbox_RDP', 'Checkbox_JetDirect', 'Checkbox_ICMP' | Get-CheckBoxValue | Where-Object {$null -ne $_} | %{($_ -as [int])}
    $Ports +=  ('TextBox_OtherPorts' | Get-TextBoxValue) -split(';|,| |\.') | Where-Object {$_} | %{($_ -as [int])}
    return ($Ports | Sort-Object -Unique)
}

Write-Host $Module -fore DarkYellow

if (Get-Module PsWrite) {
    # Export-ModuleMember -Function Convert-RdSession, Get-RdSession
    Write-LogStep 'Chargement du module ', $PSCommandPath ok
} else {
    function Script:Write-logstep {
        param ( [string[]]$messages, $mode, $MaxWidth, $EachLength, $prefixe, $logTrace )
        Write-Verbose "$($messages -join(',')) [$mode]"
        # Write-LogStep '',"" ok
    }
}