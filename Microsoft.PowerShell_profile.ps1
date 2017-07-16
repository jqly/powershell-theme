$Host.UI.RawUI.ForegroundColor = "Black"
$Host.UI.RawUI.BackgroundColor = "White"

(Get-Host).PrivateData.ErrorBackgroundColor = $Host.UI.RawUI.BackgroundColor
(Get-Host).PrivateData.WarningBackgroundColor = $Host.UI.RawUI.BackgroundColor
(Get-Host).PrivateData.DebugBackgroundColor = $Host.UI.RawUI.BackgroundColor
(Get-Host).PrivateData.VerboseBackgroundColor = $Host.UI.RawUI.BackgroundColor
(Get-Host).PrivateData.ProgressBackgroundColor = $Host.UI.RawUI.BackgroundColor

(Get-Host).PrivateData.ErrorForegroundColor = "DarkRed"
(Get-Host).PrivateData.WarningForegroundColor = "Black"
(Get-Host).PrivateData.DebugForegroundColor = "Black"
(Get-Host).PrivateData.VerboseForegroundColor = "Black"
(Get-Host).PrivateData.ProgressForegroundColor = "Black"


Set-PSReadlineOption -TokenKind Command -ForegroundColor DarkCyan
Set-PSReadlineOption -TokenKind Comment -ForegroundColor Gray
Set-PSReadlineOption -TokenKind String -ForegroundColor Magenta
Set-PSReadlineOption -TokenKind Number -ForegroundColor Magenta
Set-PSReadlineOption -TokenKind Parameter -ForegroundColor DarkGray
Set-PSReadlineOption -TokenKind Keyword -ForegroundColor DarkGreen
Set-PSReadlineOption -TokenKind Variable -ForegroundColor DarkMagenta
Set-PSReadlineOption -TokenKind Type -ForegroundColor Gray
Set-PSReadlineOption -TokenKind Member -ForegroundColor DarkMagenta

Clear-Host

Set-Alias subl "$env:Programfiles\Sublime Text 3\subl.exe" -option ReadOnly
Set-Alias cmake "$env:USERPROFILE\CMake\bin\cmake.exe" -option ReadOnly
Set-Alias cmake-gui "$env:USERPROFILE\CMake\bin\cmake-gui.exe" -option ReadOnly

$env:Path = "$env:USERPROFILE\TDM-GCC-64\bin;$env:Path"
$Script:TagList = @()


function setTitleTag {
    $title = ""
    foreach ($tag in $Script:TagList) {$title += "($tag) "}
    $Host.UI.RawUI.WindowTitle = $title
}

function addTag {
    Param(
        [string]$tag
    )
    $Script:TagList += $tag
    setTitleTag
}

function removeTag {
    Param(
        [string]$tag
    )
    $Script:TagList = @($Script:TagList | ? { $_ -notlike $tag })
    setTitleTag
}

$Script:location = (Get-Location)

function prompt {
    removeTag($Script:location)
    $Script:location = (Get-Location)
    addTag($Script:location)
    [Environment]::CurrentDirectory = `
        (Get-Location -PSProvider FileSystem).ProviderPath

    $nestSymbol = ">" * $NestedPromptLevel
    $stackSymbol = "/" * (Get-Location -Stack).Count
    $nextCommandId = (Get-History -Count 1).Id + 1
    Write-Host "[${nestSymbol}${nextCommandId}${stackSymbol}]" `
        -ForegroundColor DarkRed -NoNewLine
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal `
        -ArgumentList $identity
    if ($principal.IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return ": "        
    }
    return ": "
}

