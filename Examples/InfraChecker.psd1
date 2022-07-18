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
            $Script:consolePtr = [Console.Window]::GetConsoleWindow()
            if (!$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
                [Console.Window]::ShowWindow($Script:consolePtr,0) | Out-Null
            }
        }
        Activated    = @{
            Type='Thread'
            ScriptBlock=$Global:MainTabsScriptBlock
        }
        KeyDown = [Scriptblock]{ # Event
            Invoke-EventTracer $this 'KeyDown'
            if ($_.KeyCode -eq 'Escape') {
                $this.Close()
            }
        }
        Closing = [Scriptblock]{ # Event
            Invoke-EventTracer $this 'Closing'
            # Get-Job | ?{$_.Name -like 'PSWinForm_*'} | Remove-Job -Force
            if ($Script:consolePtr) {
                [Console.Window]::ShowWindow($Script:consolePtr,5) | Out-Null
            }
        }
    }
    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
        @{  ControlType = 'TabControl'
            Name        = 'TabsRessources'
            Dock        = 'Fill'
            Enabled     = $True
            Events      =  @{
                SelectedIndexChanged = @{
                    Type = 'Thread'
                    ScriptBlock = $Global:MainTabsScriptBlock
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
                                    start-threadJob -Name "PSWinForm_$IP" {
                                        param($IP,$Ports,$Intervale,$icmpSize)
                                        Import-Module PSBright -function ping
                                        Ping $IP -ports $Ports -intervale $Intervale -size $icmpSize | Out-GridView -Title "Ping $IP -port $ports -intervele $intervale -size $icmpSize"
                                    } -ArgumentList @($this.focusedItem.SubItems[0].text,(Get-Port2Ping),(Get-ComboBoxValue 'ComboBox_Speed' 2000),(Get-ComboBoxValue 'ComboBox_Charge' 32))
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
                                    start-threadJob -Name "PSWinForm_$IP" {
                                        param($IP,$Ports,$Intervale,$icmpSize)
                                        Import-Module PSBright -function ping
                                        Ping $IP -ports $Ports -intervale $Intervale -size $icmpSize | Out-GridView -Title "Ping $IP -port $ports -intervele $intervale -size $icmpSize"
                                    } -ArgumentList @($this.focusedItem.SubItems[0].text,(Get-Port2Ping),(Get-ComboBoxValue 'ComboBox_Speed' 2000),(Get-ComboBoxValue 'ComboBox_Charge' 32))
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
                                    start-threadJob -Name "PSWinForm_$IP" {
                                        param($IP,$Ports,$Intervale,$icmpSize)
                                        Import-Module PSBright -function ping
                                        Ping $IP -ports $Ports -intervale $Intervale -size $icmpSize | Out-GridView -Title "Ping $IP -port $ports -intervele $intervale -size $icmpSize"
                                    } -ArgumentList @($this.focusedItem.SubItems[0].text,(Get-Port2Ping),(Get-ComboBoxValue 'ComboBox_Speed' 2000),(Get-ComboBoxValue 'ComboBox_Charge' 32))
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
        @{  ControlType = 'TabControl'
            Dock        = 'Bottom'
            Height      = 150
            Events      = @{
            }
            Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                @{  ControlType = 'TabPage'
                    Name        = 'OptionsPing'
                    Text        = 'Options du Ping'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'Checkbox'
                            Name        = 'Checkbox_Refresh'
                            Text        = "Rafrechir la liste a chaque changement d'onglet"
                            Dock        = 'Fill'
                            Checked     = $True
                            Events      = @{}
                        },
                        @{  ControlType = 'ComboBox'
                            Name        = 'ComboBox_Speed'
                            Dock        = 'Top'
                            Items       = @(250,500,1000,2000,4000,10000)
                            SelectedIndex = 4
                            Events      = @{}
                        },
                        @{  ControlType = 'label'
                            Text        = 'Ping Intervale (ms)'
                            Dock        = 'Top'
                        },
                        @{  ControlType = 'ComboBox'
                            Name        = 'ComboBox_Charge'
                            Dock        = 'Top'
                            Items       = @(32,256,1024,4096,8192,16384,32768,65536)
                            SelectedIndex = 0
                            Events      = @{}
                        },
                        @{  ControlType = 'label'
                            Text        = 'Charge ICMP (Octets)'
                            Dock        = 'Top'
                        }
                    )
                },
                @{  ControlType = 'TabPage'
                    Name        = 'PortsPing'
                    Text        = 'Ports du Ping'
                    Dock        = 'Fill'
                    Events      = @{}
                    Childrens   = @( # FirstControl need {Dock = 'Fill'} but the following will be [Top, Bottom, Left, Right]
                        @{  ControlType = 'Panel'
                            Dock        = 'Fill'
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
                                    Text        = 'SSH (22), souvent ouvert sur les equipements linux'
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
                                    Text        = "JetDirect (9100), flux d'impression sur les imprimante et copieurs"
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
            )
        }
    )
}