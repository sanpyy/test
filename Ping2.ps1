Write-Host "Sandros Ping Tester" -ForegroundColor Green

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$testform = New-Object System.Windows.Forms.Form
$testform.Text = 'Ping Tester'
$testform.Size = New-Object System.Drawing.Size(400, 200)
$testform.StartPosition = 'CenterScreen'

$lb = New-Object System.Windows.Forms.Label
$lb.Location = New-Object System.Drawing.Point(20, 20)
$lb.Size = New-Object System.Drawing.Size(240, 20)
$lb.Text = 'Adresse zum Pingen eingeben:'
$testform.Controls.Add($lb)

$tb = New-Object System.Windows.Forms.TextBox
$tb.Location = New-Object System.Drawing.Point(20, 50)
$tb.Size = New-Object System.Drawing.Size(240, 20)
$testform.Controls.Add($tb)

$okb = New-Object System.Windows.Forms.Button
$okb.Location = New-Object System.Drawing.Point(270, 50)
$okb.Size = New-Object System.Drawing.Size(75, 25)
$okb.Text = 'Ping'
$okb.DialogResult = [System.Windows.Forms.DialogResult]::OK
$testform.AcceptButton = $okb
$testform.Controls.Add($okb)

$testform.Topmost = $true
$testform.Add_Shown({ $tb.Select() })

$rs = $testform.ShowDialog()

if ($rs -eq [System.Windows.Forms.DialogResult]::OK) {
    $y = $tb.Text
    Write-Host "Adresse welche angepingt wird: $y" -ForegroundColor Green
    
    $timestamp = Get-Date -Format "dd.MM.yyyy 'um' HH:mm"
    $outputFolder = "C:\Users\$env:USERNAME\Documents\Logs\Test"
    $outputFile = "$outputFolder\$y.txt"
    
    if (-not (Test-Path $outputFolder)) {
        New-Item -Path $outputFolder -ItemType Directory -Force
    }
    
    $pingResult = Test-Connection $y -Count 4 -ErrorAction SilentlyContinue
    
    if ($pingResult -eq $null) {
        $pingResultString = "$timestamp > Ping für $y not available."
    } else {
        $pingResultStrings = $pingResult | ForEach-Object {
            "$timestamp | Ping für > $y, Time=$($_.ResponseTime)ms TTL=$($_.ResponseTimeToLive) StatusCode=$($_.StatusCode)"
        }
    }
    
    if (Test-Path $outputFile) {
        "`r`n" | Out-File $outputFile -Append
    }
    
    if ($pingResult -eq $null) {
        $pingResultString | Out-File $outputFile -Append
    } else {
        if (Test-Path $outputFile) {
            "`r`n" | Out-File $outputFile -Append
        }
        $pingResultStrings | Out-File $outputFile -Append
    }
}
