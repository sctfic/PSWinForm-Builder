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
$Pass=[char]9474
$Plus=[char]9500
$Space=[char]9472
$Last=[char]9492

# class ThreadScriptBlock {
#     # Optionally, add attributes to prevent invalid values
#     [string]$Name
#     [ScriptBlock]$ScriptBlock
#     ThreadScriptBlock( $ScriptBlock) { # [ThreadScriptBlock]::new('xxx',{return 123})
#     #    $this.Name = $Name
#        $this.ScriptBlock = $ScriptBlock
#     }
# }


function New-WinForm () {
    param(
        [Parameter(Mandatory = $True, 
            ValueFromPipeline = $False,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'File contenaining form definition')]
        [string]$DefinitionFile,
        [switch]$PassThru,
        [switch]$HideConsole,
        [Alias('Modules')][string[]]$PreloadModules
    )
    begin{
        Write-LogStep "Load Descriptor File",$DefinitionFile Wait
        $Global:Verbose = ($PSCmdlet.MyInvocation.BoundParameters -and $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
        if ($HideConsole -and !$PassThru) {
            if (-not ('Console.Window' -as [type])) {
                Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")]public static extern IntPtr GetConsoleWindow();[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
            }
            $consolePtr = [Console.Window]::GetConsoleWindow()
            [Console.Window]::ShowWindow($consolePtr,0) | Out-Null
        }
        $Global:Modules = @()
        $Global:FormModule = (Get-Item ((get-item $DefinitionFile).FullName -replace('.psd1','*.psm1'))).FullName
        $Global:PSWinFormModule = (Get-Item ($PSCommandPath -replace('.psm1','_*.psm1'))).FullName
        $Script:Modules += $PreloadModules
        $Script:Modules += $Global:FormModule
        $Script:Modules += $Global:PSWinFormModule
        $Script:Modules = $Script:Modules | Sort-Object -Unique
        foreach ($Module in $Script:Modules){
            try {
                Import-module $Module -Scope Global -SkipEditionCheck -DisableNameChecking -ea Stop -Verbose:$false -Force
            } catch {
                Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
            }
        }
        # Write-Object $Script:Modules -foreGroundColor Green
    }
    process{
        # Get forms definition from file
        $FormDef = Import-PowerShellDataFile $DefinitionFile -SkipLimitCheck
        $Global:ControlHandler = @{}
        $Script:ThreadEventHandler = @{}
        
        if ($FormDef.ControlType -and $FormDef.ControlType -ne 'Form') {
            throw "[$($FormDef.ControlType)] n'est pas valide au 1er niveau. Le 1er controler doit etre de type [From] ou omis"
        } else {
            Write-Verbose "[Form]"
            # Write-LogStep '[Form]',"" ok
            $Form = New-WinFormControl -Type 'Form' -Definition $FormDef
            Write-Verbose "$Last$Space END!"
        }
    }
    end{
        Write-LogStep "Form is available","Call with '`$Global:ControlHandler['$($Form.Name)'].ShowDialog()'" -mode ok

        if (!$PassThru) {
            $MainTimer = New-Object System.Windows.Forms.Timer
            $MainTimer.Interval = 1000
            $MainTimer.add_Tick({ # on supprime les jobs terminé, toute les seconde
                $Thread = Get-Job | ?{$_.Name -like 'PSWinForm_*' -and $_.State -eq 'Completed'}
                # if ($Global:Verbose) {
                #     $Thread | Receive-Job -Wait -AutoRemoveJob
                # } else {
                    $Thread | Remove-Job
                # }
            })
            $MainTimer.Start() | Out-Null
                $Form.ShowDialog()
            $Form.Dispose()
            $MainTimer.Dispose()
            $MainTimer.Enabled = $false
            $MainTimer = $null
            if ($HideConsole) {
                [Console.Window]::ShowWindow($consolePtr,9) | Out-Null
            }
        } else {
            return $Form
        }
    }
}

function New-WinFormControl {
    param (
        [Alias('Type')]$CurrentControlType,
        [Alias('Definition')]$CurrentControlDef,
        [Alias('Indentation')]$tabs='',
        [switch]$isFirst
    )


    if ($CurrentControlDef.Name) { # Nom du Controleur
        $Name = $CurrentControlDef.Name
    } else {
        $i=0
        $Name = "${CurrentControlType}_$i"
        while ($Global:ControlHandler[$Name]) {
            $i++
            $Name = "${CurrentControlType}_$i"
        }
    }



    $Global:ControlHandler[$Name] = New-Object System.Windows.Forms.$CurrentControlType
    $Global:ControlHandler[$Name].Name = $Name
    Write-Verbose "$tabs$Plus$Space $('Name'.padright(18)) = '$($Name)'"
    # Construction des Properties
    foreach ($Key in $CurrentControlDef.Keys) {
        try {
            if (@('Name','Events','Childrens','ControlType','Items') -notcontains $Key) {
                $Global:ControlHandler[$Name].$Key = $CurrentControlDef.$Key
                Write-Verbose "$Tabs$Plus$Space $($Key.padright(18)) = '$($CurrentControlDef.$Key)'"
                if ($Global:Verbose -and $isFirst -and $Key -eq 'Dock' -and $CurrentControlDef.$Key -ne 'Fill' -and @('Checkbox','InputBox') -notcontains $Children.ControlType) {
                    Write-Color ("$tabs$Pass  $Last$Space ","Prefer @{Dock = 'Fill'} for the fisrt children and Top,Bottom,Left,Right for the following") -ForegroundColor DarkYellow, Magenta
                }
            } elseif ('Items' -eq $Key) {
                $Global:ControlHandler[$Name].Items.AddRange($CurrentControlDef.$Key)
                Write-Verbose "$Tabs$Plus$Space $($Key.padright(18)) = $($CurrentControlDef.$Key -join(','))"
            }
        } catch {
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
            $ValidProperties = $Global:ControlHandler[$Name].PSobject.Properties.Name -join(', ~') -split('~')
            Write-Host "[$Name] accepte only :" -ForegroundColor Red -NoNewline
            Write-Color $ValidProperties -ForeGroundColor Red,Magenta
        }
    }



    # Construction des Events
    if ($CurrentControlDef.Events.Keys){
        foreach ($Evt in $CurrentControlDef.Events.Keys) {
            try {
                Write-Verbose "$Tabs$Plus$Space Event.On_$($Evt)()"
                if ($CurrentControlDef.Events.$Evt -is [ScriptBlock] ) {
                    $Global:ControlHandler[$Name]."Add_$($Evt)"( $CurrentControlDef.Events.$Evt )
                } elseif($CurrentControlDef.Events.$Evt -is [Hashtable]) {
                    if($CurrentControlDef.Events.$Evt.Type -eq 'Thread') {
                        # Write-Host 'ThreadScriptBlock' -backgroundColor Magenta 
                        $ThreadName = "$Name-$Evt"
                        $Script:ThreadEventHandler[$ThreadName] = @{
                            Name = $ThreadName
                            ScriptBlock = [Scriptblock]$CurrentControlDef.Events.$Evt.ScriptBlock
                        }
                        # Start-ThreadJob
                        
                        $ThreadScriptBlock = [scriptblock]::Create(
                            "
                            Invoke-EventTracer $Name 'Thread_$ThreadName'
                            if (!(Get-Job -Name 'PSWinForm_$ThreadName' -ea 0)){
                                Start-ThreadJob -Name 'PSWinForm_$ThreadName' ``
                                    -InitializationScript {import-Module '$($Global:PSWinFormModule -join("', '"))','$($Global:FormModule -join("', '"))' -SkipEditionCheck -DisableNameChecking} ``
                                    -ScriptBlock `$Script:ThreadEventHandler['$ThreadName'].ScriptBlock ``
                                    -ArgumentList `$Global:ControlHandler,'$Name','$Evt' ``
                                    -StreamingHost `$host
                            }
                            "
                        ) # `$Script:ThreadEventHandler['$ThreadName'].ScriptBlock")
                        $Global:ControlHandler[$Name]."Add_$($Evt)"($ThreadScriptBlock)
                    } else {}
                } else {}
                # Write-LogStep 'Event',"On_$($Evt)" ok
            } catch {
                Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
                $ValidEvents = ($Global:ControlHandler[$Name].PSobject.Methods.Name | Where-Object {
                    $_ -match 'add_.+'
                }) -replace('add_') -join(', ~') -split('~')
                Write-Host "[$Name] accepte only : " -ForegroundColor Blue -NoNewline
                Write-Color $ValidEvents -ForeGroundColor Yellow,Magenta
            }
        }
    }



    $FirstChild = $true
    # Construction des Childrens Controls
    foreach ($Children in $CurrentControlDef.Childrens ) {
        try {
            Write-Verbose "$tabs$Plus$Space [$($CurrentControlDef.ControlType)].$($Children.ControlType)"
            $WinFormChildren = (New-WinFormControl -Type $Children.ControlType -Definition $Children -Tabs "$Pass  $Tabs" -isFirst:$FirstChild)
            if ($Children.ControlType -match '^ToolStrip') {
                if ($CurrentControlDef.ControlType -match '^ToolStrip') {
                    Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].DropDownItems.Add([$($Children.ControlType)].$($WinFormChildren.Name))"
                    [void]$Global:ControlHandler[$Name].DropDownItems.Add($Global:ControlHandler[$WinFormChildren.Name])
                } else {
                    Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Items.Add([$($Children.ControlType)].$($WinFormChildren.Name))"
                    [void]$Global:ControlHandler[$Name].Items.Add($Global:ControlHandler[$WinFormChildren.Name])
                }
            } elseif($Children.ControlType -eq 'ContextMenuStrip') {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].ContextMenuStrip = [$($Children.ControlType)].$($WinFormChildren.Name)"
                # [void]$Global:ControlHandler[$Name].Controls.Add($Global:ControlHandler[$WinFormChildren.Name])
                $Global:ControlHandler[$Name].ContextMenuStrip = $Global:ControlHandler[$WinFormChildren.Name]
            } elseif($Children.ControlType -eq 'MenuStrip') {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].MainMenuStrip = [$($Children.ControlType)].$($WinFormChildren.Name)"
                [void]$Global:ControlHandler[$Name].Controls.Add($Global:ControlHandler[$WinFormChildren.Name])
                $Global:ControlHandler[$Name].MainMenuStrip = $Global:ControlHandler[$WinFormChildren.Name]
            } elseif($Children.ControlType -match '^(ColumnHeader|DataGridView\w+Column)$') {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Columns = [$($Children.ControlType)].$($WinFormChildren.Name)"
                [void]$Global:ControlHandler[$Name].Columns.Add($Global:ControlHandler[$WinFormChildren.Name])
            # } elseif(@('ComboBox','ListBox') -contains $Children.ControlType) {
                # Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Items.Add([$($Children.ControlType)].$($WinFormChildren.Name))"
            #     [void]$Global:ControlHandler[$Name].Items.Add($Global:ControlHandler[$WinFormChildren.Name])
            } else {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Controls.Add([$($Children.ControlType)].$($WinFormChildren.Name))"
                [void]$Global:ControlHandler[$Name].Controls.Add($WinFormChildren)
            }
            # Write-LogStep "[$($Children.ControlType)]",'' ok
        } catch {
            # $Children | Write-Object -fore red
            write-host "[$($CurrentControlDef.ControlType)]$Name.[$($Children.ControlType)]$($Children.Name)" -foreGroundColor red
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
        }
        $FirstChild = $false
    }
    # $Global:ControlHandler[$Name] | Write-Object -fore gray
    $Global:ControlHandler[$Name]
}


Add-Type -AssemblyName System.Windows.Forms 
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Drawing 

if (Get-Module PsWrite) {
    # Export-ModuleMember -Function Convert-RdSession, Get-RdSession
    Write-LogStep 'Chargement du module ',$PSCommandPath ok
} else {
    function Script:Write-logstep {
        param ( [string[]]$messages, $mode, $MaxWidth, $EachLength, $prefixe, $logTrace )
        Write-Verbose "$($messages -join(',')) [$mode]"
        # Write-LogStep '',"" ok
    }
}