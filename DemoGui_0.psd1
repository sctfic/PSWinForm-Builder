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
    Icon            = [System.Drawing.Icon][System.IO.MemoryStream] [System.Convert]::FromBase64String('AAABAAEALUAQAAEABABoCAAAFgAAACgAAAAtAAAAgAAAAAEABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWFxsAHh8jACkqLQA4ODwARkZJAFRVWABkZGcAc3R3AIGChQCRkpUAo6WnALW2uQDGyMsA4eLlAPj5+gAAAAAA//////////////////////////////AA////////////////////////f/////AA////////////////////////+f////AA////93//////////////////h/////AA/////0b6///////////////79f////AA/////2KPb/////////////+hEa////AA//////Rf9//////////////2QP////AA//////gGxI/P//////////90MY////AA//////8i+D/5///////////4IU////AA//////9xfwf4f/////////9nYS////AA///////wOQL/b//////////yEQn///AA//////9xFhF/dt////////+rIR////AA///////xERE/8v////////o0IQX///AA//////9REREPkD////////+RERr///AA//////lBEREV8Qn///////b1ERn///AA///////GERESQRO//////9cBERn//6AA///////2ARERERH////////xERn/9/AA///////2ERERERFP/////2VREQ//c4AA///////xEREREREJ//////EREQj/8XAA/////4UBEhEREREX////j8YRER//MUAA//////EREREREREU////9PcxEU/3gjAA////+RERESIRERERf///9RAREX//gSAA////8hERE/YBERER///3/0EREP/3USAA////UREQf/9BERIRf//4BWERE7+5UTAA///2ESEW///yERERL/r/QRERFf/1IUAA//+SERGP///4ERERD/hfkRERD/9ZEXAA//9RERr/////YRERF/sBYRERb/+BEYAA//8REJ//////ghEREH9BERERn7+2EIAA//URCf//////9hEREReBEREG//gCEvAA/5MRb////////0EREREhERFP/2lRFPAA//AW//////////IREREREhL/+fERB/AA/3E///////////gBESEREQj/xoURP/AA/2H///////////9REREREf/09wER//AA/6e///+fYj////9xERERBv9RFREUn/AA//////YwERj////xERER//YBEREY//AA////dRERERKP//9yAREm/8MRERFv//AA///2ERERERFv///zEhP///YREQT///AA//8jZgERERFf//+SEl////8BEl////AA//Kt7oERERfo///xSf////8hJ/////AA+F3u7qERERvpz/+vj/////82r/////AA9N7u7UERERrr//////////////////AAjO7u5xERERjsn/////////////////AAfu7ugBERERPb//////////////////AAfe7XERERERGXr/////////////////AA9ZlRERERAAAp//////////////////AA/5h2Ylkzn6/P//////////////////AA////9G9y//////////////////////AA////g69hf/////////////////////AA////8v/y//////////////////////AA////Ym/Eb/////////////////////AA////8//5L/////////////////////AA////k5//Kf////////////////////AA////9f//9P////////////////////AA////1H//84////////////////////AA////9P//+U////////////////////AA////95///2f///////////////////AA////9/////X///////////////////AA/////1////9f//////////////////AA/////3/////2//////////////////AA/////2//////b/////////////////AA////////////+P////////////////AA/////////////5/v//////////////AA//////r///////////////////////AA///////P//////////////////////AA///////4AAD/////9/gAAP/////7+AAA/n////P4AAD/L///6/gAAP8X///B+AAA/5v//+P4AAD/gX//wfgAAP/Jv//h+AAA/8Sf/8H4AAD/4N//4PgAAP/AR//B+AAA/+Bv/4D4AAD/wEf/wPgAAP+AI/+g+AAA/8AB/wDwAAD/4AP/4OgAAP/gAf8BwAAA/+AA/4DgAAD/AAD9AcAAAP+AAP6BgAAA/gAAfgHAAAD+AgD7A4AAAPwHAHgBAAAA+A+AbAOAAADwH4BkBwAAAPA/wCAHAAAA8H/AEAUAAADg/+AADggAAMH/8AAcCAAA4//4ADoIAADH//gAMBgAAM///ADoOAAAx9H8AMAYAAD/gP4DgDgAAPwAfAMAeAAA+AB+D4D4AADwAHwfwfgAAOAAPj/D+AAAgAAdf8f4AACAAD////gAAAAAH///+AAAAAA////4AAAAAB////gAAIAAP///+AAAwAV////4AAD+T/////gAAPxH////+AAA/u/////4AAD8R/////gAAP7n////+AAA/HP////4AAD++/////gAAPx5////+AAA/vn////4AAD+fP////gAAP7+////+AAA/39////4AAD/f7////gAAP9/3///+AAA///v///4AAD///X///gAAP+/////+AAA/9/////4AAA=')
    # Icon            = [System.Drawing.Icon][System.IO.MemoryStream] [System.Convert]::FromBase64String('AAABAAEAAQEAAAEAIAAwAAAAFgAAACgAAAABAAAAAgAAAAEAIAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//AAAAAA==') 
    # Icon            = [System.Drawing.Icon][System.IO.MemoryStream] [System.Convert]::FromBase64String('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') 
    # Form Events (function must defined in calling script)
    Events          = @{
        Load = [Scriptblock]{
            Invoke-EventTracer $this 'Load'
        }
        KeyDown = [Scriptblock]{
            Invoke-EventTracer $this 'KeyDown'
            if ($_.KeyCode -eq 'Escape') {
                $this.Close()
            }
        }
    }
    Childrens        = @(
        @{
            ControlType = 'GroupBox'
            # Name     = 'Gbx0'
            Text     = 'GroupBox'
            Dock     = "Fill"
            Events   = @{
                Click = [Scriptblock]{
                    Invoke-EventTracer $this 'Click'
                }
            }
            Childrens = @(
                @{
                    ControlType = 'Textbox'
                    # Name   = 'Tbx0'
                    Dock   = "Fill"
                    Events = @{
                        Click = [Scriptblock]{
                            Invoke-EventTracer $this 'Click'
                        }
                    }
                }
                @{
                    ControlType = 'GroupBox'
                    # Name     = 'Gbx0'
                    Text     = 'GroupBox'
                    Dock     = "Fill"
                    Events   = @{
                        Click = [Scriptblock]{
                            Invoke-EventTracer $this 'Click'
                        }
                    }
                    Childrens = @(
                        @{
                            ControlType = 'Textbox'
                            # Name   = 'Tbx0'
                            Dock   = "Fill"
                            Events = @{
                                Click = [Scriptblock]{
                                    Invoke-EventTracer $this 'Click'
                                }
                            }
                        }
                        @{
                            ControlType = 'Textbox'
                            # Name   = 'Tbx1'
                            Dock   = "top"
                            Events = @{
                                Click = [Scriptblock]{
                                    Invoke-EventTracer $this 'Click'
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
                            Invoke-EventTracer $this 'Click'
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
                    Invoke-EventTracer $this 'Click'
                }
            }
        }
    )
}