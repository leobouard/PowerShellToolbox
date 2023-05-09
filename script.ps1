param(
    [string]$JsonFile = "$PSScriptRoot\data\default.json",
    [string]$MainTitle = 'PowerShell Toolbox',
    [int]$Height = 680,
    [int]$Width = 1000,
    [switch]$Resizable,
    [switch]$ShowConsole
)

Import-Module .\module.psm1

$parentFolder = $PSScriptRoot -replace '\\','/'
$xml = Get-MainXaml -MainTitle $MainTitle -Height $Height -Width $Width -Resizable $Resizable.IsPresent
$data = (Get-Content -Path $JsonFile -Encoding UTF8) -replace '{{parentFolder}}',$parentFolder | ConvertFrom-Json
$tabs = $data | Sort-Object -Property position | ForEach-Object {
    $tab = Get-TabXaml -TabName $_.tabName -Columns $_.columns -Rows $_.rows
    $id = 0
    $positions = Get-ButtonGridPosition -Columns $_.columns -Rows $_.rows
    $buttons = $_.buttons | ForEach-Object {
        $position = ($positions)[$id]
        Get-ButtonXaml -GridColumn $position.gridColumn -GridRow $position.gridRow -Icon $_.icon -Title $_.title -Text $_.text
        $id++
    }
    $tab -replace '{{buttons}}',$buttons
}

[xml]$xml = $xml -replace '{{tabs}}',$tabs
Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,System.Windows.Forms
$Global:XmlWPF = $Xml
$Global:XamGUI = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $Global:XmlWPF))
$Global:XmlWPF.SelectNodes("//*[@Name]") | ForEach-Object {
    $name = $_.Name
    Set-Variable -Name $name -Value $Global:XamGUI.FindName($name) -Scope Global
    $action = ($data.buttons | Where-Object {($_.title -replace ' ','') -eq $name}).action
    Invoke-Expression -Command "`$$name.Add_Click({ $action })"
}

if (!$ShowConsole.IsPresent) { $null = Hide-Console }

$null = $Global:XamGUI.ShowDialog()