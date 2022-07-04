@{  ControlType = 'Form'
    # Name        = 'MainFor $true
    Size        = '360, 480'
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
            Get-DnsByName -prefix 'RT-' | Update-ListView -listView $Script:ControlHandler['Routers_LV']
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
            Dock        = 'Fill'
            Enabled     = $True
            Events      = @{
                SelectedIndexChanged = [Scriptblock]{ # Event
                    Invoke-EventTracer $this 'SelectedIndexChanged'
                    Write-Verbose $this.SelectedTab.Name
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
                            Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            HoverSelection   = 'True'
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
                                }
                            }
                            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col1'
                                    Width        = 140
                                },
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col2'
                                    Width        = 120
                                }
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col3'
                                    Width        = 150
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
                            Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            HoverSelection   = 'True'
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
                                }
                            }
                            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col1'
                                    Width        = 140
                                },
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col2'
                                    Width        = 120
                                }
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col3'
                                    Width        = 150
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
                            Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            HoverSelection   = 'True'
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
                                }
                            }
                            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col1'
                                    Width        = 140
                                },
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col2'
                                    Width        = 120
                                }
                                @{
                                    ControlType = 'ColumnHeader'
                                    Text        = 'Col3'
                                    Width        = 150
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
            Events      = @{}
            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                @{  ControlType = 'Checkbox'
                    Name        = 'Checkbox_ICMP'
                    Text        = 'ICMP'
                    Dock        = 'Top'
                    Events      = @{
                        CheckedChanged    = [Scriptblock]{ # Event
                            Invoke-EventTracer $this 'CheckedChanged'
                        }
                    }
                },
                @{  ControlType = 'Checkbox'
                    Name        = 'Checkbox_RDP'
                    Text        = 'RDP'
                    Dock        = 'Top'
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