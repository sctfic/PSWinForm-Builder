# PSWinForm-Builder
PowerShell Module to build a windows.forms object from a defintion file

Is a PowerShell module to load a Windows.Forms from a PSD1 definition file, all Windows.Forms controls can be defined.

PSD1 file must habe following structure

    @{
        ControlType = 'Form'
        Name        = 'Form Name'
        KeyPreview  = $true
        Size        = '360, 480'
        # ... Form property fields ...
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

# Usage

    ipmo PSWinForm-Builder
    New-WinForm C:\Users\alopez\Documents\PowerShell\Modules\PSWinForm-Builder\DemoGui_0.psd1 -Show


