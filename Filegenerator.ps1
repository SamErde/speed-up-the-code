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

    Write-Host 'Pre-generating random values...'

    # Pre-allocate StringBuilder and baseDate for better performance
    $LogLines = [System.Text.StringBuilder]::new(5000000)
    $baseDate = Get-Date

    # Pre-allocate arrays for better performance
    $count = 50000
    $operators = [int[]]::new($count)
    $batches = [int[]]::new($count)
    $loads = [int[]]::new($count)
    $plcIndices = [int[]]::new($count)
    $statusIndices = [int[]]::new($count)
    $errorFlags = [bool[]]::new($count)
    $machineTemps = [double[]]::new($count)
    $errorTypeIndices = [int[]]::new($count)
    $sandextratorValues = [int[]]::new($count)

    # Fill arrays in bulk - much faster than ForEach-Object
    $random = [System.Random]::new()
    for ($i = 0; $i -lt $count; $i++) {
        $operators[$i] = $random.Next(101, 121)
        $batches[$i] = $random.Next(1000, 1101)
        $loads[$i] = $random.Next(0, 101)
        $plcIndices[$i] = $random.Next(0, $plcNames.Length)
        $statusIndices[$i] = $random.Next(0, $statusCodes.Length)
        $errorFlags[$i] = $random.Next(1, 8) -eq 4
        $machineTemps[$i] = [math]::Round(($random.Next(60, 110) + $random.NextDouble()), 2)
        $errorTypeIndices[$i] = $random.Next(0, $errorTypes.Length)
        $sandextratorValues[$i] = $random.Next(1, 11)
    }

    # Pre-calculate base timestamp string to avoid repeated formatting
    $baseDateTicks = $baseDate.Ticks
    $ticksPerSecond = [TimeSpan]::TicksPerSecond

    Write-Host 'Generating log entries...'

    for ($i = 0; $i -lt $count; $i++) {
        # More efficient timestamp calculation
        $currentTicks = $baseDateTicks - ($i * $ticksPerSecond)
        $timestamp = [DateTime]::new($currentTicks).ToString('yyyy-MM-dd HH:mm:ss')

        # Cache array lookups
        $plc = $plcNames[$plcIndices[$i]]
        $status = $statusCodes[$statusIndices[$i]]
        $operator = $operators[$i]
        $batch = $batches[$i]
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
