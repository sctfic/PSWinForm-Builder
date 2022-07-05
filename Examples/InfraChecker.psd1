@{  ControlType = 'Form'
    # Name        = 'MainFor $true
    Size        = '480, 640'
    KeyPreview = $true
    # Icon        = [System.Drawing.Icon] [System.IO.MemoryStream] [System.Convert]::FromBase64String('')
    Events      = @{
        Load    = [Scriptblock]{ # Event
            Invoke-EventTracer $this 'Load'
            if (-not ('Console.Window' -as [type])) {
                Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")]public static extern IntPtr GetConsoleWindow();[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
            }
            $consolePtr = [Console.Window]::GetConsoleWindow()
            if (!$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
                [Console.Window]::ShowWindow($consolePtr,0) | Out-Null
            }
        }
        Activated    = @{
            Type='Thread'
            ScriptBlock={
                param($Caller, $e)
                function Write-Host {
                    # Wrapper for Write-Host in threads
                    param(
                        $object,
                        [ConsoleColor]$foregroundColor,
                        [ConsoleColor]$backgroundColor,
                        [switch]$nonewline
                    )
                    if ($foregroundColor) {
                        [Console]::ForegroundColor = $foregroundColor
                    }
                    elseif ($backgroundColor) {
                        [Console]::BackgroundColor = $backgroundColor
                    }
                    [Console]::Write($object -join (', ')) | Out-Null
                    if (!$nonewline) { [Console]::Write( "`n" ) | Out-Null }
                    [Console]::ResetColor() | Out-Null
                }
                Write-Host 'ThreadEventHandler' -backgroundColor Magenta 
                Write-Host 'ThreadEventHandler',$caller.name -backgroundColor Magenta 

        #         Invoke-EventTracer $this 'Activated'
        #         $Tabs = $Script:ControlHandler['TabsRessources']
        #         $Script:ControlHandler["$($Tabs.SelectedTab.Name)_LV"].Items.Clear()
        #         $Script:ControlHandler["Loading"].Visible = $true
        #         $(switch ($Tabs.SelectedTab.Name) {
        #             'Routers' {
        #                 Get-DnsByName -prefix 'RT-'
        #             }
        #             'Switchs' {
        #                 Get-DnsByName -prefix 'SW-'
        #             }
        #             'Servers' {
        #                 Get-DnsBySamAccountName -prefix 'SRV-'
        #             }
        #             default {}
        #         }) | Update-ListView -listView $Script:ControlHandler["$($Tabs.SelectedTab.Name)_LV"]
        #         $Script:ControlHandler["Loading"].Visible = $false
            }
        }
        KeyDown = [Scriptblock]{ # Event
            Invoke-EventTracer $this 'KeyDown'
            if ($_.KeyCode -eq 'Escape') {
                $this.Close()
            }
        }
        Closing = [Scriptblock]{ # Event
            Invoke-EventTracer $this 'Closing'
            [Console.Window]::ShowWindow($consolePtr,5) | Out-Null
        }
    }
    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
        @{  ControlType = 'TabControl'
            Name        = 'TabsRessources'
            Dock        = 'Fill'
            Enabled     = $True
            Events      = @{
                SelectedIndexChanged = [Scriptblock]{ # Event
                    Invoke-EventTracer $this 'SelectedIndexChanged'
                    $Script:ControlHandler["$($this.SelectedTab.Name)_LV"].Items.Clear()
                    $Script:ControlHandler["Loading"].Visible = $true
                    $(switch ($this.SelectedTab.Name) {
                        'Routers' {
                            Get-DnsByName -prefix 'RT-'
                        }
                        'Switchs' {
                            Get-DnsByName -prefix 'SW-'
                        }
                        'Servers' {
                            Get-DnsBySamAccountName -prefix 'SRV-'
                        }
                        default {}
                    }) | Update-ListView -listView $Script:ControlHandler["$($this.SelectedTab.Name)_LV"]
                    $Script:ControlHandler["Loading"].Visible = $false
                }
            }
            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                @{  ControlType = 'TabPage'
                    Name        = 'Routers'
                    Text        = 'Routers'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'ListView'
                            Name             = 'Routers_LV'
                            Dock             = 'Fill'
                            # Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            # HoverSelection   = 'True'
                            ShowGroups       = 'True'
                            ShowItemToolTips = 'True'
                            View             = 'Details'
                            Events      = @{
                                ColumnClick    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'ColumnClick'
                                    Set-ListViewSorted  -listView $this -column $_.Column
                                }
                                Click    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'Click' # left and right but not on empty area
                                }
                                DoubleClick    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'DoubleClick'
                                    Invoke-Expression "pwsh -NoProfile -NoLogo -Command 'ipmo PSBright -function ping; Ping $($this.focusedItem.SubItems[1].text) -ports @($(Get-Port2Ping -verbose)) | Out-GridView'"
                                }
                            }
                            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'HostName'
                                    Width        = 270
                                },
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'IpAddress'
                                    Width        = 110
                                }
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Time ICMP'
                                    Width        = 50
                                }
                            )
                        }
                    )
                },
                @{  ControlType = 'TabPage'
                    Name        = 'Switchs'
                    Text        = 'Switchs'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'ListView'
                            Name             = 'Switchs_LV'
                            Dock             = 'Fill'
                            # Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            # HoverSelection   = 'True'
                            ShowGroups       = 'True'
                            ShowItemToolTips = 'True'
                            View             = 'Details'
                            Events      = @{
                                ColumnClick    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'ColumnClick'
                                    Set-ListViewSorted  -listView $this -column $_.Column
                                }
                                Click    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'Click' # left and right but not on empty area
                                }
                                DoubleClick    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'DoubleClick'
                                    Invoke-Expression "pwsh -NoProfile -NoLogo -Command 'ipmo PSBright -function ping; Ping $($this.focusedItem.SubItems[1].text) -ports @($(Get-Port2Ping -verbose)) | Out-GridView'"
                                }
                            }
                            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'HostName'
                                    Width        = 270
                                },
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'IpAddress'
                                    Width        = 110
                                }
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Time ICMP'
                                    Width        = 50
                                }
                            )
                        }
                    )
                },
                @{  ControlType = 'TabPage'
                    Name        = 'Servers'
                    Text        = 'Servers'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'ListView'
                            Name             = 'Servers_LV'
                            Dock             = 'Fill'
                            # Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            # HoverSelection   = 'True'
                            ShowGroups       = 'True'
                            ShowItemToolTips = 'True'
                            View             = 'Details'
                            Events      = @{
                                ColumnClick    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'ColumnClick'
                                    Set-ListViewSorted  -listView $this -column $_.Column
                                }
                                Click    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'Click' # left and right but not on empty area
                                }
                                DoubleClick    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'DoubleClick'
                                    Invoke-Expression "pwsh -NoProfile -NoLogo -Command 'ipmo PSBright -function ping; Ping $($this.focusedItem.SubItems[1].text) -ports @($(Get-Port2Ping -verbose)) | Out-GridView'"
                                }
                            }
                            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'HostName'
                                    Width        = 270
                                },
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'IpAddress'
                                    Width        = 110
                                }
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Time ICMP'
                                    Width        = 50
                                }
                            )
                        }
                    )
                }
            )
        },
        @{  ControlType = 'ProgressBar'
            Name        = 'Loading'
            Style       = 'Marquee'
            Dock        = 'Top'
            Height      = 5
        },
        @{  ControlType = 'Splitter'
            Dock        = 'Bottom' # 
            Events      = @{
                Enter    = [Scriptblock]{ # Event
                    Invoke-EventTracer $this 'Enter'
                }
            }
        },
        @{  ControlType = 'GroupBox'
            Text        = 'Option'
            Dock        = 'Bottom'
            Height      = 150
            Events      = @{}
            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                @{  ControlType = 'Panel'
                    Dock        = 'Top'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'Label'
                            Text        = 'OtherPorts'
                            Dock        = 'Fill'
                        },
                        @{  ControlType = 'TextBox'
                            Name        = 'TextBox_OtherPorts'
                            Dock        = 'Right'
                            Events      = @{
                                TextChanged    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'TextChanged'
                                }
                            }
                        }
                    )
                },
                @{  ControlType = 'Checkbox'
                    Name        = 'Checkbox_SSH'
                    Text        = 'SSH (22), souvent ouvert sur les equipement linux'
                    Tag         = 22
                    Dock        = 'Top'
                    Events      = @{
                        CheckedChanged    = [Scriptblock]{ # Event
                            Invoke-EventTracer $this 'CheckedChanged'
                        }
                    }
                },
                @{  ControlType = 'Checkbox'
                    Name        = 'Checkbox_RDP'
                    Text        = 'RDP (3389), ouvert sur les serveur Windows, parfois sur les postes client'
                    Tag         = 3389
                    Dock        = 'Top'
                    Events      = @{
                        CheckedChanged    = [Scriptblock]{ # Event
                            Invoke-EventTracer $this 'CheckedChanged'
                        }
                    }
                },
                @{  ControlType = 'Checkbox'
                    Name        = 'Checkbox_JetDirect'
                    Text        = "JetDirect (9100), flux d'impression sur les copieurs"
                    Tag         = 9100
                    Dock        = 'Top'
                    Events      = @{
                        CheckedChanged    = [Scriptblock]{ # Event
                            Invoke-EventTracer $this 'CheckedChanged'
                        }
                    }
                },
                @{  ControlType = 'Checkbox'
                    Name        = 'Checkbox_ICMP'
                    Text        = 'ICMP, canal pour le Protocole de Controle Internet'
                    Tag         = 0
                    Dock        = 'Top'
                    Checked     = $True
                    Events      = @{
                        CheckedChanged    = [Scriptblock]{ # Event
                            Invoke-EventTracer $this 'CheckedChanged'
                        }
                    }
                }
            )
        }
    )
}