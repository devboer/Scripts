# Function to write colored output
function Write-ColorOutput {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    $colorMap = @{
        "Green" = "32"
        "Red"   = "31"
    }
    $colorCode = $colorMap[$Color]
    Write-Host -ForegroundColor $Color $Message
}

# Check if the script is running as administrator
Function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-ColorOutput -Message "This script requires administrative privileges. Restarting with elevated permissions..." -Color "Red"
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Script continues from here with elevated privileges
Write-ColorOutput -Message "Running as administrator. Continuing with the script..." -Color "Green"

# Run the updates
try {
    Write-Output "Updating Scoop packages..."
    scoop update --all

    Write-Output "Updating Winget packages..."
    winget upgrade --all

 #   Write-Output "Updating Chocolatey packages..."
 #   choco upgrade all --yes

 # Windows Update Section

    # Install Windows Update Module if not present
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Output "Installing PSWindowsUpdate module..."
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
    }

    # Import the module
    Import-Module PSWindowsUpdate

    # Check for available updates
    $updates = Get-WindowsUpdate
    if ($updates) {
        Write-Output "Updates found. Installing updates..."
        Install-WindowsUpdate -AcceptAll -AutoReboot
    } else {
        Write-Output "No updates found."
    }
} catch {
    Write-Error "Failed to perform Windows Updates: $_"
}

Write-Output "System updates completed successfully."
