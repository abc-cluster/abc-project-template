Import-Module Pode.Web

Start-PodeServer {
    # add a simple endpoint
    Add-PodeEndpoint -Address localhost -Port 8090 -Protocol Http

    # set the use of the pode.web templates
    Use-PodeWebTemplates -Title 'Example' -Theme Terminal

    # add the page
    Add-PodeWebPage -Name Processes -Icon Activity -ScriptBlock {
        New-PodeWebChart -Name 'Top Processes' -Type Bar -AutoRefresh -AsCard -ScriptBlock {
            Get-Process |
                Sort-Object -Property CPU -Descending |
                Select-Object -First 10 |
                ConvertTo-PodeWebChartData -LabelProperty ProcessName -DatasetProperty CPU
        }
    }
}
