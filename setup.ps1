    #
#   # #   Enginsight GmbH
# # # #   Geschäftsführer: Mario Jandeck, Eric Range
# #   #   Hans-Knöll-Straße 6, 07745 Jena
  # 

$Counters = @(
'\Web service(_total)\bytes sent/sec',
'\Web service(_total)\bytes received/sec',
'\Web service(_total)\bytes total/sec',
'\Web service(_total)\files sent/sec',
'\Web service(_total)\files received/sec',
'\Web service(_total)\files/sec',
'\Web service(_total)\connection attempts/sec',
'\Web service(_total)\total method requests/sec'
)

$samples = 25
$result = Get-Counter -Counter $Counters -MaxSamples $samples -SampleInterval 2

$kb_received_per_second = @{}
$kb_sent_per_second = @{}
$kb_total_per_second = @{}
$connection_attempts_per_second = @{}
$total_requests_per_second = @{}

$result | ForEach-Object -Process { $_.countersamples } | ForEach-Object -Process {
    $Path = $_.path
    $Value = $_.CookedValue
    
    if ($Path -match '\\Web Service\(_total\)(.*)' -eq $True) {
        $counter = $Matches[1]
        switch ($counter){
            '\Bytes Received/sec' {
                $kb_received_per_second['_total'] += $Value
                break
            }
            '\Bytes Sent/sec' {
                $kb_sent_per_second['_total'] += $Value
                break
            }
            '\Bytes Total/sec' {
                $kb_total_per_second['_total'] += $Value
                break
            }
            '\Connection Attempts/sec' {
                $connection_attempts_per_second['_total'] += $Value
                break
            }
            '\Total Method Requests/sec' {
                $total_requests_per_second['_total'] += $Value
                break
            }
        }
    }
}

$iis_kb_received_per_second = [math]::round($kb_received_per_second['_total'] / $samples / 1kb,0)
$iis_kb_sent_per_second = [math]::round($kb_sent_per_second['_total'] / $samples / 1kb,0)
$iis_kb_total_per_second = [math]::round($kb_total_per_second['_total'] / $samples / 1kb,0)
$iis_connection_attempts_per_second = [math]::round($connection_attempts_per_second['_total'] / $samples,0)
$iis_requests_per_second = [math]::round($total_requests_per_second['_total'] / $samples)

@"
__METRICS__={{
        "iis_kb_total_per_second": {0:d},
        "iis_kb_sent_per_second": {1:d},
        "iis_kb_received_per_second": {2:d},
        "iis_connection_attempts_per_second": {3:d},
        "iis_requests_per_second": {4:d}
}}
"@ -f
[string]$iis_kb_total_per_second,
[string]$iis_kb_sent_per_second,
[string]$iis_kb_received_per_second,
[string]$iis_connection_attempts_per_second,
[string]$iis_requests_per_second
