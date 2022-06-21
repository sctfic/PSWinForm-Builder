<#
.SYNOPSIS
    PowerShell Module to build a windows.forms object from a defintion file
.DESCRIPTION
    PSWinForm-Builder is a PowerShell module to load a Windows.Forms from a PSD1 definition file, all Windows.Forms controls can be defined.
    PSD1 file must habe following structure
    @{
        ControlType = 'Form'
        Name        = 'Form Name'
        KeyPreview  = $true
        Size        = '360, 480'
        # ... Form property fields ...
        Icon            = [System.Drawing.Icon][System.IO.MemoryStream] [System.Convert]::FromBase64String('Base64 *.Ico') 
        Events      = @{
            Load    = [Scriptblock]{'ScriptBlock Code'}
            KeyDown = [Scriptblock]{
                if ($_.KeyCode -eq 'Escape') {
                    $this.Close()
                }
            }
        }
        Childrens   = @(
            @{
                ControlType = 'GroupBox'
                Nane        = 'Gxb_1'
                # Recursive structure ...
            }
            @{
                ControlType = 'GroupBox'
                Nane        = 'Gxb_2'
                # Recursive structure ...
            }
        )
    }

.PARAMETER FormsFile
    psd1 files containing the form defintition
.EXAMPLE
    Build a new form with some controls
    $MyForm = New-WinForm .\myWinForm.psd1
.NOTES
    Author  : alban LOPEZ
.LINK
    https://github.com/sctfic/PSWinForm-Builder
#>


function New-WinForm () {
    param(
        [Parameter(Mandatory = $True, 
            ValueFromPipeline = $False,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'File contenaining form definition')]
        [string]$DefinitionFile,
        [switch]$Show
    )

    # Get forms definition from file
    $FormDef = Import-PowerShellDataFile  $DefinitionFile -SkipLimitCheck
    $Script:ControlHandler = @{}
    
    if ($FormDef.ControlType -and $FormDef.ControlType -ne 'Form') {

    } else {
        Write-Verbose "[Form]"
        # Write-LogStep '[Form]',"" ok
        $Form = New-WinFormControl -Type 'Form' -Definition $FormDef
    }

    if ($Show) {
        $Form.ShowDialog()
    } else {
        return $Form
    }
}

function New-WinFormControl {
    param (
        $Type,
        $Definition,
        $tabs=''
    )
    if ($Definition.Name) {
        $Name = $Definition.Name
    } else {
        $i=0
        $Name = "${Type}_$i"
        while ($Script:ControlHandler[$Name]) {
            $i++
            $Name = "${Type}_$i"
        }
    }
    Write-Verbose "Script:ControlHandler[$Name]"

    $Script:ControlHandler[$Name] = New-Object System.Windows.Forms.$Type
    # Construction des Properties
    # $ValidProperties = $Script:ControlHandler[$Name].PSobject.Properties.Name
    foreach ($Key in $Definition.Keys) {
        try {
            if (@('Events','Childrens','ControlType') -notcontains $Key) {
                Write-Verbose "$Tabs+-- $Key = $($Definition.$Key)"
                $Script:ControlHandler[$Name].$Key = $Definition.$Key
                # Write-LogStep $Key,$($Definition.$Key) ok
            }
        } catch {
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
        }
    }

    # Construction des Events
    # $ValidEvents = $Script:ControlHandler[$Name].PSobject.Methods.Name
    foreach ($Evt in $Definition.Events.Keys) {
        try {
            Write-Verbose "$Tabs+-- On_$($Evt)()"
            $Script:ControlHandler[$Name]."Add_$($Evt)"( $Definition.Events.$Evt )
            # Write-LogStep 'Event',"On_$($Evt)" ok
        } catch {
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
        }
    }

    # Construction des Childrens Controls
    foreach ($Children in $Definition.Childrens) {
        try {
            Write-Verbose "$tabs[$($Children.ControlType)]"
            $Script:ControlHandler[$Name].Controls.Add((New-WinFormControl -Type $Children.ControlType -Definition $Children -Tabs "   $Tabs"))
            # Write-LogStep "[$($Children.ControlType)]",'' ok
        } catch {
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
        }
    }

    $Script:ControlHandler[$Name]
}




Add-Type -AssemblyName System.Windows.Forms 
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Drawing 

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




# New-ModuleManifest -Path 'C:\Users\alopez\Documents\PowerShell\Modules\PSWinForm-Builder\PSWinForm-Builder.psd1' `
#                    -Author 'alban LOPEZ' `
#                    -ModuleVersion '0.0.0.01' `
#                    -CompanyName 'Lpz' `
#                    -RootModule 'PSWinForm-Builder.psm1' `
#                    -NestedModules PsWrite
                   

function Invoke-EventTracer {
    param (
        $ObjThis,
        $EventType
    )
    # $ObjThis | Write-Object
    Write-Host $ObjThis.name,$EventType -ForegroundColor Magenta
}

