function Get-MainXaml {
    param(
        [string]$MainTitle,
        [int]$Height,
        [int]$Width,
        [bool]$Resizable
    )

    $xaml = Get-Content -Path "$PSScriptRoot\xml\main.xml" -Encoding UTF8
    $xaml = $xaml -replace '{{mainTitle}}',$MainTitle
    $xaml = $xaml -replace '{{height}}',$Height
    $xaml = $xaml -replace '{{width}}',$Width
    if ($Resizable -eq $true) { $xaml = $xaml -replace 'ResizeMode="NoResize"','ResizeMode="CanResize"' }

    return $xaml
}

function Get-TabXaml {
    param(
        [string]$TabName,
        [int]$Columns = 1,
        [int]$Rows = 1
    )

    $xaml = Get-Content -Path "$PSScriptRoot\xml\tab.xml" -Encoding UTF8
    $xaml = $xaml -replace '{{tabName}}',$TabName
    $xaml = $xaml -replace '{{columnDefinition}}',('<ColumnDefinition/>'*$Columns)
    $xaml = $xaml -replace '{{rowDefinition}}',('<RowDefinition/>'*$Rows)

    return $xaml
}

function Get-ButtonXaml {
    param(
        [int]$GridColumn,
        [int]$GridRow,
        [string]$Icon,
        [string]$Title,
        [string]$Text
    )

    if ($Icon -eq '') { $Icon = "$PSScriptRoot\assets\default.png" }

    $xaml = Get-Content -Path "$PSScriptRoot\xml\button.xml" -Encoding UTF8
    $xaml = $xaml -replace '{{gridColumn}}',$GridColumn
    $xaml = $xaml -replace '{{gridRow}}',$GridRow
    $xaml = $xaml -replace '{{icon}}',$Icon
    $xaml = $xaml -replace '{{title}}',$Title
    $xaml = $xaml -replace '{{text}}',$Text
    $xaml = $xaml -replace '{{name}}',($Title -replace ' ','')

    return $xaml
}

function Get-ButtonGridPosition {
    param(
        [int]$Columns,
        [int]$Rows
    )

    $Column = 0 ; $Row = 0
    $positions = 1..($Columns*$Rows) | ForEach-Object {
        [GridPosition]::New($Column,$Row)
        $Row++
        if ($Row -gt ($Rows-1)) { $Column++ ; $Row = 0 }
        if ($Column -gt ($Columns-1)) { $Column = 0 }
    }

    return ($positions | Sort-Object -Property GridRow,GridColumn)
}

function Hide-Console {
    Write-Verbose 'Hiding PowerShell console...'
    # .NET method for hiding the PowerShell console window
    # https://stackoverflow.com/questions/40617800/opening-powershell-script-and-hide-command-prompt-but-not-the-gui
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 0) # 0 = hide
}

class GridPosition {
    [int]$GridColumn
    [int]$GridRow
    
    GridPosition([int]$1,[int]$2){
        $this.GridColumn = $1
        $this.GridRow    = $2
    }
}