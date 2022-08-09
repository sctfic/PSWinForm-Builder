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

function Update-TreeView {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)] $Items = $null,
        $treeNode,
        [scriptblock]$ChildrenScriptBlock = $null,
        $Depth = 1,
        [switch]$Clear,
        [switch]$Expand
    )
    begin {
        if ($Clear) {
            $treeNode.Nodes.Clear()
        }
    }
    process {
        foreach($item in $Items){
            try {
                # Write-Color $Item.Name,' - ',$Item.Handler -ForeGroundColor Cyan,Yellow,Magenta
                $childNode = [System.Windows.Forms.TreeNode]@{
                    'Text'        = $(if($Item.Name) {$Item.Name} else {$Item})
                    'Tag'         = $(if($Item.Handler) {$Item.Handler} else {$null})
                    'ForeColor'   = $(if($Item.ForeColor -is [system.Drawing.Color]) {$Item.ForeColor} else {[system.Drawing.Color]::Black})
                    'BackColor'   = $(if($Item.BackColor -is [system.Drawing.Color]) {$Item.BackColor} else {[system.Drawing.Color]::White})
                    'ToolTipText' = $(if($Item.Infos) {$Item.Infos} elseif($Item.Handler) {$Item.Handler} else {$null})
                }
                [System.Void]$treeNode.Nodes.Add($childNode)
            } catch {
                Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
            }
            if ($depth -gt 0 -and $ChildrenScriptBlock) {
                # Write-Object $item -fore Blue
                Invoke-Command -ScriptBlock $ChildrenScriptBlock -ArgumentList $item -ea SilentlyContinue | Update-TreeView -treeNode $childNode -ChildrenScriptBlock $ChildrenScriptBlock -Depth ($Depth-1)
            }
        }
    }
    end {
        if ($expand) {
            try {
                $treeNode.ExpandAll()
            } catch {
                Write-LogStep -prefix "L.$($_.InvocationInfo.ScriptLineNumber)" "", $_ error
            }
        }
        $treeNode
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
function Get-CheckBoxValue {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $checkBoxName
    )
    process {
        if( $Global:ControlHandler[$checkBoxName].Checked) {
            # Write-Color $checkBoxName,$Global:ControlHandler[$checkBoxName].Tag -ForegroundColor DarkMagenta,DarkYellow
            return $Global:ControlHandler[$checkBoxName].Tag
        }
    }
}
function Get-TextBoxValue {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $textBoxName
    )
    process {
        if($Global:ControlHandler[$textBoxName].Text -ne '') {
            # Write-Color $textBoxName,$Global:ControlHandler[$textBoxName].Text -ForegroundColor DarkRed,DarkCyan
            return $Global:ControlHandler[$textBoxName].Text
        }
    }
}
function Invoke-EventTracer {
    param (
        $ObjThis,
        $EventType
    )
    if ($Global:Verbose) {
        if (!$ObjThis.name) {
            Write-Host $ObjThis,$EventType -ForegroundColor Magenta
        } else {
            Write-Host $ObjThis.name,$EventType -ForegroundColor Magenta
        }
    }
}
function Write-Verbose {
    param (
        [string[]]$msg,
        [ConsoleColor]$foreGroundColor = 'DarkYellow',
        [ConsoleColor]$backGroundColor = 'Black'
    )
    if ($Global:Verbose) {
        Write-Host $msg -ForegroundColor $foreGroundColor -BackgroundColor $backGroundColor
    }
}


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
