# PSWinForm-Builder
PowerShell Module to build a windows.forms object from a defintion file

Is a PowerShell module to load a Windows.Forms from a PSD1 definition file, all Windows.Forms controls can be defined.

## Usage

You can write a description file `MyProject.psd1` for GUI and Event and you can extand by a function file with same Name but extension is *.psm1 like `MyProject.psm1` (if this file exist is imported like powershell module)

```powershell
    Import-Module PSWinForm-Builder
    New-WinForm .\DemoGui.psd1  -ShowWinForms -PreloadModules PsWrite,PsBright -Verbose
```
## Snippet VSCode
Copy content of `"Snippet Powershell.json"` to `"...\Code\User\snippets\powershell.json"` (VSCode --> File --> Preferences --> User Snippets --> Powershell)

## PSD1 file must habe following structure
### Descripter *.psd1
```powershell
    @{
        ControlType = 'Form'
        Name        = 'Form Name'
        KeyPreview  = $true
        Size        = '360, 480'
        # Icon Base64 8Bits + 1 Alpha
        Icon            = [System.Drawing.Icon][System.IO.MemoryStream] [System.Convert]::FromBase64String('...')

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
```

### Rendu GUI (generate and loading 1.2s)
![alt tag](https://github.com/sctfic/PSWinForm-Builder/blob/main/Example.png "Example.png")

### Mode -Verbose
![alt tag](https://github.com/sctfic/PSWinForm-Builder/blob/main/Verbose.png "Verbose.png")