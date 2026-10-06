<# changelog / 2026 ---------------------------------------------------------------------------------------------------------------------------------------------------------------- #

23/07 v0.2.0-alpha / 
added initial main menu content

24/07 v0.2.1-alpha / 
implemented menu navigation logic
added quick fix submenu

25/07 v0.2.2-alpha / 
added additional main menu options
added vpn submenu

28/07 v0.2.3-alpha / 
added validation and error messaging for invalid menu selections

31/07 v0.3.0-alpha / 
completed menu navigation framework
renamed functions to align with powershell naming conventions and standards

05/08 v0.3.0-alpha / 
review session with TL focused on code reuse and maintainability
reworked codebase to improve function reuse
began development of vpn-related commands
 
06/08 v0.3.1-alpha / 
added vpn submenu with organisation-specific selection options
implemented vpn installation logic
began investigation into file import functionality
 
07/08 v0.3.2-alpha / 
consulted with technician (euc) regarding file import implementation
added file import functionality
finalised [redacted] vpn installation workflow
 
10/08 v0.3.3-alpha / 
feedback session with additional technicians
added additional command functions
added application branding/logo to all menus
minor code reuseability optimisations
 
14/08 v0.3.4-alpha / 
added vpn installation functionality for [redacted] and [redacted]
added system repair functionality
 
19/08 .v0.3.5-alpha / 
reworked error handling framework
added error handling for external command execution
 
20/08 v0.3.6-alpha / 
added launchpad commands
added success notifications for application-launch commands
removed continuation prompts following successful application launches
automated sccm remediation process
added additional sccm-related functions
received guidance from george regarding further sccm automation opportunities
 
24/08 v0.3.7-alpha / 
added clipboard copy functionality
added networking-related functions
improved code formatting and consistency
 
25/08 v0.3.7-alpha / 
refined code structure and layout
 
26/08 v0.3.8-alpha / 
added additional utility functions
streamlined multiple-choice submenu navigation logic
 
27/08 v0.4.0-alpha / 
added cache management menu
added logged-in user detection functionality
implemented parameter-driven cache clearing functionality
 
28/08 v0.4.1-alpha / 
added browser cache clearing functionality
added group policy update functionality
 
03/09 v0.4.1-alpha / 
feedback session with charlie
 
04/09 v0.4.2-alpha / 
reworked clipboard copy functionality
reworked c:/temp access functionality
integrated c:/temp access into relevant functions
added multiple utility functions
applied minor accessibility improvements to menu navigation
 
08/09 v0.4.3-alpha / 
added stage/context detection functionality
fixed issue where show-continueprompt output could leak into other functions

11/09 v0.5.0-alpha / 
added device management menu
created device control functions
added info option for all menus
improved main menu layout. added [q = return] functionality across all menus.
created generic confirmation message function. 

15/09 v0.5.1-alpha /
added device management functions
feedback with cody on readability of program output 
minor code re-use optimisations
created menu color function

16/09 v0.5.2-alpha /
reworked menu coloring function
implemented to menus to improve navigation and accessiblility 

17/09 v0.6.0-alpha /
created quick fixes (frontstage) section
menu colors finalised

21/09 v0.6.1-alpha /
created bitlocker function
created inactive profile clear function
improved visual clarity of network function outputs
added common ports numbers to port testing function
reworked to-do / tagging system

22/09 v0.7.0-alpha / 
expanded device-management / device-info into seperate menus
moved various functions to above menus to free up space
standardised sub-menu colour and layout
functions added: drive space, mail profile, wfbh cache clear
added more drive locations to map function

25/09 v0.7.1-alpha /
consolidated VPN re-installation into single function
added clipboard copy functionality to device info functions

29/09 v0.7.2-alpha / 
added: -launch sd keepass
reworked: -sccm actions debug

30/09 v0.7.3-alpha /
added: -clear recycle (user/all), -determine domain
reworked: -confirm prompt improvement

02/10 v0.7.4-alpha /
added: -ram utilzation, -event log capture, -timestamp/date functionality
reworked: -renamed / re-commented multiple functions for clarity
misc: -tested multiple functions

# ANCHOR - misc. #
<# to-do ---------------------------------------------------------------------------------------------------------------------------------------------------------------- #
-logging
-further 3rd line feedback
-gpresult (broken)

to-do legend #
# to-do     = not started
# wip       = in-progress
# untested  = finished, untested
# broken    = tested, does not work
# tested = tested on personal / [company] device
#>

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - common functions #

param (
    # session info
    [string]$Version = "v0.7.4-alpha", # program version
    [string]$Hostname = "$env:computername",
    [string]$RunningAs = [Security.Principal.WindowsIdentity]::GetCurrent().Name,
    # cosmetic seperator elements
    [string]$Seperator = "-----------------------------------",
    [string]$SeperatorSmall = "-----",
    # time info
    [string]$Timestamp = (Get-Date -Format "HH:mm:ss"),
    [string]$Date = (Get-Date -Format "dd/MM/yy"),
    [string]$TimeDate = (Get-Date -Format "HH:mm dd/MM/yy"), 
    # error message timeout duration
    [int]$ErrorDelay = 800 
)

# ascii logo
$Script:SdmsLogo = @'
           .___              
  ______ __| _/_____   ______
 /  ___// __ |/     \ /  ___/
 \___ \/ /_/ |  Y Y  \\___ \ 
/____  >____ |__|_|  /____  >
     \/     \/     \/     \/  
'@ 

# display logo + session info
function Show-TitleBar {
    Write-Host "$SdmsLogo" -ForegroundColor White -NoNewline
    Write-Host "// $Version" -NoNewline
    Write-Host " // $RunningAs // $Hostname" -ForegroundColor DarkGray
}

# copy $Output to clipboard

# 1) route output to variable =  | Tee-Object -Variable [$Temp]
# 2) write to clipboard = $Output = @"[$Temp]"@
# 3) copy to clipboard = Copy-OutputClipboard -Output $Output
function Copy-OutputClipboard {
    param (
        [string]$Output
    )
    $Output | Set-Clipboard # copies output onto clipboard
    Write-Host "[output copied to clipboard]" -ForegroundColor Green
}

# confirm / create C:/temp folder
function Confirm-TempFolder {
    $Folder = "C:/Temp"
    if (-not (Test-Path $Folder)) { 
        # Test-Path = checks path for existance of folder
        # if (-not) =  runs only if Test-Path returns negative result
        New-Item -Path $Folder -ItemType Directory -Force | Out-Null # creates C:/Temp folder, bypasses Out-Null bypasses success msg
    }
}

# determine domain of device
function Get-Domain {
    $Domain = (Get-CimInstance Win32_ComputerSystem).Domain
    switch -Wildcard ($Domain) {
        "[redacted]"                { return "[redacted]" }
        "[redacted]"                { return "[redacted]" }
        "[redacted]"                { return "[redacted]" }
        "[redacted]"                { return "[redacted]" }
        "[redacted]"                { return "[redacted]" }
        "[redacted]"                { return "[redacted]" } # wildcard for all L83[...] domains
        "[redacted]"                { return "[redacted]" }
        default                     { return "unknown ($Domain)" }
    }
}

# launch C:/temp (create, if missing)
function Open-TempFolder {
    param ( 
        [switch]$Silent # run without Show-LaunchSuccess
    )
    try {
        Confirm-TempFolder
        Start-Process -FilePath "explorer.exe" -ArgumentList "C:\Temp"
        if (-not $Silent) { Show-LaunchSuccess }
    }
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# determine logged in user from system context
function Get-LoggedOnUser {
    $User = (Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" | # explorer.exe only runs on actual, logged-in sessions (tested working in back-stage)
        # return user that started the process
        Invoke-CimMethod -MethodName GetOwner).User | 
        # ignore duplicate explorer.exe instances
        Select-Object -Unique -First 1 
    if (-not $User) { 
        throw "no logged in user detected"
    }
    return $User # passes output to function that called this one
}

# confirm current privilege level
function Confirm-SdmsContext {
# choice left to user, as automating this was beyond the complexity scope of program
# run as guard clause inside function: if (-not (Confirm-SdmsContext -ExampleParam)) { return }
# available params = Backstage, Frontstage, User, Admin
    param (
        [switch]$Backstage, # requires backstage
        [switch]$Frontstage, # requires frontstage
        [switch]$Admin, # requires admin context
        [switch]$User # requires user context
    )

    $Labels = @() 
    # add to label based on specified params [+=] = adds to end of array
    if ($Backstage) { $Labels += "backstage" } 
    if ($Frontstage) { $Labels += "frontstage" } 
    if ($Admin) { $Labels += "admin" }
    if ($User) { $Labels += "user" } 
    $Context = $Labels -join " + " # combine all labels into output, joined by [+] symbol

    while ($true) {
        # Write-Host ""
        # Write-Host "$Seperator"
        Write-Host "please confirm that sdms is currently running in " -NoNewLine
            Write-Host "[$Context]" -NoNewLine -ForegroundColor Yellow
            Write-Host " context"
        Format-Menu -Key "1" -Text "yes" -KeyFg Yellow
        Format-Menu -Key "2" -Text "no" -KeyFg Yellow
        Write-Host ""
        Format-Menu -Key "q" -Text "return" -KeyFg Yellow
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 
        # returns true if correct context, false + error msg if incorrect
        switch ($Select) {
            '1' { return $true } 
            '2' { 
                Write-Host "[incorrect context]" -ForegroundColor Red
                Write-Host "launch sdms in [$Context]" -ForegroundColor Red
                Show-ContinuePrompt
                return $false
            } 
            'q' { return $false } 
            default { Show-InvalidSelection }
        }
    }
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - error / nav. handling #

# error handling
$ErrorActionPreference = "Stop" # stops script execution even on non-terminating errors

# run external commands with error parsing 
# to use: [Invoke-ExternalCommand "example"] (quotes required)
function Invoke-ExternalCommand {
    param (
        [Parameter (Mandatory = $true)] 
        [string]$Command # the command to run
    )
    Invoke-Expression $Command
    # only triggers if exit code is not 0 (success)
    if ($LASTEXITCODE -ne 0) { 
        # throw creates terminating error, "$Command" specifies what error the command came from (for multi command functions)
        throw "$Command`: $LASTEXITCODE" 
    }
}

# generic yes/no confirmation prompt, returns $true / $false. 
# message can be overriden inline with -ConfirmMessage
# exit on no = if (-not (Confirm-Selection -ConfirmMessage "example")) { return }
function Confirm-Selection {
    param (
        [string]$ConfirmMessage = "are you sure?" # default message, can override inline with [-ConfirmMessage]
    )
    while ($true) {
        # Write-Host "$Seperator"   
        Write-Host "$ConfirmMessage" -ForegroundColor Yellow     
        Format-Menu -Key "1" -Text "yes" -KeyFg Yellow
        Format-Menu -Key "2" -Text "no" -KeyFg Yellow
        Write-Host ""  
        Format-Menu -Key "q" -Text "return" -KeyFg Yellow
        $Select = Read-Host "[select]" 
        switch ($Select) {
            '1' { return $true }
            '2' { return $false }
            'q' { return }
            default { Show-InvalidSelection }
        }
    }
}
# script error msg
function Show-ErrorMessage { 
Write-Host "[$Timestamp error]: $_" -ForegroundColor Red # $_= dumps the error message
}

# invalid option selection msg
function Show-InvalidSelection { 
    Write-Host "[invalid selection] ..." -ForegroundColor Red
    Start-Sleep -Milliseconds $ErrorDelay
} 

# app launch success msg
function Show-LaunchSuccess {
    Write-Host "[launching] ..." -ForegroundColor Green
    Start-Sleep -Milliseconds $ErrorDelay 
}

# cache clear success msg
function Show-CacheSuccess {
    Write-Host "[cache cleared]" -ForegroundColor Green
}

# continue prompt msg
function Show-ContinuePrompt { 
    Read-Host -Prompt "[press enter to continue] ..." | Out-Null # supresses output leaking into other functions
}

# placeholder msg
function Show-Unavailable { 
    Write-Host "[feature currently unavailable] ..." -ForegroundColor Red
    Start-Sleep -Milliseconds ($ErrorDelay * 2)
}

# control the colors of menu elements
# can also be used for colored [status] messages
function Format-Menu {
# key = menu button in bracket eg. '[1]'
# text = menu button label eg. 'quick fixes'
    param (
        [string]$Key, # highlighted bracket text
        [string]$Text, # main body text

        # fg / bg color of $Key
        [ConsoleColor]$KeyFg = "White", 
        [ConsoleColor]$KeyBg = "Black",
        # fg / bg color of $Text        
        [ConsoleColor]$TextFg = "White",
        [ConsoleColor]$TextBg = "Black"
    )
    Write-Host "[$Key]" -NoNewline -ForegroundColor $KeyFg -BackgroundColor $KeyBg
    Write-Host " $Text" -ForegroundColor $TextFg -BackgroundColor $TextBg
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - main-menu #

function Show-MenuMain {
    # set windowtitle
    $Host.UI.RawUI.WindowTitle = "sd-management-script $Version" 
    while ($true) {       
        Clear-Host # clear PS window
        Show-TitleBar # logo + device/user info
        Write-Host ""
        Write-Host "------------ main menu ------------"
        Format-Menu -Key "1" -Text "quick fixes" -KeyFg Yellow
        Format-Menu -Key "2" -Text "frontstage fixes" -KeyFg Yellow
        Format-Menu -Key "3" -Text "cache clear" -KeyFg Yellow
        Format-Menu -Key "4" -Text "network" -KeyFg Yellow
        Format-Menu -Key "5" -Text "vpn" -KeyFg Yellow
        Format-Menu -Key "6" -Text "updates" -KeyFg Yellow
        Format-Menu -Key "7" -Text "device management" -KeyFg Yellow
        Format-Menu -Key "8" -Text "device info" -KeyFg Yellow
        Format-Menu -Key "9" -Text "launchpad" -KeyFg Yellow
        Format-Menu -Key "0" -Text "[unavailable]" -KeyFg Yellow
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg Yellow
        Format-Menu -Key "l" -Text "log" -KeyFg Yellow
        Format-Menu -Key "q" -Text "quit" -KeyFg Yellow
        Write-Host "$Seperator"
        Write-Host "[enter] to confirm selection"
        $Select = Read-Host "[select]"

        switch ($Select) { 
            '1' { Show-MenuFixes } 
            '2' { Show-MenuFixesFrontstage } 
            '3' { Show-MenuCache }
            '4' { Show-MenuNetwork }
            '5' { Show-MenuVpn } 
            '6' { Show-MenuUpdates }
            '7' { Show-MenuDeviceManagement }
            '8' { Show-MenuDeviceInfo }
            '9' { Show-MenuLaunchpad }
            '0' { Show-Unavailable }            
            'i' { Show-Unavailable }
            'l' { Show-Unavailable }
            'q' { exit }   
            default { Show-InvalidSelection }
        }
    }
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - quick-fixes  #
function Show-MenuFixes {
    while ($true) {
        Clear-Host
        Show-TitleBar
        Write-Host ""
        Write-Host "----------- quick fixes -----------"
        Format-Menu -Key "1" -Text "[unavailable]" -KeyFg Magenta # tested
        Format-Menu -Key "2" -Text "[unavailable]" -KeyFg Magenta # tested
        Format-Menu -Key "3" -Text "[unavailable]" -KeyFg Magenta # tested
        Format-Menu -Key "4" -Text "flush DNS" -KeyFg Magenta # tested
        Format-Menu -Key "5" -Text "reset print spooler" -KeyFg Magenta # tested
        Format-Menu -Key "6" -Text "[unavailable]" -KeyFg Magenta # tested
        Format-Menu -Key "7" -Text "office repair" -KeyFg Magenta # untested
        Format-Menu -Key "8" -Text "resync clock" -KeyFg Magenta # untested
        Format-Menu -Key "9" -Text "bitlocker pin" -KeyFg Magenta # tested
        Format-Menu -Key "0" -Text "remove old user profiles" -KeyFg Magenta # untested
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg Magenta # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg Magenta
        Write-Host "$Seperator"
        $Select = Read-Host "[select]"

        switch ($Select) {                       
            '1' { Show-Unavailable }
            '2' { Show-Unavailable }
            '3' { Show-Unavailable } 
            '4' { Clear-DnsCache }
            '5' { Restart-PrintSpooler }
            '6' { Show-Unavailable }
            '7' { Show-RepairOfficeMenu }
            '8' { Sync-Clock }
            '9' { Show-BitLockerPin }
            '0' { Clear-InactiveProfiles }
            'i' { Show-Unavailable }
            'q' { return }
            default { Show-InvalidSelection }
        }
    }
}

# reset print spooler
# restart spooler and deletes cached print jobs
function Restart-PrintSpooler {
    try {
        Invoke-ExternalCommand "net stop spooler"
        Remove-Item -Path "C:/Windows/System32/spool/printers/*" -Force 
        Invoke-ExternalCommand "net start spooler"
        Write-Host "[success] print spooler reset" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
} 

# office repair [gui / no gui selection]
function Repair-OfficeMenu {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "------- run in background? --------"
        Format-Menu -Key "1" -Text "yes" -KeyFg Yellow
        Format-Menu -Key "2" -Text "no" -KeyFg Yellow
        # Write-Host ""
        Format-Menu -Key "q" -Text "return" -KeyFg Yellow
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) { 
            '1' { Repair-Office -DisplayLevel False } 
            '2' { Repair-Office -DisplayLevel True } 
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}
function Repair-Office {
    # controls -argumentlist DisplayLevel setting. true / false = gui / no gui
    param ( 
        [string]$DisplayLevel
    )
    try {
        Start-Process -FilePath "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe" -Verb RunAs -ArgumentList "scenario=Repair platform=x64 culture=en-us forceappshutdown=True RepairType=FullRepair DisplayLevel=$DisplayLevel"
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}
function Sync-Clock {
    try {
        Write-Host "[resetting w32time service] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "net stop w32time"
        Invoke-ExternalCommand "w32tm /unregister"
        Invoke-ExternalCommand "w32tm /register"
        Invoke-ExternalCommand "net start w32time"
        Write-Host "[success] clock sync complete" -ForegroundColor Green 
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# return bitlocker pin from GetPIN.log file
function Show-BitLockerPin {
    try {
        $LogPath = "C:\Windows\CCM\Logs\GetPIN.log"

        # confirm log exists
        if (-not (Test-Path $LogPath)) { 
            throw "getpin.log not found at $LogPath" 
        }

        # search log for line containing phrase 'BitLocker PIN'
        # format: '<![LOG[BitLocker PIN       : 123456]LOG]!><time="00:00:00.000+000" date="01-01-2024" component="GetPIN" context="" type="1" thread="" file="GetPIN">'
        # run a regex search on the matched line ('\d{6}' = exactly 6 digits in a row), '.Value' returns only the matched digits
        # (tested, this should only return the PIN and not any false positives based on example layout above, cleaner than using multiple instances of -Replace) 
        $Pin = [regex]::Match((Select-String -Path "$LogPath" -Pattern "BitLocker PIN").Line, '\d{6}').Value
        if (-not $Pin) { # if line containing 'BitLocker PIN' not found
            throw "bitlocker pin not found" 
        }

        Write-Host ""
        Write-Host "[bitlocker pin] : $Pin"
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# removes profiles inactive for more than specified time
# code based on KB0011608 by Findlay Robertson
<#Get-WMIObject -class Win32_UserProfile | Where {(!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddMonths(-2))} | Remove-WmiObject#>
function Clear-InactiveProfiles {
    Format-Menu -Key "warning" -Text "deletes user profiles inactive for longer than specified threshold. proceed with care." -KeyFg Red
    Write-Host ""
    Format-Menu -Key "q" -Text "return" -KeyFg Yellow
    Write-Host "$Seperator"
    $MonthsInactive = Read-Host "[enter inactivity threshold in months]" # prompt for cutoff period 

    if ($MonthsInactive -eq 'q') { return } # allow user to back out
    if (-not (Confirm-Selection -Confirm "this will remove profiles unused for $MonthsInactive+ months, continue?")) { return }

    try {
        Write-Host "[removing inactive profiles] ..." -ForegroundColor Yellow
        Get-WmiObject -Class Win32_UserProfile |
            Where-Object { (!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddMonths(-$MonthsInactive)) } |
            Remove-WmiObject
        Write-Host "[success] inactive profiles removed" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - quick-fixes-frontstage #
function Show-MenuFixesFrontstage {
    while ($true) {
        Clear-Host
        Show-TitleBar
        Write-Host ""
        Write-Host "-------- frontstage fixes ---------"
        Format-Menu -Key "1" -Text "app-v repair [fronstage]" -KeyFg DarkMagenta # untested
        Format-Menu -Key "2" -Text "map drives" -KeyFg DarkMagenta # tested
        Format-Menu -Key "3" -Text "clear recycle bin [current user]" -KeyFg DarkMagenta # tested
        Format-Menu -Key "4" -Text "[unavailable]" -KeyFg DarkMagenta
        Format-Menu -Key "5" -Text "[unavailable]" -KeyFg DarkMagenta
        Format-Menu -Key "6" -Text "[unavailable]" -KeyFg DarkMagenta
        Format-Menu -Key "7" -Text "[unavailable]" -KeyFg DarkMagenta
        Format-Menu -Key "8" -Text "[unavailable]" -KeyFg DarkMagenta
        Format-Menu -Key "9" -Text "[unavailable]" -KeyFg DarkMagenta
        Format-Menu -Key "0" -Text "[unavailable]" -KeyFg DarkMagenta
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg DarkMagenta
        Format-Menu -Key "q" -Text "return" -KeyFg DarkMagenta
        Write-Host "$Seperator"
        $Select = Read-Host "[select]"

        switch ($Select) {                       
            '1' { Repair-AppV }
            '2' { Mount-SharedDrive }
            '3' { Clear-RecycleBinUser} 
            '4' { Show-Unavailable }
            '5' { Show-Unavailable }
            '6' { Show-Unavailable }
            '7' { Show-Unavailable }
            '8' { Show-Unavailable }
            '9' { Show-Unavailable }
            '0' { Show-Unavailable }
            'i' { Show-Unavailable }
            'q' { return }
            default { Show-InvalidSelection }
        }
    }
}

# action appv repair
# launches commands in new windows, making it work from both user/admin context 
# however, this means this one is frontstage only. can potentially use scheduled task work-aroud
function Repair-AppV {
if (-not (Confirm-SdmsContext -Frontstage -Admin)) { return }
    try {
        Write-Host "[admin] removing appv client packages ..." -ForegroundColor Yellow
        Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"Get-AppvClientPackage -All | Remove-AppvClientPackage`"" -Verb RunAs -Wait

        Write-Host "[user] syncing / repairing app-v packages ..." -ForegroundColor Yellow
        Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"Get-AppvPublishingServer | Sync-AppvPublishingServer; Get-AppvClientPackage -All | Repair-AppvClientPackage`"" -Wait

        Write-Host "[success] appv repair complete" -ForegroundColor Green 
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# remap shared drive
function Mount-SharedDrive {
if (-not (Confirm-SdmsContext -Frontstage -User)) { return }
    while ($true) {
        Clear-Host
        Show-TitleBar
        Write-Host ""
        Write-Host "--------- select company ----------"
        Format-Menu -Key "1" -Text "[redacted]"    -KeyFg Yellow
        Format-Menu -Key "2" -Text "[redacted]"    -KeyFg Yellow
        Format-Menu -Key "3" -Text "[redacted]"    -KeyFg Yellow
        Format-Menu -Key "4" -Text "[redacted]"    -KeyFg Yellow
        Format-Menu -Key "5" -Text "[redacted]"   -KeyFg Yellow
        Write-Host ""
        Format-Menu -Key "q" -Text "return" -KeyFg Yellow
        Write-Host "$Seperator"
        $Select = Read-Host "[select]"

        # determine filepath based on 
        $DrivePath = switch ($Select) {
            '1' { "\\[redacted]" }
            '2' { "\\[redacted]" }
            '3' { "\\[redacted]" }
            '4' { "\\[redacted]" }
            '5' { "\\[redacted]" }
            'q' { return }
        }

        # retry on ($null) input. continue = return to top of loop
        if ($null -eq $DrivePath) {
            Show-InvalidSelection
            continue
        }
        # unmaps then re-maps drive
        try {
            Write-Host "[unmapping s/ drive] ..." -ForegroundColor Yellow
            net use S: /DELETE # not 'Invoke-ExternalCommand' to prevent error from unmapped drive from stopping function
            Write-Host "[mapping s:/ to $DrivePath] ..." -ForegroundColor Yellow
            Invoke-ExternalCommand "net use S: `"$DrivePath`" /Persistent:Yes"
            Write-Host "[success] s:/ mapped to $DrivePath" -ForegroundColor Green
        }
        catch {
            Show-ErrorMessage
        }
        Show-ContinuePrompt
    }
}

# clear recycling bin for currently logged in user
function Clear-RecycleBinUser {
if (-not (Confirm-SdmsContext -Frontstage -User)) { return }
    try {
        Write-Host "[clearing recycle bin] ..." -ForegroundColor Yellow
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Host "[success] recycle bin cleared" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - cache #
function Show-MenuCache {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "----------- cache clear -----------"
        Format-Menu -Key "1" -Text "edge [cache/cookies]" -KeyFg Green # untested
        Format-Menu -Key "2" -Text "chrome [cache/cookies]" -KeyFg Green # untested
        Format-Menu -Key "3" -Text "teams" -KeyFg Green # untested
        Format-Menu -Key "4" -Text "systemone" -KeyFg Green # untested
        Format-Menu -Key "5" -Text "outlook" -KeyFg Green # untested
        Format-Menu -Key "6" -Text "office" -KeyFg Green # untested
        Format-Menu -Key "7" -Text "dns" -KeyFg Green # tested
        Format-Menu -Key "8" -Text "windows hello" -KeyFg Green # untested
        Format-Menu -Key "9" -Text "print queue" -KeyFg Green # tested
        Format-Menu -Key "0" -Text "[unavailable]" -KeyFg Green
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg Green # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg Green
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) { 
            '1' { Clear-Cache -BrowserType 'Edge' } # edge
            '2' { Clear-Cache -BrowserType 'Chrome' } # chrome
            '3' { Clear-Cache -CacheLocation "AppData\Local\Packages\MSTeams_8wekyb3d8bbwe" -UserFolderRequired } # teams
            '4' { Clear-Cache -CacheLocation "C:\apps\tpp" } # systmone
            '5' { Clear-Cache -CacheLocation "AppData\Microsoft\Outlook\RoamCache" -UserFolderRequired } # outlook
            '6' { Clear-Cache -CacheLocation "AppData\Microsoft\Office\16.0\OfficeFileCache" -UserFolderRequired } # office
            '7' { Clear-DnsCache }
            '8' { Clear-WfbhCache }
            '9' { Restart-PrintSpooler }
            'i' { Show-Unavailable }
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}

function Clear-Cache {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CacheLocation, # path of cache to clear
        [switch]$UserFolderRequired # if cache path goes through c:/users/%username%
    )
    try {
        if ($UserFolderRequired) {
            $User = Get-LoggedOnUser 
            $CacheLocation = "C:\Users\$User\$CacheLocation" 
        }
        if (-not (Test-Path $CacheLocation)) {
            throw "cannot locate cache: $CacheLocation"
        }
        Write-Host "[clearing $CacheLocation] ..." -ForegroundColor Yellow
        Remove-Item -Path "$CacheLocation\*" -Recurse -Force
        Show-CacheSuccess
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

function Clear-CacheBrowser {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Edge', 'Chrome')] # restricts param to 'edge' / 'chrome' only
        [string]$BrowserType # defines browser type
    )
    try {
        $User = Get-LoggedOnUser
        $ProfilePath = switch ($BrowserType) { # changes cache path based on param selected
            'Edge'   { "C:\Users\$User\AppData\Local\Microsoft\Edge\User Data\Default" }
            'Chrome' { "C:\Users\$User\AppData\Local\Google\Chrome\User Data\Default" }
        }
        if (-not (Test-Path $ProfilePath)) {
            throw "cannot locate cache: $ProfilePath"
        }
        # both run on chromium, so have a re-usable cache folder structure
        Write-Host "[clearing $BrowserType cache/cookies] ..." -ForegroundColor Yellow
        Remove-Item -Path "$ProfilePath\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue # main cache files
        Remove-Item -Path "$ProfilePath\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue # javascript / webassembly cached files
        Remove-Item -Path "$ProfilePath\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue # gpu shader cache
        Remove-Item -Path "$ProfilePath\Cookies" -Force -ErrorAction SilentlyContinue # main cookie cash
        Remove-Item -Path "$ProfilePath\Cookies-journal" -Force -ErrorAction SilentlyContinue # rollback journal for cookies, in case of app crash
        Show-CacheSuccess
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# reset wfbh process and clear cache
# code from INC0770580
function Clear-WfbhCache {
    try {
        $User = Get-LoggedOnUser
        # stop the Windows Biometric Service
        Write-Host "[stopping wbiosrvc service] ..." -ForegroundColor Yellow
        Stop-Service -Name WbioSrvc -Force
        # remove all biometric data
        Write-Host "[removing biometric data] ..." -ForegroundColor Yellow
        Remove-Item -Path "C:\Windows\System32\WinBioDatabase" -Recurse -Force
        # restart the Windows Biometric Service
        Write-Host "[starting wbiosrvc service] ..." -ForegroundColor Yellow
        Start-Service -Name WbioSrvc
    }
    catch {
        Show-ErrorMessage
    }
    try {
        # remove the Ngc folder (containes pin / hello credentials)
        $NgcPath = "C:\Users\$User\AppData\Local\Microsoft\Ngc"
        Write-Host "[deleting ngc folder] ..." -ForegroundColor Yellow
        Remove-Item -Path $NgcPath -Recurse -Force
    }
    catch {
        try {
            # take ownership of the Ngc folder
            Write-Host "[taking ownership of ngc folder] ..." -ForegroundColor Yellow
            icacls $NgcPath /grant "$($User):(F)" /t
            # retry removing the folder
            Write-Host "[deleting ngc folder with ownership] ..." -ForegroundColor Yellow
            Remove-Item -Path $NgcPath -Recurse -Force
        }
        catch {
            Show-ErrorMessage
        }
    }
    Show-ContinuePrompt
}
# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - network #

function Show-MenuNetwork {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "------------- network -------------"
        Format-Menu -Key "1" -Text "test ip/domain" -KeyFg Cyan # tested
        Format-Menu -Key "2" -Text "test ip/domain -port" -KeyFg Cyan # tested
        Format-Menu -Key "3" -Text "device network info" -KeyFg Cyan # tested
        Format-Menu -Key "4" -Text "wireless history report" -KeyFg Cyan # tested
        Format-Menu -Key "5" -Text "ipconfig release/renew" -KeyFg Cyan # untested
        Format-Menu -Key "6" -Text "reset network adapter" -KeyFg Cyan # untested
        Format-Menu -Key "7" -Text "open hosts file" -KeyFg Cyan # tested
        Format-Menu -Key "8" -Text "flush dns" -KeyFg Cyan # tested
        Format-Menu -Key "9" -Text "sim info" -KeyFg Cyan # untested
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg Cyan # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg Cyan
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 
        switch ($Select) { 
            '1' { Test-IpConnection }
            '2' { Test-IpPort }
            '3' { Show-DeviceNetworkInfo }
            '4' { Export-WlanReport }
            '5' { Reset-DhcpLease } 
            '6' { Reset-NetAdapter }
            '7' { Open-HostsFile }
            '8' { Clear-DnsCache }
            '9' { Show-SimInfo }
            'i' { Show-Unavailable }
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}

# reset dhcp lease
function Reset-DhcpLease {
    try {
        Write-Host "[releasing ip] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand 'ipconfig /release'
        Write-Host "[renewing ip] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand 'ipconfig /renew'
        Write-Host "[success] dhcp lease renewed" -ForegroundColor Green       
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt    
}

# runs network diagnostic tests on specified domain
function Test-IpConnection {
    # configure tracert options
    param (
    [int]$MaximumHops = 15, # maximum no. of hops
    [int]$HopDelay = 2000 # time in ms
)

    $TargetAddress = Read-Host "[enter ip / domain]" # prompts user for domain / IP to test
    # stores the output of each command as a string, to be copied to clipboard later
    # invoke-externalcommand not used, as errors are useful info in this case. still formatted as try/catch, in case clipboard copying fails, and for later logging
    try {
        Write-Host "[ping] ..." -ForegroundColor Yellow
        ping $TargetAddress | Tee-Object -Variable PingResult # Tee-Object splits output, result shown on-screen and also stored to $[x]Result

        Write-Host "[test-netconnection] ..." -ForegroundColor Yellow
        Test-NetConnection $TargetAddress | Out-String | Tee-Object -Variable TncResult # forces output into text
        # $TncResult = $TncResult | Out-String 

        Write-Host "[nslookup] ..." -ForegroundColor Yellow
        nslookup $TargetAddress | Tee-Object -Variable NslookupResult

        Write-Host "[tracert] ..." -ForegroundColor Yellow
        tracert -h $MaximumHops -w $HopDelay $TargetAddress | Tee-Object -Variable TracertResult
# output of the commands, -join "`n" = each line of the array gets seperated by a new line when converted to string
# not required for tnc as PS formats output by default
        $Output = @"
$Seperator

[$TargetAddress] // $env:computername
[ping]
$($PingResult -join "`n")
$Seperator

[tnc]
$TncResult
$Seperator

[nslookup]
$($NslookupResult -join "`n")
$Seperator

[tracert]
$($TracertResult -join "`n")q
$Seperator
"@
        Copy-OutputClipboard -Output $Output
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# test port on specific address
function Test-IpPort {
    $TargetAddress = Read-Host "[enter address]" # prompts user for address

    Write-Host "$Seperator"
    Write-Host "[common ports]:" 
    Format-Menu -Key "443" -Text "https" -KeyFg Cyan 
    Format-Menu -Key "80" -Text "http" -KeyFg Cyan
    Format-Menu -Key "389" -Text "ldap" -KeyFg Cyan 
    Format-Menu -Key "587" -Text "smtp " -KeyFg Cyan 
    Format-Menu -Key "993" -Text "imaps" -KeyFg Cyan 
    Format-Menu -Key "53" -Text "dns" -KeyFg Cyan 
    Format-Menu -Key "3389" -Text "rdp" -KeyFg Cyan 
    $TargetPort = Read-Host "[enter port number]" # prompts user for port no.

    try {
        Write-Host "[running test-netconnection] ..." -ForegroundColor Yellow
        Test-NetConnection $TargetAddress -Port $TargetPort | Out-String | Tee-Object -Variable TncResult # forces output into text
        $Output = @"
$Seperator

[$TargetAddress -port $TargetPort] // $env:computername
$TncResult
"@
        Copy-OutputClipboard -Output $Output
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# displays detailed networking information for device 
function Show-DeviceNetworkInfo {
    try {
        Write-Host "[get-netadapter] ..." -ForegroundColor Yellow
        Get-NetAdapter | Format-Table -AutoSize | Out-String -Width 200 | Tee-Object -Variable NetAdapterResult 
        # Out-String -Width 200 = forces output into text, width stops tables from defaulting to console size, messing up formatting for clipboard

        Write-Host "[get-netipconfiguration] ..." -ForegroundColor Yellow
        Get-NetIPConfiguration | Format-List | Out-String -Width 200 | Tee-Object -Variable NetIPResult

        Write-Host "[arp -a] ..." -ForegroundColor Yellow
        arp -a | Tee-Object -Variable ArpResult

        Write-Host "[route print] ..." -ForegroundColor Yellow
        route print | Tee-Object -Variable RoutePrintResult

# output of the commands, -join "`n" = each line of the array gets seperated by a new line when converted to string
        $Output = @"
$Seperator

[$env:computername]
[get-netadapter]
$($NetAdapterResult -join "`n")
$Seperator

[get-netipconfiguration]
$($NetIPResult -join "`n")
$Seperator

[arp -a]
$($ArpResult -join "`n")
$Seperator

[routeprint]
$($RoutePrintResult -join "`n")
$Seperator
"@
        Copy-OutputClipboard -Output $Output
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# generates wlan report and saves to c:/temp
function Export-WlanReport  {
    try {
        Confirm-TempFolder
        $User = Get-LoggedOnUser
        Write-Host "[running netsh wlan show wlanreport] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "netsh wlan show wlanreport"
        # copy from hardcoded output location to c:/temp + rename
        Copy-Item -Path "C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html" -Destination "C:\Temp\wlan-report-latest_$($Hostname)_$($User).html" -Force 
        Write-Host "[success] wlan report saved to c:\temp\wlan-report-latest_$($Hostname)_$($User).html" -ForegroundColor Green
        Open-TempFolder -Silent
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# reset network adapter
Function Reset-NetAdapter {
    try {
        Get-NetAdapter # display list of available adapters
        $AdapterName = Read-Host "[type adapter name]" # prompt to select adapter

        Disable-NetAdapter -Name $AdapterName -Confirm:$false
        Start-Sleep -Seconds 5 # pause to give adapter time to shut down
        Enable-NetAdapter -Name $AdapterName -Confirm:$false
        Write-Host "[success] $AdapterName reset" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# display / copy sim info
function Show-SimInfo {
        try {
        Write-Host "[netsh mbn show read interface = *] ..." -ForegroundColor Yellow
        netsh mbn show read interface = * | Tee-Object -Variable SimResult 

        $Output = @"
[sim information] //
$($SimResult -join "`n")
"@
        Copy-OutputClipboard -Output $Output
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - vpn #
function Show-MenuVpn {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "--------------- vpn ---------------"
        Format-Menu -Key "1" -Text "vpn reinstall" -KeyFg Blue # untested
        Format-Menu -Key "2" -Text "check vpn connection" -KeyFg Blue # tested
        Format-Menu -Key "3" -Text "flush dns" -KeyFg Blue # tested
        Format-Menu -Key "4" -Text "open cert. manager" -KeyFg Blue # tested
        Format-Menu -Key "5" -Text "open hosts file" -KeyFg Blue # tested
        Format-Menu -Key "6" -Text "[unavailable]" -KeyFg Blue
        Format-Menu -Key "7" -Text "[unavailable]" -KeyFg Blue
        Format-Menu -Key "8" -Text "[unavailable]" -KeyFg Blue
        Format-Menu -Key "9" -Text "[unavailable]" -KeyFg Blue
        Format-Menu -Key "0" -Text "[unavailable]" -KeyFg Blue
        Write-Host ""
        Format-Menu -Key "i" -Text "+info" -KeyFg Blue # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg Blue
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) { 
            '1' { Install-Vpn }
            '2' { Show-VpnStatus }
            '3' { Clear-DnsCache } 
            '4' { Start-CertManager }
            '5' { Open-HostsFile }
            '6' { Show-Unavailable }
            '7' { Show-Unavailable }
            '8' { Show-Unavailable }
            '9' { Show-Unavailable }
            '0' { Show-Unavailable }
            'i' { Show-Unavailable }
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}

# reinstall VPN 
# menu to prompt for company selection
function Install-Vpn {
    # select tennant
    while ($true) {
        Clear-Host
        Show-TitleBar
        Write-Host ""
        Write-Host "--------- select company ----------"
        Format-Menu -Key "1" -Text "[redacted]" -KeyFg Yellow
        Format-Menu -Key "2" -Text "[redacted]" -KeyFg Yellow
        Format-Menu -Key "3" -Text "[redacted]" -KeyFg Yellow
        Write-Host ""
        Format-Menu -Key "q" -Text "return" -KeyFg Yellow
        Write-Host "$Seperator"
        $Select = Read-Host "[select]"
        # confirm c:/temp
        Confirm-TempFolder
        # write script install files to c:/temp
        switch ($Select) {
            '1' { Write-ScriptVpnTennant1 }
            '2' { Write-ScriptVpnTennant2 }
            '3' { Write-ScriptVpnTennant3 }
            'q' { return }
            default { Show-InvalidSelection; continue }
        }
        # install vpn
        try {
            Write-Host "[installing device tunnel] ..." -ForegroundColor Yellow
            Invoke-ExternalCommand 'PowerShell.exe -ExecutionPolicy Bypass -File "C:\temp\New-AovpnDeviceTunnel.ps1" -xmlFilePath C:\temp\DeviceProfile.xml'
            Write-Host "[installing user tunnel] ..." -ForegroundColor Yellow
            Invoke-ExternalCommand 'PowerShell.exe -ExecutionPolicy Bypass -File "C:\temp\New-AovpnUserTunnel.ps1" -xmlFilePath C:\temp\UserProfile.xml'
            Write-Host "[success] vpn install complete" -ForegroundColor Green
        }
        catch {
            Show-ErrorMessage
        }
        Show-ContinuePrompt
    }
}

# flush DNS cache
function Clear-DnsCache { 
    try { # try running command first
        ipconfig /flushdns; 
    }
    catch { # fallback if error occurs during command
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# launch rasphone + run rasdial command
function Show-VpnStatus {
    try {
        rasphone
        rasdial
    }
    catch { 
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - updates #
function Show-MenuUpdates {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "------------- updates -------------"
        Format-Menu -Key "1" -Text "launch sccm manager" -KeyFg Red # tested
        Format-Menu -Key "2" -Text "updates scripts fix" -KeyFg Red # untested
        Format-Menu -Key "3" -Text "run all client actions" -KeyFg Red # untested
        Format-Menu -Key "4" -Text "clear software-distribution" -KeyFg Red # untested
        Format-Menu -Key "5" -Text "repair sccm" -KeyFg Red # untested
        Format-Menu -Key "6" -Text "windows ver" -KeyFg Red # tested
        Format-Menu -Key "7" -Text "[unavailable]" -KeyFg Red
        Format-Menu -Key "8" -Text "[unavailable]" -KeyFg Red
        Format-Menu -Key "9" -Text "[unavailable]" -KeyFg Red
        Format-Menu -Key "0" -Text "drive space available" -KeyFg Red # tested
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg Red # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg Red
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) { 
            '1' { Start-SccmManager }
            '2' { Invoke-SccmScript }
            '3' { Invoke-SccmActions }
            '4' { Clear-SoftwareDistribution }
            '5' { Repair-Sccm }
            '6' { Show-WinVersion }
            '0' { Show-DiskSpace }
            'i' { Show-Unavailable }
            'q' { return }
            default { Show-InvalidSelection }
        }
    }
}

# referecnes = KB0015019
# import sccm fix files, then run sequentually
# no error reporting, as scripts often fail by design
function Invoke-SccmScript {
    Confirm-TempFolder
    Write-ScriptSccm
        Write-Host "[running fix-windowsupdate] ..." -ForegroundColor Yellow
        & "C:\Temp\FIX-WindowsUpdate.ps1"
        Write-Host "[running fix-wuaandmwerrors] ..." -ForegroundColor Yellow
        & "C:\Temp\FIX-WUAandMWerros.ps1"
        Write-Host "[running fix-stuckbitsjobs] ..." -ForegroundColor Yellow
        & "C:\Temp\FIX-StuckBITSJobs.ps1"
        Write-Host "[running sccm-resetinventory] ..." -ForegroundColor Yellow
        & "C:\Temp\SCCM-ResetInventory.ps1"
        Write-Host "[running sccm-updatescan] ..." -ForegroundColor Yellow
        & "C:\Temp\SCCM-UpateScan.ps1"
    Write-Host "[success]" -ForegroundColor Green
    Show-ContinuePrompt
}

# run all sccm client actions
function Invoke-SccmActions {
    # sccm client action IDs, ordered hashtable so that they are ran in correct sequence (unsure if this matters)
    $Actions = [ordered]@{
        "machine policy retrieval & evaluation cycle"    = "{00000000-0000-0000-0000-000000000021}"
        "machine policy evaluation cycle"                = "{00000000-0000-0000-0000-000000000022}"
        "discovery data collection cycle"                = "{00000000-0000-0000-0000-000000000003}"
        "software inventory cycle"                       = "{00000000-0000-0000-0000-000000000002}"
        "hardware inventory cycle"                        = "{00000000-0000-0000-0000-000000000001}"
        "software updates scan cycle"                     = "{00000000-0000-0000-0000-000000000113}"
        "software updates deployment evaluation cycle"    = "{00000000-0000-0000-0000-000000000114}"
        "software metering usage report cycle"            = "{00000000-0000-0000-0000-000000000031}"
        "application deployment evaluation cycle"         = "{00000000-0000-0000-0000-000000000121}"
        "user policy retrieval"                           = "{00000000-0000-0000-0000-000000000026}"
        "user policy evaluation cycle"                    = "{00000000-0000-0000-0000-000000000027}"
        "windows installer source list update cycle"      = "{00000000-0000-0000-0000-000000000032}"
        "file collection"                                 = "{00000000-0000-0000-0000-000000000010}"
    }
    # each action gets its own try/catch, prevents one error from stopping next 
    foreach ($Action in $Actions.GetEnumerator()) {
        try {
            Write-Host "[running $($Action.Key)] ..." -ForegroundColor Yellow
            # TriggerSchedule runs the client action matching the ID
            Invoke-CimMethod -Namespace "root\ccm" -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{ sScheduleID = $Action.Value } | Out-Null
        }
        catch {
            Show-ErrorMessage
        }
    }

    Write-Host "[success] actions triggered" -ForegroundColor Green
    Show-ContinuePrompt
}
# delete software-distribution folder
# (part of troubleshooting in KB0015019)
function Clear-SoftwareDistribution {
    try {
        Write-Host "[stopping wuauserv service] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "net stop wuauserv"
        Write-Host "[stopping bits service] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "net stop bits"
        Write-Host "[clearing softwaredistribution folder] ..." -ForegroundColor Yellow
        Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue # recurse = delete subfolders # SilentlyContinue = skip deleting and dont provide error
        Write-Host "[starting net start wuauserv] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "net start wuauserv"
        Write-Host "[starting net start bits] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "net start bits"
        Write-Host "[success] software-distribution cleared" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# sccm repair
function Repair-Sccm {
    try {
        Write-Host "[repairing ccm] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "C:\Windows\ccm\ccmrepair.exe"
        Write-Host "[repair initiated in background] ..." -ForegroundColor Green 
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

function Show-WinVersion {
    try {
        $Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion # os release
        $Build = (Get-CimInstance Win32_OperatingSystem).BuildNumber # current build
        $Ubr = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").UBR # unique build revision

        $Output = "[version] Windows $Version [$Build.$Ubr]"
        Write-Host $Output
        Copy-OutputClipboard -Output $Output

    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - device-management #
function Show-MenuDeviceManagement {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "-------- device management --------" 
        Format-Menu -Key "1" -Text "gpupdate" -KeyFg DarkCyan # tested
        Format-Menu -Key "2" -Text "gpresult" -KeyFg DarkCyan # broken
        Format-Menu -Key "3" -Text "system repair" -KeyFg DarkCyan # tested
        Format-Menu -Key "4" -Text "clear recycle bin [all users]" -KeyFg DarkCyan # tested
        Format-Menu -Key "5" -Text "clear inactive user profiles" -KeyFg DarkCyan
        Format-Menu -Key "6" -Text "[unavailable]" -KeyFg DarkCyan # wip
        Format-Menu -Key "7" -Text "[unavailable]" -KeyFg DarkCyan
        Format-Menu -Key "8" -Text "restart" -KeyFg DarkCyan # untested
        Format-Menu -Key "9" -Text "shutdown" -KeyFg DarkCyan # untested
        Format-Menu -Key "0" -Text "logout user" -KeyFg DarkCyan # untested
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg DarkCyan # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg DarkCyan
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) { 
            '1' { Update-GroupPolicy }
            '2' { Get-GpResult }
            '3' { Repair-System } 
            '4' { Clear-RecycleBinAllUsers }
            '5' { Clear-InactiveProfiles } 
            '6' { Show-Unavailable }
            '7' { Show-Unavailable }
            '8' { Restart-Device }
            '9' { Stop-Device }
            '0' { Invoke-Logout }
            'i' { Show-Unavailable }
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}

# gpupdate as user context
# run as scheduled tasks, allowing it to be exectuted from system elevation / backstage
function Update-GroupPolicy {
    try {
        $User = Get-LoggedOnUser # get currently logged in user
        Write-Host "[registering background task] ..." -ForegroundColor Yellow
        # defines the task
        # principal task = determine who runs the task and what privilege level they use 
        # -userid = output of Get-LoggedOnUser. -LogonType Interactive = run inside that user's active session
        $ActionTask = New-ScheduledTaskAction -Execute "gpupdate.exe" -Argument "/force"
        $PrincipalTask = New-ScheduledTaskPrincipal -UserId $User -LogonType Interactive 

        # create, execute, then remove the task
        Register-ScheduledTask -Force -TaskName "SDMS-GpUpdate" -Action $ActionTask -Principal $PrincipalTask | Out-Null 
        Write-Host "[initialising gpupdate /force task for $User] ..." -ForegroundColor Yellow
        Start-ScheduledTask -TaskName "SDMS-GpUpdate"
        Start-Sleep -Seconds 5 # time for script to initialise before task is cleared (will continue running)
        Unregister-ScheduledTask -TaskName "SDMS-GpUpdate" -Confirm:$false # remove task

        Write-Host "[background gpupdate initiated for $User]" -ForegroundColor Green
        Write-Host "[gpupdate will continue running even if this window is closed]" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# system repair - chkdsk, DISM, SFC 
# run commands sequentially. automatically confirm Yes on chkdsk prompt
function Repair-System {
    try {
        Write-Host "[running chkdsk] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand '"Y" | chkdsk C: /f'
        # "Y |" automatically confirm 'Yes' to 'volume to be checked the next time the system restarts?'
        Write-Host "[running dism] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "DISM /online /cleanup-image /restorehealth"    
        Write-Host "[running sfc] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "SFC /SCANNOW"    
        Write-Host "[success] repair complete, restart required" -ForegroundColor Green 
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# clear recycle bin for all users
function Clear-RecycleBinAllUsers {
if (-not (Confirm-Selection -Confirm "this will clear the recycle bin for all users, continue?")) { return }
    try {
        Write-Host "[clearing recycle bin] ..." -ForegroundColor Yellow
        # deletes the recycle bin folder
        Remove-Item -Path "C:\`$Recycle.Bin" -Recurse -Force
        Write-Host "[success] recycle bin cleared for all users" -ForegroundColor Green
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# restart device
function Restart-Device {
    if (-not (Confirm-Selection -Confirm "restart $env:computername, continue?")) { return }
    try {
        Write-Host "[restarting device] ..." -ForegroundColor Yellow
        Restart-Computer -Force
    }
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# shut down device
function Stop-Device {
    if (-not (Confirm-Selection -Confirm "shut down $env:computername, continue?")) { return }
    try {
        Write-Host "[shutting down device] ..." -ForegroundColor Yellow
        Stop-Computer -Force
    }
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# logout current user
function Invoke-Logout {
    $User = Get-LoggedOnUser # get currently logged in user
    if (-not (Confirm-Selection -Confirm "log off $User on $env:computername, continue?")) { return }
    try {
        Write-Host "[logging off $User] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand "shutdown /l"
    }
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - device-info #
function Show-MenuDeviceInfo{
        while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "----------- device info -----------" 
        Format-Menu -Key "1" -Text "all device info" -KeyFg DarkCyan #to-do
        Format-Menu -Key "2" -Text "asset tag / model" -KeyFg DarkCyan # tested
        Format-Menu -Key "3" -Text "uptime" -KeyFg DarkCyan # tested
        Format-Menu -Key "4" -Text "battery report" -KeyFg DarkCyan # tested
        Format-Menu -Key "5" -Text "windows ver" -KeyFg DarkCyan # tested
        Format-Menu -Key "6" -Text "export event logs" -KeyFg DarkCyan # tested
        Format-Menu -Key "7" -Text "drive space available" -KeyFg DarkCyan # tested
        Format-Menu -Key "8" -Text "ram utilisation" -KeyFg DarkCyan # tested
        Format-Menu -Key "9" -Text "logged in sessions" -KeyFg DarkCyan # tested
        Format-Menu -Key "0" -Text "installed printers" -KeyFg DarkCyan # tested
        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg DarkCyan # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg DarkCyan
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) { 
            '1' { Show-Unavailable }
            '2' { Show-DeviceModel }
            '3' { Show-Uptime } 
            '4' { Export-BatteryReport }
            '5' { Show-WinVersion } 
            '6' { Export-EventLogs }
            '7' { Show-DiskSpace }
            '8' { Show-RamUtilization }
            '9' { Show-ActiveSessions }
            'i' { Show-InstalledPrinters }
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}

# show device model / asset
function Show-DeviceModel {
    try {
        Write-Host "[fetching device info] ..." -ForegroundColor Yellow
        Get-CimInstance -ClassName Win32_ComputerSystem | Tee-Object -Variable DeviceModel
# copy output to clipboard        
$Output = @"
$DeviceModel
"@
Copy-OutputClipboard -Output $Output
    }
        catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# show device uptime
function Show-Uptime {
    try {
        try {
            Write-Host "[fetching uptime] ..." -ForegroundColor Yellow
            $Uptime = Get#-Uptime
        }
        catch {
            # Get-Uptime not available on all PS versions
            # Get-CimInstance Win32_OperatingSystem).LastBootUpTime used as fallback 
            Write-Host "[fetching uptime - get-ciminstance win32_operatingsystem).lastbootuptime] ..." -ForegroundColor Yellow
            $LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime 
            $Uptime = (Get-Date) - $LastBoot
        }
        $Uptime = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
        Write-Host ""
        Write-Host "[uptime]: $Uptime"
# copy output to clipboard
$Output = @"
[uptime]: $DeviceModel
"@
Copy-OutputClipboard -Output $Output
        
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# write battery report to c:/temp
function Export-BatteryReport {
    try {
        Confirm-TempFolder
        Write-Host "[running report] ..." -ForegroundColor Yellow
        Invoke-ExternalCommand '& powercfg /batteryreport /output "C:\Temp\battery-report_$Hostname.html"'
        Write-Host "[success] battery report saved to c:\temp\battery-report_$Hostname.html" -ForegroundColor Green
        Open-TempFolder
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# export event logs from for specified timeframe, filter by error / all
function Export-EventLogs {
    Confirm-TempFolder
    # determine timerange in weeks
    $WeeksInput = Read-Host "[number of weeks to export]"
    if ($WeeksInput -notmatch '^\d+$') { # only accept whole numbers
        Write-Host "[error] please enter a valid number" -ForegroundColor Red
        Show-ContinuePrompt
        return
    }

    Format-Menu -Key "1" -Text "faults [critical / warning / error]" -KeyFg Yellow
    Format-Menu -Key "2" -Text "all events" -KeyFg Yellow
    Format-Menu -Key "q" -Text "return" -KeyFg Yellow    
    Write-Host
    $LogTypeSelect = Read-Host "[select]"
    if ($LogTypeSelect -eq 'q') {
        return
    }
    # convert weeks to days (required for Get-WinEvent)
    $WeeksRange = (Get-Date).AddDays(-7 * [int]$WeeksInput)

    try {
        foreach ($LogName in @("Application", "System")) {
            Write-Host "[exporting $LogName log] ..." -ForegroundColor Yellow
            
            $LogParams = @{
                LogName   = $LogName
                StartTime = $WeeksRange
            }
            # filter applied when '[1] - faults' selected, otherwise proceeds without filter (all logs)
            if ($LogTypeSelect -eq '1') {
                $LogParams.Level = 1, 2, 3 # 1 critical, 2 error, 3 warning
            }

            $Events = Get-WinEvent -FilterHashtable $LogParams -ErrorAction SilentlyContinue
            $Events | Export-Csv -Path "C:\Temp\EventLog_$LogName_$Hostname_$Date.csv" -NoTypeInformation -Force
        }
        Write-Host "[success] event logs exported to c:temp" -ForegroundColor Green
        Open-TempFolder
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# show free disk space on C:/
function Show-DiskSpace {
    $DriveLetter = Read-Host "[enter drive letter]"
    # reject inputs that are not a single letter
    if ($DriveLetter -notmatch '^[a-zA-Z]$') { # accepted: a-z, both cases
    Write-Host "[error] enter a single letter only. eg. 'c'" -ForegroundColor Red
    Show-ContinuePrompt
    return
    }
    # add missing colon to drivepath, requires for 'DeviceID='
    $DrivePath = "$DriveLetter" + ":"
    try {
        # check for matching drive
        $Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$DrivePath'"
        # if no matching drive found
        if (-not $Disk) {
            throw "$DrivePath not found"
        }
        # calculate free space
        $FreeGb = [math]::Round($Disk.FreeSpace / 1GB, 2) # convert to gb, round to 2 decimals
        $TotalGb = [math]::Round($Disk.Size / 1GB, 2)

        # color output based on free space
        $Color = if ($FreeGb -lt 10) { "Red" } # <10 gb = red
            elseif ($FreeGb -lt 30) { "DarkYellow" } # <30gb = orange
            else { "Green" } # >30gb = green

        Write-Host "[$DrivePath] $FreeGb gb free / $TotalGb gb total" -ForegroundColor $Color
# copy output to clipboard
$Output = @"
"[$DrivePath] $FreeGb gb free / $TotalGb gb total"
"@
Copy-OutputClipboard -Output $Output
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# display processes using the most memory 
# code edited from: KB0013959
function Show-RamUtilization {
    try {
        # list top processes by ram usage
        $ListSize = 15 # ammount of top processes shown
        $Processes = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First $ListSize Name, 
        @{Name='MemoryMB'; Expression={[math]::Round($_.WorkingSet64 / 1MB, 0)}}
        $Processes | Format-Table -AutoSize

        $Os = Get-CimInstance Win32_OperatingSystem
        $FreeRamGb = [math]::Round($Os.FreePhysicalMemory / 1MB, 2) # round to 2 decimals
        $TotalRamGb = [math]::Round($Os.TotalVisibleMemorySize / 1MB, 2)

        # color output based on free space
        $Color = if ($FreeRamGb -lt 0.5) { "Red" } # <0.5 gb = red
        elseif ($FreeRamGb -lt 1) { "DarkYellow" } # <1 = orange
        else { "Green" } # >1 = green

        # output result 
        Write-Host "[ram] $FreeRamGb gb free / $TotalRamGb gb total" -ForegroundColor $Color
        Write-Host "$Seperator"
# copy free/total space to clipboard
$Output = @"
[ram] $FreeRamGb gb free / $TotalRamGb gb total
"@
Copy-OutputClipboard -Output $Output
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}


# shows all logged on sessions + their connection type
function Show-ActiveSessions {
    try {
        Write-Host "[fetching active sessions] ..." -ForegroundColor Yellow
        # list active sessions
        $Sessions = quser 
        if (-not $Sessions) {
            Write-Host "[no active sessions found]" -ForegroundColor Red
        }
        else {  
            Write-Host ""
            Write-Host "[session details]:" 
            $Sessions | ForEach-Object { Write-Host $_ } 
        }
        $User = Get-LoggedOnUser # owner of explorer.exe 
        Write-Host "" 
        Write-Host "[active desktop user]: $User" 
        Write-Host "$Seperator"
    }
    catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# show installed printers
function Show-InstalledPrinters {
    try {
        Write-Host "[fetching installed printers] ..."
        Get-CimInstance -Class Win32_Printer
    }
        catch {
        Show-ErrorMessage
    }
    Show-ContinuePrompt
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - launchpad  #
# launchpad for quick access to systems / websites that cannot be automated
function Show-MenuLaunchpad {
    while ($true) { 
        Clear-Host 
        Show-TitleBar
        Write-Host ""
        Write-Host "------------ launchpad ------------"
        Format-Menu -Key "1" -Text "c:/temp" -KeyFg DarkGray # tested
        Format-Menu -Key "2" -Text "sd keepass" -KeyFg DarkGray # tested
        Format-Menu -Key "3" -Text "appwiz" -KeyFg DarkGray # tested
        Format-Menu -Key "4" -Text "device manager" -KeyFg DarkGray # tested
        Format-Menu -Key "5" -Text "cert. manager" -KeyFg DarkGray # tested
        Format-Menu -Key "6" -Text "mail profile" -KeyFg DarkGray # tested
        Format-Menu -Key "7" -Text "event viewer" -KeyFg DarkGray # tested
        Format-Menu -Key "8" -Text "hosts file" -KeyFg DarkGray # tested
        Format-Menu -Key "9" -Text "rds" -KeyFg DarkGray # tested
        Format-Menu -Key "0" -Text "sccm config" -KeyFg DarkGray # tested

        Write-Host ""
        Format-Menu -Key "i" -Text "info" -KeyFg DarkGray # to-do
        Format-Menu -Key "q" -Text "return" -KeyFg DarkGray
        Write-Host "$Seperator"
        $Select = Read-Host "[select]" 

        switch ($Select) {
            '1' { Open-TempFolder } 
            '2' { Open-SdKeepass } 
            '3' { Start-AppWiz } 
            '4' { Start-DeviceManager } 
            '5' { Start-CertManager } 
            '6' { Start-MailProfiles }
            '7' { Start-EventViewer }
            '8' { Open-HostsFile }
            '9' { Start-Rds } 
            '0' { Start-SccmManager }          
            'i' { Show-Unavailable }
            'q' { return } 
            default { Show-InvalidSelection }
        }
    }
}

# open service desk keepass
function Open-SdKeepass {
    $KeepassPath = "# redacted #"
    try {
        if (-not (Test-Path $KeepassPath)) {
            throw "cannot locate KeePass vault: $KeepassPath"
        }
        Write-Host "[opening keepass vault] ..." -ForegroundColor Yellow
        Start-Process -FilePath $KeepassPath
        Show-LaunchSuccess
    }
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch application wizard
function Start-AppWiz {
    try {
        Start-Process -FilePath "C:\Windows\System32\appwiz.cpl" #-Verb RunAs
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch device manager
function Start-DeviceManager {
    try {
        Start-Process -FilePath "C:\Windows\System32\devmgmt.msc" -Verb RunAs
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch remote desktop client
function Start-Rds {
    try {
        Start-Process -FilePath "C:\Windows\System32\mstsc.exe"
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch sccm manager
function Start-SccmManager {
    try {
        Start-Process -FilePath "C:/Windows/ccm/smscfgrc.cpl" -Verb RunAs
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch mail profile manager (MLCFG32.CPL)
function Start-MailProfiles {
    # check for Microsoft Office Control Panel applet (MLCFG32.CPL) in 64-bit/32-bit installation paths
    try {
        if (Test-Path "C:\Program Files\Microsoft Office\root\Office16\MLCFG32.CPL") {
            $OfficeCplPath = "C:\Program Files\Microsoft Office\root\Office16\MLCFG32.CPL"
        }
        elseif (Test-Path "C:\Program Files (x86)\Microsoft Office\root\Office16\MLCFG32.CPL") {
            $OfficeCplPath = "C:\Program Files (x86)\Microsoft Office\root\Office16\MLCFG32.CPL"
        }
        else {
            throw "mlcfg32.cpl not found. ensure outlook installed successfully."
        }
    }
    # if test-path fails
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
        return
    }
    # if test-path succeeds
    try {
        # launches through control panel (control.exe)
        Start-Process -FilePath "control.exe" -ArgumentList "`"$OfficeCplPath`""
        Show-LaunchSuccess
    }
    catch {
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch cert. manager
function Start-CertManager {
    try {
        Start-Process -FilePath "C:\Windows\System32\certmgr.msc"
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch event viewer
function Start-EventViewer {
    try {
        Start-Process -FilePath "C:\Windows\System32\eventvwr.msc" -Verb RunAs
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# launch hosts file in notepad
function Open-HostsFile {
    try {
        Start-Process -FilePath "notepad.exe" -ArgumentList "C:\Windows\System32\drivers\etc\hosts" -Verb RunAs
        Show-LaunchSuccess
    }
    catch { 
        Show-ErrorMessage
        Show-ContinuePrompt
    }
}

# ---------------------------------------------------------------------------------------------------- #
# ANCHOR - file-importing #

<# creates arrays containing the content of files, then writes them to the correct files in C:/Temp
will create file if not present, and override it if already existing
discussed with technician in EUC that this is easiest method of implementing this #>

# vpn script file imports
#region
# tennant 1 VPN file import --------------------#
function Write-ScriptVpnTennant1 {
    $Tennant1VpnDeviceTunnel = @' 
# REDACTED # 
'@
    $Tennant1VpnUserTunnel = @'
# REDACTED # 
'@
    $Tennant1VpnDeviceProfile = @'
# REDACTED # 
'@
    $Tennant1VpnUserProfile = @'
# REDACTED # 
'@
    
    try {
        New-Item -Path "C:\Temp\New-AovpnDeviceTunnel.ps1"  -ItemType File -Force -Value $Tennant1VpnDeviceTunnel
        New-Item -Path "C:\Temp\New-AovpnUserTunnel.ps1"    -ItemType File -Force -Value $Tennant1VpnUserTunnel
        New-Item -Path "C:\Temp\DeviceProfile.xml"          -ItemType File -Force -Value $Tennant1VpnDeviceProfile
        New-Item -Path "C:\Temp\UserProfile.xml"            -ItemType File -Force -Value $Tennant1VpnUserProfile
    }
    catch {
        Write-Host "[error] failed to import vpn files: $_" -ForegroundColor Red
        Start-Sleep -($ErrorDelay * 2)
    }
}

# tennant 2 VPN file import --------------------#
function Write-ScriptVpnTennant2 {
    $Tennant2VpnDeviceTunnel = @' 
# REDACTED # 
'@
    $Tennant2VpnUserTunnel = @'
# REDACTED # 
'@
    $Tennant2VpnDeviceProfile = @'
# REDACTED # 
'@
    $Tennant2VpnUserProfile = @'
# REDACTED # 
'@
    
    try {
        New-Item -Path "C:\Temp\New-AovpnDeviceTunnel.ps1"  -ItemType File -Force -Value $Tennant2VpnDeviceTunnel
        New-Item -Path "C:\Temp\New-AovpnUserTunnel.ps1"    -ItemType File -Force -Value $Tennant2VpnUserTunnel
        New-Item -Path "C:\Temp\DeviceProfile.xml"          -ItemType File -Force -Value $Tennant2VpnDeviceProfile
        New-Item -Path "C:\Temp\UserProfile.xml"            -ItemType File -Force -Value $Tennant2VpnUserProfile
    }
    catch {
        Write-Host "[error] failed to import vpn files: $_" -ForegroundColor Red
        Start-Sleep -Milliseconds ($ErrorDelay * 2)
    }
}

# tennant 3 VPN file import --------------------#
function Write-ScriptVpnTennant3 {
    $Tennant1VpnDeviceTunnel = @' 
# REDACTED # 
'@
    $Tennant1VpnUserTunnel = @'
# REDACTED # 
'@
    $Tennant1VpnDeviceProfile = @'
# REDACTED #
'@
    $Tennant1VpnUserProfile = @'
# REDACTED # 
'@

    
    try {
        New-Item -Path "C:\Temp\New-AovpnDeviceTunnel.ps1"  -ItemType File -Force -Value $Tennant1VpnDeviceTunnel
        New-Item -Path "C:\Temp\New-AovpnUserTunnel.ps1"    -ItemType File -Force -Value $Tennant1VpnUserTunnel
        New-Item -Path "C:\Temp\DeviceProfile.xml"          -ItemType File -Force -Value $Tennant1VpnDeviceProfile
        New-Item -Path "C:\Temp\UserProfile.xml"            -ItemType File -Force -Value $Tennant1VpnUserProfile
    }
    catch {
        Write-Host "[error] failed to import vpn files: $_" -ForegroundColor Red
        Start-Sleep -Milliseconds ($ErrorDelay * 2)
    }
}
#endregion

# sccm script file imports
#region
function Write-ScriptSccm {
    $FIXStuckBITSJobs = @'
Set-Service MpsSvc -StartupType Automatic
(Get-Service 'MpsSvc').Start()

$A = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-command &{Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -like "TransientError" } | Remove-BitsTransfer}'
$T = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(10); $t.EndBoundary = (get-date).AddSeconds(20).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable -DeleteExpiredTaskAfter 00:02:00
Register-ScheduledTask -Force -user SYSTEM -TaskName "Fix Stuck BITS" -Action $A -Trigger $T -Settings $S
schtasks /run /tn "Fix Stuck BITS"

$A1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-command &{Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -like "SUSPENDED" } | Resume-BitsTransfer}'
$T1 = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(10); $t.EndBoundary = (get-date).AddSeconds(20).ToString('s')
$S1 = New-ScheduledTaskSettingsSet -StartWhenAvailable -DeleteExpiredTaskAfter 00:02:00
Register-ScheduledTask -Force -user SYSTEM -TaskName "Resume BITS" -Action $A1 -Trigger $T1 -Settings $S1
schtasks /run /tn "Resume BITS"
'@
    $FIXWindowsUpdate = @'
## reset windows update

Write-Host "1. Stopping Windows Update Services..." 
Stop-Service -Name BITS 
Stop-Service -Name wuauserv 
Stop-Service -Name appidsvc 
Stop-Service -Name cryptsvc 
 
Write-Host "2. Remove QMGR Data file..." 
Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue 
 
Write-Host "3. Renaming the Software Distribution and CatRoot Folder..." 
Remove-Item $env:systemroot\SoftwareDistribution -ErrorAction SilentlyContinue -recurse
Remove-Item $env:systemroot\System32\Catroot2 -ErrorAction SilentlyContinue -recurse
Remove-item "C:\ProgramData\application data\Microsoft\Network\Downloader.old" -ErrorAction SilentlyContinue
rename-item "C:\ProgramData\application data\Microsoft\Network\Downloader" downloader.old

Write-Host "4. Removing old Windows Update log..." 
Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue 
 
Write-Host "5. Resetting the Windows Update Services to defualt settings..." 
sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 
sc.exe sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 
 
Set-Location $env:systemroot\system32 
 
Write-Host "6. Registering some DLLs..." 
regsvr32.exe /s atl.dll 
regsvr32.exe /s urlmon.dll 
regsvr32.exe /s mshtml.dll 
regsvr32.exe /s shdocvw.dll 
regsvr32.exe /s browseui.dll 
regsvr32.exe /s jscript.dll 
regsvr32.exe /s vbscript.dll 
regsvr32.exe /s scrrun.dll 
regsvr32.exe /s msxml.dll 
regsvr32.exe /s msxml3.dll 
regsvr32.exe /s msxml6.dll 
regsvr32.exe /s actxprxy.dll 
regsvr32.exe /s softpub.dll 
regsvr32.exe /s wintrust.dll 
regsvr32.exe /s dssenh.dll 
regsvr32.exe /s rsaenh.dll 
regsvr32.exe /s gpkcsp.dll 
regsvr32.exe /s sccbase.dll 
regsvr32.exe /s slbcsp.dll 
regsvr32.exe /s cryptdlg.dll 
regsvr32.exe /s oleaut32.dll 
regsvr32.exe /s ole32.dll 
regsvr32.exe /s shell32.dll 
regsvr32.exe /s initpki.dll 
regsvr32.exe /s wuapi.dll 
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wuaueng1.dll 
regsvr32.exe /s wucltui.dll 
regsvr32.exe /s wups.dll 
regsvr32.exe /s wups2.dll 
regsvr32.exe /s wuweb.dll 
regsvr32.exe /s qmgr.dll 
regsvr32.exe /s qmgrprxy.dll 
regsvr32.exe /s wucltux.dll 
regsvr32.exe /s muweb.dll 
regsvr32.exe /s wuwebv.dll 
 
Write-Host "7) Removing WSUS client settings..." 
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f 
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f 
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f 
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientIDValidation /f
Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name SusClientIdValidation 
Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate WUServer 
Remove-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate WUStatusServer 



if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DOMaxDownloadBandwidth' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DOMaxUploadBandwidth' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DOPercentageMaxBackgroundBandwidth' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DOPercentageMaxDownloadBandwidth' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DOPercentageMaxForegroundBandwidth' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DORestrictPeerSelectionBy' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'AcceptTrustedPublisherCerts' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'SetAutoRestartNotificationConfig' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'AutoRestartNotificationSchedule' -Value 15 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'SetAutoRestartNotificationDisable' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'SetAutoRestartRequiredNotificationDismissal' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'AutoRestartRequiredNotificationDismissal' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'SetRestartWarningSchd' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ScheduleRestartWarning' -Value 4 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ScheduleImminentRestartWarning' -Value 15 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'DeferFeatureUpdatesPeriodInDays' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'PauseFeatureUpdatesStartTime' -Value "" -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ManagePreviewBuilds' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ManagePreviewBuildsPolicyValue' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'DoNotAllowSP' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoUpdate' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'AUOptions' -Value 3 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'ScheduledInstallDay' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'ScheduledInstallTime' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'ScheduledInstallEveryWeek' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'AllowMUUpdateService' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'EnableFeaturedSoftware' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'IncludeRecommendedUpdates' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'RebootRelaunchTimeoutEnabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'RebootRelaunchTimeout' -Value 15 -PropertyType DWord -Force -ea SilentlyContinue;

Write-Host "8) Resetting the WinSock..." 
netsh winsock reset 
netsh winhttp reset proxy 
 
Write-Host "9) Delete all BITS jobs..." 
import-module bitstransfer
Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -like 'TransientError' } | Remove-BitsTransfer
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value '*' -force
Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -like 'SUSPENDED' } | Resume-BitsTransfer

netsh branchcache reset 
netsh branchcache set service mode=DISTRIBUTED
gpupdate.exe /Force
Write-Host "11) Starting Windows Update Services..." 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc 
 
 
Write-Host "12) Forcing discovery..." 
wuauclt.exe /ResetAuthorization /DetectNow
wuauclt /reportnow

 ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000021}')
 ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}')
 ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000024}')
 ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000023}')
 (New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState()
'@
    $FIXWUAandMWerros = @'
#FIX bad WUA location and missing MW's and "Waiting for turn to start updates." errors
if(Select-String "c:\windows\ccm\logs\UpdatesDeployment.log" -pattern "Waiting for turn to start updates." -quiet){
	Remove-Item 'C:\Windows\System32\GroupPolicy\*' -Force -recurse
	Rename-Item -path "c:\windows\ccm\logs\UpdatesDeployment.log" -NewName "UpdatesDeployment-old.log" -force
	Restart-Service 'ccmexec'
	#Remove SG Lock
	$query = "select * from CCM_PrePostActions"; gwmi -Namespace ROOT\ccm\Policy\Machine\RequestedConfig -Query $query | rwmi; gwmi -Namespace ROOT\ccm\Policy\Machine\ActualConfig -Query $query | rwmi
	
	Get-TroubleshootingPack -Path "C:\Windows\diagnostics\system\WindowsUpdate" | Invoke-TroubleshootingPack -Unattended
	Restart-Service 'wuauserv'
	#location refreash
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000012}')
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000024}')
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000023}')

	#MP Refreash
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000021}')
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000022}')
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000042}')
	 
	wuauclt.exe /ResetAuthorization /DetectNow
	wuauclt /reportnow

	#update scan
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}')
	([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}')
	 (New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState()

	#install all
	 ([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates([System.Management.ManagementObject[]] (get-wmiobject -query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK'))
	 
    "FIXING ERROR"
}else{
	#install all
	([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates([System.Management.ManagementObject[]] (get-wmiobject -query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK'))
    "NO ERROR FOUND"
}

 
'@
    $SCCMResetInventory = @'
$HardwareInventoryID = '{00000000-0000-0000-0000-000000000001}'
Get-WmiObject -Namespace 'Root\CCM\INVAGT' -Class 'InventoryActionStatus' -Filter "InventoryActionID='$HardwareInventoryID'" | Remove-WmiObject
$HardwareInventoryID = '{00000000-0000-0000-0000-000000000002}'
Get-WmiObject -Namespace 'Root\CCM\INVAGT' -Class 'InventoryActionStatus' -Filter "InventoryActionID='$HardwareInventoryID'" | Remove-WmiObject
$HardwareInventoryID = '{00000000-0000-0000-0000-000000000003}'
Get-WmiObject -Namespace 'Root\CCM\INVAGT' -Class 'InventoryActionStatus' -Filter "InventoryActionID='$HardwareInventoryID'" | Remove-WmiObject
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000001}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000002}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000003}')
([wmiclass]'ROOT\ccm:SMS_Client').ResetPolicy(1)
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000040}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000021}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000022}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000112}')
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000111}')
(New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState()
(start-process C:\Windows\CCM\ccmeval.exe -PassThru).Id

'@
    $SCCMUpateScan = @'
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}');
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}')  | out-null; "Initiating a full update scan and deployment evaluation...";
(New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState();
wuauclt.exe /ResetAuthorization /DetectNow;
wuauclt /reportnow
'@

    try {
        New-Item -Path "C:\Temp\FIX-StuckBITSJobs.ps1"          -ItemType File -Force -Value $FIXStuckBITSJobs
        New-Item -Path "C:\Temp\FIX-WindowsUpdate.ps1"          -ItemType File -Force -Value $FIXWindowsUpdate
        New-Item -Path "C:\Temp\FIX-WUAandMWerros.ps1"          -ItemType File -Force -Value $FIXWUAandMWerros
        New-Item -Path "C:\Temp\SCCM-ResetInventory.ps1"        -ItemType File -Force -Value $SCCMResetInventory
        New-Item -Path "C:\Temp\SCCM-UpateScan.ps1"             -ItemType File -Force -Value $SCCMUpateScan
        
    }
    catch {
        Write-Host "[error] failed to import sccm scripts: $_" -ForegroundColor Red
        Start-Sleep -Milliseconds ($ErrorDelay * 2)
    }
}
#endregion

Show-MenuMain

