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
            ScriptBlock=[Scriptblock]{
                param($ControlHandler, $ControllerName, $EventName)
                # Invoke-EventTracer $ControllerName, "$ControllerName-$EventName"
                $Tabs = $ControlHandler['TabsRessources']
                $ListView = $($ControlHandler["$($Tabs.SelectedTab.Name)_LV"])
                $listview.tag = $(Get-Date)
                Invoke-EventTracer $Tabs.SelectedTab.Name $EventName
                $ListView.Items.Clear()
                $ControlHandler["Loading"].Visible = $true
                $(switch ($Tabs.SelectedTab.Name) {
                    'Routers' {
                        Get-DnsByName -prefix 'RT-'
                    }
                    'Switchs' {
                        Get-DnsByName -prefix 'SW-'
                    }
                    'Servers' {
                        Get-DnsByName -prefix 'SRV-'
                    }
                    default {}
                }) | Update-ListView -listView $ListView
                $ControlHandler["Loading"].Visible = $false
                # 1..30 | %{
                #     Start-Sleep -m 100
                #     Write-Host '.',"$ControllerName-$EventName" -fore Cyan -NoNewline
                # }
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
                    ScriptBlock = [Scriptblock]{
                        param($ControlHandler, $ControllerName, $EventName)
                        $Tabs = $ControlHandler[$ControllerName]
                        $ListView = $($ControlHandler["$($Tabs.SelectedTab.Name)_LV"])
                        # write-host  $listview.tag -fore Red
                        if (!$listview.tag -or (get-date $listview.tag) -lt (get-date).AddMinutes(-1)) {
                            $listview.tag = $(Get-Date)
                            Invoke-EventTracer $Tabs.SelectedTab.Name $EventName
                            $ListView.Items.Clear()
                            $ControlHandler["Loading"].Visible = $true
                            $(switch ($Tabs.SelectedTab.Name) {
                                'Routers' {
                                    Get-DnsByName -prefix 'RT-'
                                }
                                'Switchs' {
                                    Get-DnsByName -prefix 'SW-'
                                }
                                'Servers' {
                                    Get-DnsByName -prefix 'SRV-'
                                }
                                default {}
                            }) | Update-ListView -listView $ListView
                        }
                        $ControlHandler["Loading"].Visible = $false
                    }
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
                                        param($IP,$Ports)
                                        Import-Module PSBright -function ping
                                        Ping $IP -ports $Ports | Out-GridView
                                    } -ArgumentList @($this.focusedItem.SubItems[1].text,(Get-Port2Ping))
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
                                        param($IP,$Ports)
                                        Import-Module PSBright -function ping
                                        Ping $IP -ports $Ports | Out-GridView
                                    } -ArgumentList @($this.focusedItem.SubItems[1].text,(Get-Port2Ping))
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
                                        param($IP,$Ports)
                                        Import-Module PSBright -function ping
                                        Ping $IP -ports $Ports | Out-GridView
                                    } -ArgumentList @($this.focusedItem.SubItems[1].text,(Get-Port2Ping))
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