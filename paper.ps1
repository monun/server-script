Function download {
    [CmdletBinding()]
    Param (
        [string]$url,
        [string]$folder,
        [Parameter(Mandatory = $False)] [string]$filename
    )

    New-Item "$folder" -Force -ItemType Directory | Out-Null

    try {
        $WebRequest = [System.Net.HttpWebRequest]::Create($url);
        $WebRequest.Method = "GET"
        $WebResponse = $WebRequest.GetResponse()

        if ( [string]::IsNullOrEmpty($filename)) {
            $Disposition = $WebResponse.Headers['Content-Disposition']

            if ( [string]::IsNullOrEmpty($Disposition)) {
                $filename = [System.IO.Path]::GetFileName($url)
            }
            else {
                $filename = [System.Net.Mime.ContentDisposition]::new($Disposition).FileName
            }
        }

        $dest = "$folder\$filename"
        $FileInfo = [System.IO.FileInfo]$dest

        if (Test-Path $dest) {
            $RemoteLastModified = $WebResponse.LastModified
            $LocalLastModified = $FileInfo.LastWriteTime

            if ([datetime]::Compare($RemoteLastModified, $LocalLastModified) -eq 0) {
                Write-Host "UP-TO-DATE $filename ($url)"
                $WebResponse.Dispose()
                return
            }
            Write-Host "Updating $filename from $url"
        }
        else {
            Write-Host "Downloading $filename from $url"
        }
        $ResponseStream = $WebResponse.GetResponseStream()
        Write-Host $dest
        $FileWriter = New-Object System.IO.FileStream ($dest, [System.IO.FileMode]::Create)
        [byte[]]$buffer = New-Object byte[] 4096

        do {
            $length = $ResponseStream.Read($buffer, 0, 4096)
            $FileWriter.Write($buffer, 0, $length)
        } while ($length -ne 0)

        $ResponseStream.Close()
        $FileWriter.Close()
        $FileInfo.LastWriteTime = $WebResponse.LastModified
    }
    catch [System.Net.WebException] {
        $Status = $_.Exception.Response.StatusCode
        $Msg = $_.Exception
        Write-Host "  Failed to dowloading $dest, Status code: $Status - $Msg" -ForegroundColor Red
    }
}
function choice
{
    Param(
        [string]$prompt,
        [string]$monitor,
        [int]$seconds
    )

    $monitor = $monitor.ToUpper()
    $StartTime = Get-Date
    $TimeOut = New-TimeSpan -seconds $seconds

    Write-Host $prompt

    while ($CurrentTime -lt $StartTime + $TimeOut)
    {
        if ($host.UI.RawUI.KeyAvailable)
        {
            [string]$Key = ($host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho")).character
            $Key = $Key.ToUpper().ToCharArray()[0]

            if ($monitor -eq $Key) {
                Break
            }
        }

        $CurrentTime = Get-Date
    }
}


$jar_url = "https://papermc.io/api/v1/paper/1.16.5/latest/download"
$debug = $false
$debug_port = 5005
$backup = $true
$restart = $true
$memory = 8
$plugins = @(
    'https://github.com/monun/kotlin-plugin/releases/latest/download/Kotlin-1.5.0.jar'
    'https://github.com/monun/auto-update/releases/latest/download/AutoUpdate.jar'
    'https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar'
)

# Print configurations
Write-Host "debug = $debug"
Write-Host "backup = $backup"
Write-Host "restart = $restart"
Write-Host "memory = ${memory}G"

download $jar_url "$HOME\.minecraft\servers" "paper.jar"

# Download plugins
foreach ($plugin in $plugins) {
    download $plugin ".\plugins"
}

# Build JVM args
$jvm_arguments = [System.Collections.ArrayList]@(
    "-Xmx${memory}G"
    "-Xms${memory}G"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
    "-Dusing.aikars.flags=https://mcflags.emc.gs"
    "-Daikars.new.flags=true"
    "-Dcom.mojang.eula.agree=true"
)

if ($memory -lt 12) {
  Write-Host "Use Aikar's standard memory options"
  $aika_options=@(
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:InitiatingHeapOccupancyPercent=15"
 )
}
else {
  Write-Host "Use Aikar's Advanced memory options"
  $aika_options=@(
    "-XX:G1NewSizePercent=40"
    "-XX:G1MaxNewSizePercent=50"
    "-XX:G1HeapRegionSize=16M"
    "-XX:G1ReservePercent=15"
    "-XX:InitiatingHeapOccupancyPercent=20"
  )
}

foreach ($option in $aika_options) {
    $jvm_arguments.Add($option) | Out-Null
}

if ($debug) {
    $jvm_arguments.Add("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:$debug_port") | Out-Null
}

$jvm_arguments.Add("-jar") | Out-Null
$jvm_arguments.Add("$HOME\.minecraft\servers\paper.jar") | Out-Null
$jvm_arguments.Add("--nogui") | Out-Null

while($true) {
    java $jvm_arguments

    if ($backup) {
        choice "Press Y to start the backup immediately or Ctrl+C to cancel" 'Y' 5
        Write-Host "Start the backup."
        New-Item ".backup" -Force -ItemType Directory | Out-Null
        $backup_file_name = Get-Date -Format "yyyy-MM-dd-HHmmss"
        7z a -tzip ".backup\$backup_file_name.zip" .\ "-xr!*.gz" "-x!.backup" "-x!cache" | Out-Null
        Write-Host "The backup is complete."
    }

    if ($restart -eq $false) {
        exit
    }

    choice "The server restarts. Press Y to start immediately or Ctrl+C to cancel" 'Y' 5

    Write-Host "The server will be restarted."
}
