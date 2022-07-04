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

function New-WinForm () {
    param(
        [Parameter(Mandatory = $True, 
            ValueFromPipeline = $False,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'File contenaining form definition')]
        [string]$DefinitionFile,
        [switch]$ShowWinForms,
        [switch]$HideConsole,
        [Alias('Modules')][string[]]$PreloadModules
    )
    begin{
        Write-LogStep "Load Descriptor File",$DefinitionFile Wait
        if ($HideConsole -and $ShowWinForms) {
            if (-not ('Console.Window' -as [type])) {
                Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")]public static extern IntPtr GetConsoleWindow();[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
            }
            $consolePtr = [Console.Window]::GetConsoleWindow()
            [Console.Window]::ShowWindow($consolePtr,0) | Out-Null
        }
    }
    process{

        # Get forms definition from file
        $FormDef = Import-PowerShellDataFile $DefinitionFile -SkipLimitCheck
        $Script:ControlHandler = @{}
        
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
        $PreloadModules += (get-item $DefinitionFile).FullName -replace('.psd1','.psm1')
        foreach ($Module in $PreloadModules){
            Write-Verbose $Module
            try {
                Import-module $Module -Scope Global -SkipEditionCheck -DisableNameChecking -ea Stop -Verbose:$false -Force
            } catch {
                Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
            }
        }
        
        Write-LogStep "Form is available","Call with '`$Script:ControlHandler['$($Form.Name)'].ShowDialog()'" -mode ok

        if ($ShowWinForms) {
            $Form.ShowDialog()
            $Form.Dispose()
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
        while ($Script:ControlHandler[$Name]) {
            $i++
            $Name = "${CurrentControlType}_$i"
        }
    }

    $Script:ControlHandler[$Name] = New-Object System.Windows.Forms.$CurrentControlType
    $Script:ControlHandler[$Name].Name = $Name
    Write-Verbose "$tabs$Plus$Space $('Name'.padright(18)) = '$($Name)'"
    # Construction des Properties
    foreach ($Key in $CurrentControlDef.Keys) {
        try {
            if (@('Name','Events','Childrens','ControlType') -notcontains $Key) {
                Write-Verbose "$Tabs$Plus$Space $($Key.padright(18)) = '$($CurrentControlDef.$Key)'"
                $Script:ControlHandler[$Name].$Key = $CurrentControlDef.$Key
                if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -and $isFirst -and $Key -eq 'Dock' -and $CurrentControlDef.$Key -ne 'Fill' -and @('Checkbox','InputBox') -notcontains $Children.ControlType) {
                    Write-Color ("         $tabs$Pass  $Last$Space ","Prefer @{Dock = 'Fill'} for the fisrt children and Top,Bottom,Left,Right for the following") -ForegroundColor yellow, Magenta
                }
            }
        } catch {
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
            $ValidProperties = $Script:ControlHandler[$Name].PSobject.Properties.Name -join(', ~') -split('~')
            Write-Host "[$Name] accepte only :" -ForegroundColor Red -NoNewline
            Write-Color $ValidProperties -ForeGroundColor Red,Magenta
        }
    }

    # Construction des Events
    if ($CurrentControlDef.Events.Keys){
        foreach ($Evt in $CurrentControlDef.Events.Keys) {
            try {
                Write-Verbose "$Tabs$Plus$Space Event.On_$($Evt)()"
                $Script:ControlHandler[$Name]."Add_$($Evt)"( $CurrentControlDef.Events.$Evt )
                # Write-LogStep 'Event',"On_$($Evt)" ok
            } catch {
                Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
                $ValidEvents = ($Script:ControlHandler[$Name].PSobject.Methods.Name | Where-Object {
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
                    [void]$Script:ControlHandler[$Name].DropDownItems.Add($Script:ControlHandler[$WinFormChildren.Name])
                } else {
                    Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Items.Add([$($Children.ControlType)].$($WinFormChildren.Name))"
                    [void]$Script:ControlHandler[$Name].Items.Add($Script:ControlHandler[$WinFormChildren.Name])
                }
            } elseif($Children.ControlType -eq 'ContextMenuStrip') {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].ContextMenuStrip = [$($Children.ControlType)].$($WinFormChildren.Name)"
                # [void]$Script:ControlHandler[$Name].Controls.Add($Script:ControlHandler[$WinFormChildren.Name])
                $Script:ControlHandler[$Name].ContextMenuStrip = $Script:ControlHandler[$WinFormChildren.Name]
            } elseif($Children.ControlType -eq 'MenuStrip') {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].MainMenuStrip = [$($Children.ControlType)].$($WinFormChildren.Name)"
                [void]$Script:ControlHandler[$Name].Controls.Add($Script:ControlHandler[$WinFormChildren.Name])
                $Script:ControlHandler[$Name].MainMenuStrip = $Script:ControlHandler[$WinFormChildren.Name]
            } elseif($Children.ControlType -match '^(ColumnHeader|DataGridView\w+Column)$') {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Columns = [$($Children.ControlType)].$($WinFormChildren.Name)"
                [void]$Script:ControlHandler[$Name].Columns.Add($Script:ControlHandler[$WinFormChildren.Name])
            # } elseif($Children.ControlType -eq 'SplitterPanel') {
            #     [void]$Script:ControlHandler[$Name]
            } else {
                Write-Verbose "$Pass  $tabs$Last$Space [$($CurrentControlDef.ControlType)].Controls.Add([$($Children.ControlType)].$($WinFormChildren.Name))"
                [void]$Script:ControlHandler[$Name].Controls.Add($WinFormChildren)
            }
            # Write-LogStep "[$($Children.ControlType)]",'' ok
        } catch {
            # $Children | Write-Object -fore red
            write-host "[$($CurrentControlDef.ControlType)]$Name.[$($Children.ControlType)]$($Children.Name)" -foreGroundColor red
            Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
        }
        $FirstChild = $false
    }

    # $Script:ControlHandler[$Name] | Write-Object -fore gray
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
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        Write-Host $ObjThis.name,$EventType -ForegroundColor Magenta
        # $ObjThis | Write-Object
    }
}
function Update-ListView {
    <#
        .SYNOPSIS
            Hydrate Une listView
        .DESCRIPTION
            [Descriptif en quelques lignes]
        .PARAMETER Items
            [PSCustomObject]@{
                    FirstColValue    = 'xyz'
                    NextValues  = 'xyz','xyz'
                    Group   = 'xyz'
                    Caption = 'Caption'
                    Status  = if((ping $_.IPv4Address -ports 0 -loop 1).status -ne '100%'){'Warn'} # defini la couleur si commance par : Warn, Info, Title
                    Shadow  = $false # gris clair
                }
        .EXAMPLE
            [PSCustomObject]@{
                    FirstColValue    = 'xyz'
                    NextValues  = 'xyz','xyz'
                    Group   = 'xyz'
                    Caption = 'Caption'
                    Status  = if((ping $_.IPv4Address -ports 0 -loop 1).status -ne '100%'){'Warn'} # defini la couleur si commance par : Warn, Info, Title
                    Shadow  = $false # gris clair
                } | Update-StdListView -listView $this
        .NOTES
        #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)] $Items = $null,
        $ListView
    )
    begin {
        # $ListView.BeginUpdate() # SuspendLayout()
    }
    process {
        foreach ($item in $items) {
            # $Item | Write-Object -PassThru -foreGroundColor Magenta
            if ($Item.FirstColValue) {
                try {
                    $NewLine = $ListView.items.Add("$($Item.FirstColValue)")
                    if ($Item.NextValues) {
                        $NewLine.SubItems.AddRange([string[]]$Item.NextValues) | out-null
                    }
                    # $NewLine.SubItems.AddRange("$($Item.Value)") | out-null
                    # $NewLine.SubItems.Add("$($Item.Detail)") | out-null
                    # $NewLine.group = $item.group
                    if ( $item.group ) {
                        $Grp = $ListView.Groups | Where-Object { $_.Header -like $Item.Group }
                        if (!$grp) {
                            $Grp = [System.Windows.Forms.ListViewGroup]@{ 'Header' = $Item.Group }
                            $ListView.Groups.Add($Grp)
                        }
                        $NewLine.group = $Grp
                    }

                    $NewLine.ToolTipText = "$($Item.Caption)"
                    if ($Item.Status -like 'Warn*' -or $Item.Caption -like "Warning`n*") { $NewLine.BackColor = 'LightSalmon' } # PeachPuff, LightSalmon, Tomato
                    elseif ($Item.Status -like 'Info*' -or $Item.Caption -like "Info`n*") { $NewLine.BackColor = 'MediumSpringGreen' } # NavajoWhite
                    elseif ($Item.Status -eq 'Title') { $NewLine.ForeColor = 'MidnightBlue' }
                    if ($Item.Shadow) { $NewLine.foreColor = [System.Drawing.Color]::Gray }
                } catch {
                    $item | Write-Object -back black -fore red
                    Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" '', $_ Error
                }
                # $l++
            }
            # Write-Object $item -backGroundColor Gray -fore Red
        }
    }
    end {
        $ListView.EndUpdate() # ResumeLayout()
        # Write-logstep $ListView.FirstColValue,"$l Line Added" ok
    }
}
function Set-ListViewSorted {
    <#
	.SYNOPSIS
		Sort the ListView's item using the specified column.
	.DESCRIPTION
		Sort the ListView's item using the specified column.
		This function uses Add-Type to define a class that sort the items.
		The ListView's Tag property is used to keep track of the sorting.
	.PARAMETER ListView
		The ListView control to sort.
	.PARAMETER ColumnIndex
		The index of the column to use for sorting.
	.PARAMETER SortOrder
		The direction to sort the items. If not specified or set to None, it will toggle.

	.EXAMPLE
		Sort-ListViewColumn -ListView $listview1 -ColumnIndex 0

	.NOTES
		SAPIEN Technologies, Inc.
		http://www.sapien.com/

#>
    param (
        [ValidateNotNull()]
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.ListView]$ListView,
        [Parameter(Mandatory = $true)]
        [int]$ColumnIndex,
        [System.Windows.Forms.SortOrder]$SortOrder = 'None'
    )

    if (($ListView.Items.Count -eq 0) -or ($ColumnIndex -lt 0) -or ($ColumnIndex -ge $ListView.Columns.Count)) {
        return;
    }

    #region Define ListViewItemComparer
    try {
        $local:type = [ListViewItemComparer]
    } catch {
        Add-Type -ReferencedAssemblies ('System.Windows.Forms') -TypeDefinition  @"
	using System;
	using System.Windows.Forms;
	using System.Collections;
	public class ListViewItemComparer : IComparer
	{
	    public int column;
	    public SortOrder sortOrder;
	    public ListViewItemComparer()
	    {
	        column = 0;
			sortOrder = SortOrder.Ascending;
	    }
	    public ListViewItemComparer(int column, SortOrder sort)
	    {
	        this.column = column;
			sortOrder = sort;
	    }
	    public int Compare(object x, object y)
	    {
			if(column >= ((ListViewItem)x).SubItems.Count)
				return  sortOrder == SortOrder.Ascending ? -1 : 1;

			if(column >= ((ListViewItem)y).SubItems.Count)
				return sortOrder == SortOrder.Ascending ? 1 : -1;

			if(sortOrder == SortOrder.Ascending)
	        	return String.Compare(((ListViewItem)x).SubItems[column].Text, ((ListViewItem)y).SubItems[column].Text);
			else
				return String.Compare(((ListViewItem)y).SubItems[column].Text, ((ListViewItem)x).SubItems[column].Text);
	    }
	}
"@ | Out-Null
    }
    #endregion

    if ($ListView.Tag -is [ListViewItemComparer]) {
        #Toggle the Sort Order
        if ($SortOrder -eq [System.Windows.Forms.SortOrder]::None) {
            if ($ListView.Tag.column -eq $ColumnIndex -and $ListView.Tag.sortOrder -eq 'Ascending') {
                $ListView.Tag.sortOrder = 'Descending'
            }
            else {
                $ListView.Tag.sortOrder = 'Ascending'
            }
        }
        else {
            $ListView.Tag.sortOrder = $SortOrder
        }

        $ListView.Tag.column = $ColumnIndex
        $ListView.Sort()#Sort the items
    }
    else {
        if ($Sort -eq [System.Windows.Forms.SortOrder]::None) {
            $Sort = [System.Windows.Forms.SortOrder]::Ascending
        }

        #Set to Tag because for some reason in PowerShell ListViewItemSorter prop returns null
        $ListView.Tag = New-Object ListViewItemComparer ($ColumnIndex, $SortOrder)
        $ListView.ListViewItemSorter = $ListView.Tag #Automatically sorts
    }
}