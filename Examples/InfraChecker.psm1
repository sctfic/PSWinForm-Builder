function Get-DNSBySamAccountName {
    [CmdletBinding()]
    param (
        $prefix = '^(SRV|P|V)-'
    )
    begin {
        # $Script:ControlHandler["Loading"].Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        # $Script:ControlHandler["Loading"].Enabled = $true
        # $Script:ControlHandler["Loading"].Visible = $true
        $Zone = ([System.DirectoryServices.ActiveDirectory.Domain]::getCurrentDomain()).Forest.name
    }
    process {
        Get-ADComputer -Filter "DNSHostName -match `"$prefix`"" -Properties DNSHostName,IPv4Address -Server $Zone | %{
            $ping = Ping $_.IPv4Address -ports 0 -loop 1
            [PSCustomObject]@{
                FirstColValue = $_.DNSHostName
                NextValues    = $_.IPv4Address,"$($ping.ICMP) ms"
                Group         = $null
                Caption       = $_.SID.Value
                Status        = if ($ping.status -ne '100%') { 'Warn' } # defini la couleur si commance par : Warn, Info, Title
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
        [string]$prefix = '^(SRV|P|V)-'
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
function Get-Port2Ping {
    Write-Host -fore Cyan 'Get-Port2Ping'
    $Ports = @('Checkbox_SSH', 'Checkbox_RDP', 'Checkbox_JetDirect', 'Checkbox_ICMP' | Get-CheckBoxValue) + @((Get-TextBoxValue 'OtherPorts') -split(',;') | %{
        Write-Host -fore Cyan $_
        ($_ -as [int])
    } | ?{$_}) -join(',')
    Write-Host -fore Cyan $Ports

    # return $Ports
}