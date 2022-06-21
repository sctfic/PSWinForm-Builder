@{
    Name            = 'Demo2Form'
    Text            = 'AD Users'
    TopMost         = $true
    Width           = 360
    Height          = 480
    Anchor          = 'Right,Top'
    KeyPreview      = $true
    AutoSize        = $False
    MaximizeBox     = $False
    MinimizeBox     = $False
    ControlBox      = $True # $True or $False to show close icon on top right corner
    FormBorderStyle = 'FixedSingle' # Fixed3D, FixedDialog, FixedSingle, Sizable, None, FixedToolWindow, SizableToolWindow
    # Form Events (function must defined in calling script)
    Events          = @{
        Load = [Scriptblock]{
            Invoke-EventTracer $this $this.Name
        }
        KeyDown = [Scriptblock]{
            Invoke-EventTracer $this $this.Name
            if ($_.KeyCode -eq 'Escape') {
                $this.Close()
            }
        }
    }
    Childrens        = @(
        @{
            ControlType = 'GroupBox'
            Name     = 'Gbx0'
            Text     = 'GroupBox'
            Dock     = "Fill"
            Events   = @{
                Click = [Scriptblock]{
                    Invoke-EventTracer $this $this.Name 
                }
            }
            Childrens = @(
                @{
                    ControlType = 'Textbox'
                    Name   = 'Tbx0'
                    Dock   = "Fill"
                    Events = @{
                        Click = [Scriptblock]{
                            Invoke-EventTracer $this $this.Name 
                        }
                    }
                }
                @{
                    ControlType = 'GroupBox'
                    Name     = 'Gbx0'
                    Text     = 'GroupBox'
                    Dock     = "Fill"
                    Events   = @{
                        Click = [Scriptblock]{
                            Invoke-EventTracer $this $this.Name 
                        }
                    }
                    Childrens = @(
                        @{
                            ControlType = 'Textbox'
                            Name   = 'Tbx0'
                            Dock   = "Fill"
                            Events = @{
                                Click = [Scriptblock]{
                                    Invoke-EventTracer $this $this.Name 
                                }
                            }
                        }
                        @{
                            ControlType = 'Textbox'
                            Name   = 'Tbx1'
                            Dock   = "top"
                            Events = @{
                                Click = [Scriptblock]{
                                    Invoke-EventTracer $this $this.Name 
                                }
                            }
                        }
                    )
                }
                @{
                    ControlType = 'Textbox'
                    Name   = 'Tbx1'
                    Dock   = "top"
                    Events = @{
                        Click = [Scriptblock]{
                            Invoke-EventTracer $this $this.Name 
                        }
                    }
                }
            )
        }
        @{
            ControlType = 'Textbox'
            Name   = 'Tbx2'
            Dock   = "top"
            Events = @{
                Click = [Scriptblock]{
                    Invoke-EventTracer $this $this.Name 
                }
            }
        }
    )
}