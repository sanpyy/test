Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$pinging = $false
$pingJob = $null

$testform = New-Object System.Windows.Forms.Form
$testform.Text = 'Ping Tester'
$testform.Size = New-Object System.Drawing.Size(400, 200)
$testform.StartPosition = 'CenterScreen'

$lb = New-Object System.Windows.Forms.Label
$lb.Location = New-Object System.Drawing.Point(20, 20)
$lb.Size = New-Object System.Drawing.Size(240, 20)
$lb.Text = 'Zu pingende Adresse eingeben:'
$testform.Controls.Add($lb)

$tb = New-Object System.Windows.Forms.TextBox
$tb.Location = New-Object System.Drawing.Point(20, 50)
$tb.Size = New-Object System.Drawing.Size(240, 20)
$testform.Controls.Add($tb)

$okb = New-Object System.Windows.Forms.Button
$okb.Location = New-Object System.Drawing.Point(270, 50)
$okb.Size = New-Object System.Drawing.Size(75, 25)
$okb.Text = 'Start Ping'
$testform.AcceptButton = $okb
$testform.Controls.Add($okb)

$stopb = New-Object System.Windows.Forms.Button
$stopb.Location = New-Object System.Drawing.Point(270, 80)
$stopb.Size = New-Object System.Drawing.Size(75, 25)
$stopb.Text = 'Stop Ping'
$stopb.Enabled = $false
$testform.Controls.Add($stopb)

$okb.Add_Click({
    if ($pinging -eq $false) {
        $pinging = $true
        $okb.Text = 'Pinging ...'
        $stopb.Enabled = $true
        $y = $tb.Text
        Write-Host "Adresse zum pingen eingeben: $y" -ForegroundColor Green
        $outputFolder = "C:\Users\$env:USERNAME\Documents\Logs\Test\"
        $outputFile = Join-Path -Path $outputFolder -ChildPath "$y.txt"

        if (-not (Test-Path $outputFolder)) {
            New-Item -Path $outputFolder -ItemType Directory -Force
        }

        $pingJob = Start-Job -ScriptBlock {
            param ($address, $file)
            while ($pinging) {
                $pingResult = Test-Connection $address -Count 1 -ErrorAction SilentlyContinue
                if ($pingResult -ne $null) {
                    $timestamp = Get-Date -Format "dd.MM.yyyy 'um' HH:mm"
                    $pingResultString = "$timestamp | Ping für $address > Time=$($pingResult.ResponseTime)ms TTL=$($pingResult.ResponseTimeToLive) StatusCode=$($pingResult.StatusCode)"
                    Add-Content -Path $file -Value $pingResultString
                }
                Start-Sleep -Seconds 5
            }
        } -ArgumentList $y, $outputFile

        $okb.Text = 'Start Ping'
        $stopb.Enabled = $true
    }
})

$stopb.Add_Click({
    $pinging = $false
    if ($pingJob -ne $null) {
        Get-Job -Id $pingJob.Id | Stop-Job -Force
        $pingJob = $null
    }
    $okb.Text = 'Start Ping'
    $stopb.Enabled = $false
})

$testform.Topmost = $true
$testform.Add_Shown({ $tb.Select() })

$rs = $testform.ShowDialog()
