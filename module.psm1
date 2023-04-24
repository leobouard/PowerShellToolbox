function Get-MainXaml {
    param(
        [string]$MainTitle,
        [int]$Height,
        [int]$Width,
        [bool]$Resizable
    )

    $xaml = Get-Content -Path '.\main.xml' -Encoding UTF8
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

    $xaml = Get-Content -Path '.\tab.xml' -Encoding UTF8
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
        [string]$Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"
    )

    $xaml = Get-Content -Path '.\button.xml' -Encoding UTF8
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

class GridPosition {
    [int]$GridColumn
    [int]$GridRow
    
    GridPosition([int]$1,[int]$2){
        $this.GridColumn = $1
        $this.GridRow    = $2
    }
}