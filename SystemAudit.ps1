#======================================================================
#ENTERPRISE WINDOWS ENDPOINT INVENTORY & SYSTEM HEALTH AUDIT SCRIPT
#Target Domain: CompTIA A+ Core2 (Operatting System & Automation)
#======================================================================

#1. Define the output file path on the Desktop
$ReportPath = "$env:USERPROFILE\Desktop\System_Inventory_Report.txt"

#2. Initialize the fire with a professional corporate header
"==================================================================" | Out-File $ReportPath
"         ENTERPRISE WINDOWS ENDPOINT SYSTEM AUDIT REPORT          " | Out-File $ReportPath -Append
"==================================================================" | Out-File $ReportPath -Append
"Scan Timestamp: $(Get-Date)"                                        | Out-File $ReportPath -Append
""                                                                   | Out-File $ReportPath -Append

#3. Audit Core Hardware Specs
"" | Out-File $ReportPath -Append
"--- [1.0 HARDWARE PROFILE & OPERATING SYSTEM CONFIGURATION] ---" | Out-File $ReportPath -Append
$OSInfo = Get-CimInstance Win32_OperatingSystem
$CSInfo = Get-CimInstance Win32_ComputerSystem
$CPUInfo = Get-CimInstance Win32_Processor

"OS Caption       : $($OSInfo.Caption)"       | Out-File $ReportPath -Append
"OS Architecture  : $($OSInfo.OSArchitecture)"| Out-File $ReportPath -Append
"System Hostname  : $($CSInfo.Name)"          | Out-File $ReportPath -Append
"Total RAM (GB)   : $([Math]::Round($CSInfo.TotalPhysicalMemory / 1GB,2)) GB" | Out-File $ReportPath -Append
"CPU Model        : $($CPUInfo.Name)"         | Out-File $ReportPath -Append

#4. Audit Storage Partition & SMART Health Telemtry
"" | Out-File $ReportPath -Append
"--- [2.0 LOGICAL DRIVE VOLUMES & STORAGE CAPACITY STATUS] ---" | Out-File $ReportPath -Append
$Drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
foreach ($Drive in $Drives) {
    $TotalSize = [Math]::Round($Drive.Size / 1GB, 2)
    $FreeSpace = [Math]::Round($Drive.FreeSpace / 1GB, 2)
    $UsedSpace = [Math]::Round($TotalSize - $FreeSpace, 2)
    "Drive Letter : $($Drive.DeviceID)"  | Out-File $ReportPath -Append
    "Total Space  : $TotalSize GB"       | Out-File $ReportPath -Append
    "Used Space   : $Usedspace GB"       | Out-File $ReportPath -Append
    "Free Space   : $FreeSpace GB"       | Out-File $ReportPath -Append
    "__________________________________" | Out-File $ReportPath -Append
}

#5. Audit Installed Application Software Packages
"" | Out-File $ReportPath -Append
"--- [3.0 INSTALLED APPLICATION PACKAGES REGISTERED ON HOST] ---" | Out-File $ReportPath -Append

# Target the parent folders safely
$Paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Crawl keys individually to isolate and bypass corrupted data values safely
$AppList = foreach ($Path in $Paths) {
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $Name = $_.GetValue("DisplayName")
                if ($Name) { 
                    [PSCustomObject]@{ DisplayName = $Name } 
                }
            } catch {
                # Silently drop corrupted keys and continue the execution loop
            }
        }
    }
}

# Sort the collected valid names alphabetically
$SortedApps = $AppList | Sort-Object DisplayName

foreach($App in $SortedApps) {
    "Installed App : $($App.DisplayName)"  | Out-File $ReportPath -Append
}

"" | Out-File $ReportPath -Append
"======================== [AUDIT COMPLETE] ========================" | Out-File $ReportPath -Append

Write-Host "Success! The system inventory report has been generated on your Desktop" -ForegroundColor Green