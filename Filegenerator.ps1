Measure-Command {
    $bigFileName = 'plc_log.txt'
    $plcNames = 'PLC_A', 'PLC_B', 'PLC_C', 'PLC_D'
    $statusCodes = 'OK', 'WARN', 'ERR'
    $errorTypes = @(
        'Sandextrator overload',
        'Conveyor misalignment',
        'Valve stuck',
        'Temperature warning'
    )

    # Create a single System.Random instance for better performance
    $random = [System.Random]::new()

    # Pre-calculate base timestamp to avoid Get-Date calls in loop
    $baseDate = Get-Date

    # Pre-allocate StringBuilder capacity (estimate: 50,000 lines × 100 chars = 5MB)
    $LogLines = [System.Text.StringBuilder]::new(5000000)

    # Pre-generate random values in batches for better performance
    Write-Host 'Pre-generating random values...'
    $operators = 1..50000 | ForEach-Object { $random.Next(101, 121) }
    $batches = 1..50000 | ForEach-Object { $random.Next(1000, 1101) }
    $loads = 1..50000 | ForEach-Object { $random.Next(0, 101) }
    $plcIndices = 1..50000 | ForEach-Object { $random.Next(0, $plcNames.Length) }
    $statusIndices = 1..50000 | ForEach-Object { $random.Next(0, $statusCodes.Length) }
    $errorFlags = 1..50000 | ForEach-Object { $random.Next(1, 8) -eq 4 }
    $machineTemps = 1..50000 | ForEach-Object { [math]::Round( ($random.Next(60, 110) + $random.NextDouble() ), 2) }
    $errorTypeIndices = 1..50000 | ForEach-Object { $random.Next(0, $errorTypes.Length) }
    $sandextratorValues = 1..50000 | ForEach-Object { $random.Next(1, 11) }

    for ($i = 0; $i -lt 50000; $i++) {
        $timestamp = $baseDate.AddSeconds(-$i).ToString('yyyy-MM-dd HH:mm:ss')
        $plc = $plcNames[$plcIndices[$i]]
        $operator = $operators[$i]
        $batch = $batches[$i]
        $status = $statusCodes[$statusIndices[$i]]
        $machineTemp = $machineTemps[$i]
        $load = $loads[$i]

        if ($errorFlags[$i]) {
            $errorType = $errorTypes[$errorTypeIndices[$i]]
            if ($errorType -eq 'Sandextrator overload') {
                $value = $sandextratorValues[$i]
                [void]$LogLines.AppendLine("ERROR; $timestamp; $plc; $errorType; $value; $status; $operator; $batch; $machineTemp; $load")
            } else {
                [void]$LogLines.AppendLine("ERROR; $timestamp; $plc; $errorType; ; $status; $operator; $batch; $machineTemp; $load")
            }
        } else {
            [void]$LogLines.AppendLine("INFO; $timestamp; $plc; System running normally; ; $status; $operator; $batch; $machineTemp; $load")
        }
    }

    Set-Content -Path $bigFileName -Value $LogLines.ToString()

    Write-Output 'PLC log file generated.'
}
