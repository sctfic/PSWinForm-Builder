function Get-DNSBySamAccountName {
    [CmdletBinding()]
    param (
        $prefix = 'SRV-'
    )
    begin {
        # $Script:ControlHandler["Loading"].Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        # $Script:ControlHandler["Loading"].Enabled = $true
        # $Script:ControlHandler["Loading"].Visible = $true
        $Zone = ([System.DirectoryServices.ActiveDirectory.Domain]::getCurrentDomain()).Forest.name
    }
    process {
        Get-ADComputer -Filter 'DNSHostName -like "SRV*"' -Properties DNSHostName,IPv4Address -Server $Zone | %{
            Write-Verbose $_.DNSHostName
            [PSCustomObject]@{
                FirstColValue = $_.DNSHostName
                NextValues    = $_.IPv4Address
                Group         = $null
                Caption       = $_.SID.Value
                Status        = if ((ping $_.IPv4Address -ports 0 -loop 1).status -ne '100%') { 'Warn' } # defini la couleur si commance par : Warn, Info, Title
                Shadow        = $false # gris clair
            }
        }
    }
    end {
        # $Script:ControlHandler["Loading"].Enabled = $false
        # $Script:ControlHandler["Loading"].Visible = $false
    }
}
function Get-DnsByName {
    param (
        [string]$prefix
    )
    begin{
        # $Script:ControlHandler["Loading"].Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        # $Script:ControlHandler["Loading"].Enabled = $true
        # $Script:ControlHandler["Loading"].Visible = $true
        $Zone = ([System.DirectoryServices.ActiveDirectory.Domain]::getCurrentDomain()).Forest.name
    }
    process{
        
        $dns = Get-DnsServerResourceRecord -ComputerName $Zone -ZoneName $Zone -RRType A | ?{$_.hostname -match "$prefix.*"}
        
        $dns | %{
            Write-Verbose $_.HostName
            [PSCustomObject]@{
                FirstColValue = $_.HostName + "." + $Zone
                NextValues    = $_.RecordData.IPv4Address.IPAddressToString
                Group         = (($_.HostName -split ('\.'))[1..2] -join ('.'))
                Caption       = "infos Bulles"
                Status        = if ((ping $_.RecordData.IPv4Address.IPAddressToString -ports 0 -loop 1).status -ne '100%') { 'Warn' } # defini la couleur si commance par : Warn, Info, Title
                Shadow        = $false # gris clair
            }
        }
    }
    end {
        # $Script:ControlHandler["Loading"].Enabled = $false
        # $Script:ControlHandler["Loading"].Visible = $false
    }
 }
 function Get-CheckBoxValue {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $checkBoxName
    )
    process {
        if( $Script:ControlHandler[$checkBoxName].Checked) {
            return $Script:ControlHandler[$checkBoxName].Tag
        }
    }
 }
 function Get-TextBoxValue {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $textBoxName
    )
    process {
        if($Script:ControlHandler[$textBoxName].Text -ne '') {
            return $Script:ControlHandler[$textBoxName].Text
        }
    }
 }
