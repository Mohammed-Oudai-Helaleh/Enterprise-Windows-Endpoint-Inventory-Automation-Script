# Automated Windows Endpoint Inventory & System Health Audit Script

## 📋 Project Overview
This project features a standalone, production-grade PowerShell automation script (`SystemAudit.ps1`) designed to execute a comprehensive hardware, storage capacity, and software package registry audit on Windows endpoints. 

The script runs completely headless, calculating hardware memory configurations, querying storage volumes, and utilizing advanced error-handling architectures to safely crawl core Windows subsystems without host-level degradation.

### Key Features
* **Headless Infrastructure Auditing:** Queries core Windows hardware profiles and OS configurations via the Common Information Model (CIM) interface.
* **Storage Calculation & Capacity Tracking:** Dynamically calculates drive letters, total capacities, used spaces, and remaining free spaces in gigabytes.
* **Crash-Proof Registry Crawling:** Utilizes localized exception-handling loops to safely isolate and bypass corrupted registry subkeys during software package tracking.

---

## 🔍 Technical Architecture & Logic Breakdown

### 1. Hardware and Management Layers (CIM Blocks)
The script bypasses slow graphical administration panels to request data directly from the Windows kernel management layer using the `Get-CimInstance` engine:
* **Win32_OperatingSystem:** Extracts OS caption metrics and kernel bit architecture.
* **Win32_ComputerSystem:** Discovers host system naming identities and calculates physical volatile memory capacities.
* **Win32_Processor:** Gathers primary CPU model names and operational frequencies.

### 2. High-Precision Storage Volumetric Formulas
Storage values are natively tracked by the operating system in raw bytes. To format this into scannable enterprise inventory logs, the script loops through all local fixed logical disks (`DriveType=3`) and processes raw integers through a custom math conversion block:

\[\text{Storage Size in GB} = \frac{\text{Raw Volume Bytes}}{1,073,741,824}\]

```powershell
$TotalSize = [Math]::Round($Drive.Size / 1GB, 2)
```
The result is rounded to two decimal places, dynamically tracking total capacity, current consumption spikes, and structural storage headroom across all disk volumes.

### 3. Debugging the Registry Subsystem Exception (InvalidCastException)
Standard Windows configuration tools often crash when reading application directories because various software installers write non-standard or corrupted values (such as irregular binary formats) inside their native uninstall keys. Standard command sweeps throw a hard `Specified cast is not valid` error and drop data.

To resolve this system flaw, the script implements an enterprise Isolation Loop using structural `try/catch` statement filters:

```text
  [ Parent Registry Paths ]
              │
      ( Get-ChildItem ) ──► Individual Subkey Crawling
              │
       ┌──────┴──────┐
       ▼             ▼
  [ Try Block ]   [ Catch Block ]
  Grabs text      Intercepts Cast Exception
  Drops Corrupted Node Silently
       │             │
       ▼             ▼
  [ Valid App ]   [ Keep Loop Alive ] ──► Next Application
```

By requesting just the explicit text values (`.GetValue("DisplayName")`) on an item-by-item level, any hidden data corruptions are trapped inside an empty catch block. The system drops the broken node silently and moves to the next application, generating a clean, comprehensive software asset inventory list.

---

## 🔬 Operational Verification & Telemetry Output

### 1. Automated Execution Proof
To execute the automation framework safely, open an elevated shell environment and run the script file:

```powershell
PS C:\Windows\system32> C:\Users\ASUS\Documents\SystemAudit.ps1
Success! The system inventory report has been generated on your Desktop
```

![The clean, completed text report displaying full host specs](https://raw.githubusercontent.com/Mohammed-Oudai-Helaleh/Enterprise-Windows-Endpoint-Inventory-Automation-Script/4ee397187436df0d36b9dee82a60941f39377745/assets/powershell_ise_execution.png)
*Figure: Script running smoothly inside the PowerShell ISE development panel, showing the green success confirmation trace below.*

### 2. Standardized Inventory Log Profile Output
The script automatically builds a clean, timestamped corporate manifest file at `$env:USERPROFILE\Desktop\System_Inventory_Report.txt`. The output structure prints beautifully formatted text modules:

```text
========================================================================
                  ENTERPRISE WINDOWS ENDPOINT SYSTEM AUDIT REPORT
========================================================================
Scan Timestamp: 08/31/2026 08:48:34

--- [1.0 HARDWARE PROFILE & OPERATING SYSTEM CONFIGURATION] ---
OS Caption        : Microsoft Windows 10 Pro
OS Architecture   : 64-bit
System Hostname   : DESKTOP-6ID08P6
Total RAM (GB)    : 31.86 GB
CPU Model         : Intel(R) Core(TM) i5-8300H CPU @ 2.30GHz

--- [2.0 LOGICAL DRIVE VOLUMES & STORAGE CAPACITY STATUS] ---
Drive Letter : C:
Total Space  : 476.33 GB
Used Space   : 300.33 GB
Free Space   : 176 GB
____________________________________________

Drive Letter : D:
Total Space  : 344 GB
Used Space   : 88.82 GB
Free Space   : 255.18 GB
____________________________________________

--- [3.0 INSTALLED APPLICATION PACKAGES REGISTERED ON HOST] ---
Installed App : Cisco Packet Tracer 9.0
Installed App : Git Version 2.45.0
Installed App : Google Chrome
Installed App : VMware Workstation Player
======================== [AUDIT COMPLETE] ========================
```

![Script running smoothly inside the PowerShell ISE development panel](https://raw.githubusercontent.com/Mohammed-Oudai-Helaleh/Enterprise-Windows-Endpoint-Inventory-Automation-Script/4ee397187436df0d36b9dee82a60941f39377745/assets/system_inventory_output.png)
*Figure: The clean, completed text report displaying full host specs, local partition limits, and the isolated application package arrays.*

---

## 🛠️ Deployment and Execution Instructions

1. Download or clone this repository to your computer.
2. Search for **PowerShell ISE** in your Start menu, right-click it, and select **Run as Administrator**.
3. Open `SystemAudit.ps1` and press `F5` to execute.
4. Review the generated health logs sitting directly on your Windows Desktop.
