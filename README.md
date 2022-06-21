# PSWinForm-Builder
PowerShell Module to build a windows.forms object from a defintion file

Is a PowerShell module to load a Windows.Forms from a PSD1 definition file, all Windows.Forms controls can be defined.

## Usage

    ipmo PSWinForm-Builder
    New-WinForm .\DemoGui.psd1 -Show

## PSD1 file must habe following structure

    @{
        ControlType = 'Form'
        Name        = 'Form Name'
        KeyPreview  = $true
        Size        = '360, 480'
        # Icon Base64 8Bits + 1 Alpha
        Icon            = [System.Drawing.Icon][System.IO.MemoryStream] [System.Convert]::FromBase64String('AAABAAEALUAAAAEACAAoEgAAFgAAACgAAAAtAAAAgAAAAAEACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPEBUAEhMXABMVGAAVFB0AFRYZABYXGgAaFxkAFxgcABgZHAAcGRsAGRodAB4aHAAZGh4AGhsfABscHwAfHB4AHB0gABwdIQAdHCUAIR4gACIeIAAdHiIAIh8hAB4eJgAeHyMAHx4nAB8gIwAjICIAIB8oACAhJAAkISMAICElACUiJAAhIiYAIiMnACMkKAAkJSgAKCUnACQlKQApJigAKiYpACYnKwAnKCwAKCktACkqLQAqKy4AMCwuACwuLAAsLTEALS4yADIvMQAuLzMAMzAyAC8wNAAxMjYAMjM3ADc0NgAzNDgAODU3ADQ1OQA1NjoAODk9ADk6PgA+Oz0AOjs/ADo9OwA7PEAAQT5AAD4/QwA/QEQAQENBAEZCRABBQkYAQkVDAENESABERUkASUVIAERHRQBFRkoARkdMAEZJRwBMSEsATkpMAEpLUABQTU8AS01RAExNUgBNTlMATVBOAFJPUQBOT1QAT1FVAFVRVABRVFIAWFRWAFJUWABUVVkAWlZYAFVYVgBWV1sAVlhcAFdZXQBeWlwAWVxZAFpbXwBfXF4AW1xhAFxdYgBcX10AYl5hAF1eYwBjX2IAX2BkAF9iYABgYWYAYWJmAGFkYgBiY2cAZ2NmAGNkaABjZmMAZGZkAGRlaQBpZWgAZWdlAGVmagBqZmkAZmhmAGZnawBsaGoAZ2hsAGhpbgBpbGoAb2ttAGlrbwBqbHAAcW1vAGxvbQBsbnIAc29xAG1vcwB1cXMAb3F1AHBzcQBwcnYAdnJ1AHFzdwByc3gAcnVzAHh0dgBzdHkAc3Z0AHR1egB0d3UAenZ4AHV2ewB1eHYAdnd8AHx4egB3engAeHl9AHl6fwB5fHoAenuAAIB8fgB7fnwAgX1/AHx9ggB9foMAfYB+AH5/hAB+gX8Af4CFAH+CgACFgYQAgYKHAIGEggCHg4UAgoOIAISFigCEh4UAi4eJAIaHjACGiYcAh4qIAImKjwCKjYsAi4yRAJGNjwCMj40AjI6SAI2QjgCOj5QAj5KQAJCRlgCRk5cAk5SZAJqWmQCUlpsAlZecAJaZlwCWmJ0Al5qYAJ6anQCZmp8AmJyZAJucoQCinqEAnZ6jAKCipgCoo6YAoqWjAKSlqgCmp6wApqmnAKeqqACoq6kAqayqAKqssQCtrrMAr7C1AK+zsACwtLEAsrO4ALy3ugC+urwAubq/ALq9uwC7vcIAvb/EAMDBxgDDxsQAxcbLAMjLyQDPy84AyszRAMvPzADV19wA297cAN7h3wDi4+gA5efsAO7q7QDv6+4A7O3yAOvv7ADv8PYA8fL3APL0+QD5/PoA+v37APr8/wD//P8A+/3/APv//AAAAAAA////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////j///////////AAAA/////////////////////////////////////////////////7z/////////AAAA/////////6KP////////////////////////////////////q5P/////////AAAA//////////9Ref/Z///////////////////////////////h/2H/////////AAAA//////////9xJbn/fv///////////////////////////8kVDyPO////////AAAA////////////TG3//4////////////////////////////+FQwz/////////AAAA////////////rQJt6VSq/+r//////////////////////5NQQBaj////////AAAA/////////////ycy/6E////K//////////////////////+pMhZT////////AAAA/////////////5ERnf8Cjv+mnP///////////////////2qFchEg////////AAAA//////////////8NP7wDLv//cf////////////////////80FRYPyf//////AAAA/////////////48PDIMPFZ7/lXfx/////////////////9bdMhgM////////AAAA//////////////8SGBYbGD///x//////////////////2D9MKiAPYf//////AAAA/////////////14bGxUYFgz/vA8//////////////////7oYHhgN0///////AAAA////////////v0cYGBUWFhhc/xEMvP//////////////dv9hGxgQxf//////AAAA/////////////+WFFhMXGBYrTxYWRN/////////////wlwIRGB4PzP/////WAAAA//////////////+FDRgYFhYYGxYYFf////////////////8WGxYKxP///4X/AAAA//////////////9yFhsZGBcWGBcbE0n///////////9pZmofGBgP////lUGzAAAA//////////////8ZGxgYFhYTFxYWGQbF////////////HhUbFhsJo////xaVAAAA//////////+uUw0eGB4bGBgYFhgYFhiT////////sf/qYhMYGBgR////NiJWAAAA////////////GB4TGBMVGBsWFhgWFh9H/////////0j/nT8YFhZD//+crig6AAAA/////////78PFhgfFh8yKBgXFxYXGCAflv///////2EQBhUeGBWY////tBExAAAA/////////yYcGBgWED7/ehEWGx4YGxsN//////+U//9GHBgbGAv///+VXhYyAAAA////////YhseGxsRkf///0YXFhgbGBgYi/////+2AWlvFhYVFjzb/93GVxg5AAAA//////+DExYfHhpr//////8uHhgWFx4WLv//2P//VBYVGBgYE1////9mIBtUAAAA/////74vFRgfGLb///////+oDRkZGxgVAv//rF//vBgbFhYbDP///26zJhWYAAAA/////10TGRkg0v//////////bRYeFhgWE5H/3QYgeSIWFxkbfP///54JGw+xAAAA/////w8SHgnA////////////tDEYGBYYGBGP/1MXEhMZExYiuf/j/+J5DQysAAAA////aRsZD8T//////////////28WGxMYFhsPmq4eGxsYFhNy////pAYyGC7/AAAA///ENR4Ycv////////////////9QGBgWGRkYFyMYGBgbGEj///98zmQYG1b/AAAA////CRty////////////////////KBsWGB4eHhsbFhsbIv///7//GhsbD4f/AAAA//+cFUD/////////////////////ow0XGxgYGBgVFR8Mtf//54imVBgYNv//AAAA//98D////////////////////////2kTFhkbGxMWFhP///9S/5MDFRkP////AAAA///Pm+L//////8v/eSg//////////5kRGBYYGB8YDHf//2YYFVkTHhZPxv//AAAA////////////gTYMFhYMsf////////8QExMYFhYP////gQcYGxsfFhi4////AAAA////////nFobGBMZFRgeKqj//////48nGh8bGDF9///qPBkbGBgWGIX/////AAAA//////+EEBsbGBYYFhsWGHv///////80GBYPQP//////gxMbGBYPSP//////AAAA/////y86iGoVFhcWGBgYIGL//////7wyFjBk/////////wMRHiJa////////AAAA////MtLy/PaxExgWGBYenvSm//////8fWLv//////////yUbMp3/////////AAAA/7Vc7vz6/v7TERsYFhgN2/zJ6P///9r/rv///////////zt91f//////////AAAA/1Dv/Pz+/vNHFhsXGxkP1fvh////////////////////////////////////AAAApur8/v78854VFxgbGBYYpvzlwf//////////////////////////////////AAAAnvX8/v7zrA8YGxsWFRsYQ/Xe////////////////////////////////////AAAAnPL8/vKMExgWFxgYExUWFbyV0f//////////////////////////////////AAAA/1zFyFkbFhcTFRYWBgcGAiXM////////////////////////////////////AAAA//+6rpNyeS9WxUE3w//Q/+j/////////////////////////////////////AAAA/////////0WI/4g0////////////////////////////////////////////AAAA////////ozjO/4oNnf//////////////////////////////////////////AAAA/////////y////8n////////////////////////////////////////////AAAA////////hTJ9/+pQa///////////////////////////////////////////AAAA/////////zn///+5Mv//////////////////////////////////////////AAAA////////v0O5////OLj/////////////////////////////////////////AAAA/////////1T//////03/////////////////////////////////////////AAAA////////7lOZ/////z+z////////////////////////////////////////AAAA/////////0z//////7tP////////////////////////////////////////AAAA/////////5+4//////9vnP//////////////////////////////////////AAAA/////////4//////////Xf//////////////////////////////////////AAAA//////////9Y/////////2n/////////////////////////////////////AAAA//////////+e//////////9/////////////////////////////////////AAAA//////////+E////////////dv//////////////////////////////////AAAA/////////////////////////6n/////////////////////////////////AAAA///////////////////////////K//X/////////////////////////////AAAA////////////0///////////////////////////////////////////////AAAA/////////////+z/////////////////////////////////////////////AAAA///////4AAD/////9/gAAP/////7+AAA/n////P4AAD/L///6/gAAP8X///B+AAA/5v//+P4AAD/gX//wfgAAP/Jv//h+AAA/8Sf/8H4AAD/4N//4PgAAP/AR//B+AAA/+Bv/4D4AAD/wEf/wPgAAP+AI/+g+AAA/8AB/wDwAAD/4AP/4OgAAP/gAf8BwAAA/+AA/4DgAAD/AAD9AcAAAP+AAP6BgAAA/gAAfgHAAAD+AgD7A4AAAPwHAHgBAAAA+A+AbAOAAADwH4BkBwAAAPA/wCAHAAAA8H/AEAUAAADg/+AADggAAMH/8AAcCAAA4//4ADoIAADH//gAMBgAAM///ADoOAAAx9H8AMAYAAD/gP4DgDgAAPwAfAMAeAAA+AB+D4D4AADwAHwfwfgAAOAAPj/D+AAAgAAdf8f4AACAAD////gAAAAAH///+AAAAAA////4AAAAAB////gAAIAAP///+AAAwAV////4AAD+T/////gAAPxH////+AAA/u/////4AAD8R/////gAAP7n////+AAA/HP////4AAD++/////gAAPx5////+AAA/vn////4AAD+fP////gAAP7+////+AAA/39////4AAD/f7////gAAP9/3///+AAA///v///4AAD///X///gAAP+/////+AAA/9/////4AAA=')

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
