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
            [Console.Window]::ShowWindow($consolePtr,0) | Out-Null
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
                    $this.SelectedTab.Name
                }
            }
            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                @{  ControlType = 'TabPage'
                    # Name        = 'TabPage'
                    Text        = 'Tab1'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'ListView'
                            Name             = 'ListView_1'
                            Dock             = 'Fill'
                            Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            HoverSelection   = 'True'
                            ShowGroups       = 'True'
                            ShowItemToolTips = 'True'
                            View             = 'Details'
                            Events      = @{
                                Enter    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'Enter'
                                    1..9 | %{
                                        [PSCustomObject]@{
                                            FirstColValue = (Get-Random 100)
                                            NextValues = (Get-Random 'Value1', 'Value2', 'Value0','Value3'),(Get-Random 'Value1', 'Value2', 'Value0','Value3')
                                            Group   = (Get-Random 'Grp1', 'Grp2', 'Grp0','')
                                            Caption = 'Caption '
                                            Status  = (Get-Random 'Warn', 'Info', 'Title','')
                                            Shadow  = (Get-Random $true, $false) # gris clair
                                        }
                                    } | Update-ListView -listView $this
                                    
                                }
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
                    # Name        = 'TabPage'
                    Text        = 'Tab2'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'ListView'
                            Name             = 'ListView_2'
                            Dock             = 'Fill'
                            Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            HoverSelection   = 'True'
                            ShowGroups       = 'True'
                            ShowItemToolTips = 'True'
                            View             = 'Details'
                            Events      = @{
                                Enter    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'Enter'
                                    1..9 | %{
                                        [PSCustomObject]@{
                                            FirstColValue = (Get-Random 100)
                                            NextValues = (Get-Random 'Value1', 'Value2', 'Value0','Value3'),(Get-Random 'Value1', 'Value2', 'Value0','Value3')
                                            Group   = (Get-Random 'Grp1', 'Grp2', 'Grp0','')
                                            Caption = 'Caption '
                                            Status  = (Get-Random 'Warn', 'Info', 'Title','')
                                            Shadow  = (Get-Random $true, $false) # gris clair
                                        }
                                    } | Update-ListView -listView $this
                                    
                                }
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
                    # Name        = 'TabPage'
                    Text        = 'Tab3'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'ListView'
                            Name             = 'ListView_3'
                            Dock             = 'top'
                            Activation       = 'OneClick'
                            FullRowSelect    = 'True'
                            HoverSelection   = 'True'
                            ShowGroups       = 'True'
                            ShowItemToolTips = 'True'
                            View             = 'Details'
                            Events      = @{
                                Enter    = [Scriptblock]{ # Event
                                    Invoke-EventTracer $this 'Enter'
                                    1..9 | %{
                                        [PSCustomObject]@{
                                            FirstColValue = (Get-Random 100)
                                            NextValues = (Get-Random 'Value1', 'Value2', 'Value0','Value3'),(Get-Random 'Value1', 'Value2', 'Value0','Value3')
                                            Group   = (Get-Random 'Grp1', 'Grp2', 'Grp0','')
                                            Caption = 'Caption '
                                            Status  = (Get-Random 'Warn', 'Info', 'Title','')
                                            Shadow  = (Get-Random $true, $false) # gris clair
                                        }
                                    } | Update-ListView -listView $this
                                    
                                }
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
                    Name        = 'Checkbox_label'
                    Text        = 'label'
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