# filename: setup.ps1 (can be run via powershell
# Set Windows Time service to run automatically
Set-Service -Name W32Time -Status running -StartupType automatic

# install scoop
set-executionpolicy remotesigned -scope currentuser  # [Needs an AcceptAll option]
# confirm with A (all)
iwr -useb get.scoop.sh | iex

# Install WSL
# wsl --install # requires reboot
# wsl --install -d debian

# install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Check if Scoop is installed
if (!(Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-Error "Scoop is not installed. Please install Scoop before running this script."
    exit 1
}

# List of buckets to add
$buckets = @(
    "main",
    "extras",
    "versions",
    "nonportable",
    "nerd-fonts",
    "java",
    "games",
    "charm https://github.com/charmbracelet/scoop-bucket.git"
)
# preparation of requirements
scoop install main/git-with-openssh # git, ssh, ssh-copy-id & required for buckets

# Add each bucket
foreach ($bucket in $buckets) {
    try {
        # Check if the bucket already exists
        $existingBuckets = scoop bucket list | Select-String -Pattern $bucket
        if ($existingBuckets) {
            Write-Output "Bucket '$bucket' is already added."
        } else {
            Write-Output "Adding bucket '$bucket'..."
            scoop bucket add $bucket
        }
    } catch {
        Write-Error "Failed to add bucket '$bucket': $_"
    }
}

Write-Output "All buckets processed."

scoop install main/winget

# CLI Tools & Apps
scoop install main/starship
scoop install main/gsudo # elevate specific commands to admin
scoop install main/ffmpeg # transcoder similar to handbrake in cli
scoop install main/hugo-extended # static website generator
#scoop install main/rclone # like syncthing
scoop install main/restic # simple backup utility
scoop install main/wget # downloader
scoop install main/curl
scoop install main/uutils-coreutils # GNU coreutils compiled in Rust
scoop install main/7zip # compressor, extracter
scoop install main/neovim
scoop install main/helix
scoop install main/zoxide # cd on steroides
scoop install main/fzf
scoop install main/fd
scoop install extras/winmtr # GUI interface pops up, ping + traceroute functions
scoop install main/nmap
scoop install main/bottom # like htop, top, or btop
scoop install main/bat # cat replacement
scoop install main/chezmoi # cross-platform, GNU stow alternative
scoop install main/nu
scoop install main/eza # exa, ls replacement
scoop install main/file
scoop install main/grep
scoop install main/ripgrep
scoop install main/bitwarden-cli
scoop install main/gawk # awk utility
scoop install main/which

# GUI tools
# Productivity
scoop install extras/pdfsam # PDF manipulator
scoop install extras/flameshot
scoop install extras/flow-launcher
scoop install extras/everything
scoop install extras/thunderbird
scoop install extras/onecommander
scoop install extras/simplenote

# Development
scoop install extras/vscodium # code IDE editor
scoop install extras/lapce # Code Editor written in Rust
scoop install versions/firefox-developer
scoop install extras/windows-terminal # windows foss terminal
scoop install extras/wezterm # rust gpu terminal
# scoop install extras/rio # rust terminal
# scoop install extras/alacritty # rust gpu terminal
scoop install nonportable/virtualbox-np # Requires Admin Privileges
winget install -e --id Microsoft.PowerShell
scoop install wishlist # ssh directory based on ssh config

# Media Consumption and Editing
#scoop install vlc # media player
scoop install extras/mpc-qt
scoop install extras/jellyfin-mpv-shim
scoop install extras/makemkv
scoop install extras/handbrake

# Utilities
scoop install extras/teamviewer
scoop install extras/etcher # USB burner
scoop install extras/windirstat
scoop install extras/bitwarden # password management
#scoop install mremoteng # remote connnections manager
scoop install extras/clamav
scoop install extras/quicklook # bring macOS quick look feature to Win
scoop install extras/komorebi # tiling window manager
scoop install extras/whkd # keyboard shortcut daemon
# to start komorebi: 
# komorebic quickstart
# komorebic start --whkd
scoop install extras/f.lux
scoop install extras/painter
winget install -e --id Beeper.Beeper

# Gaming
scoop install extras/playnite # games curator of clients like Steam and Ubisoft
scoop install extras/nvcleanstall
scoop install nonportable/logitech-gaming-software-np
scoop install versions/steam
scoop install games/battlenet
winget install -e --id Corsair.iCUE.4

# internet & file management tools
# scoop install extras/pia-desktop # This didn't work
winget install -e --id PrivateInternetAccess.PrivateInternetAccess
scoop install extras/winscp # FTP, SFTP client
scoop install extras/librewolf
scoop install extras/nextcloud
winget install -e --id tailscale.tailscale
# scoop install extras/tailscale # This didn't work
# reg import "C:\Users\devboer\scoop\apps\tailscale\current\add-startup.reg"
scoop install extras/transmission

# fonts
scoop install nerd-fonts/AnonymousPro-NF-Mono
scoop install nerd-fonts/Hack-NF-Mono
scoop install nerd-fonts/FiraCode-NF-Mono
scoop install nerd-fonts/JetBrainsMono-NF-Mono
scoop install nerd-fonts/Meslo-NF-Mono

# from chatgpt to clean up Lines 56 to 157
# Define categories of tools and their associated buckets
$tools = @{
    "cliTools" = @(
        "main/starship",
        "main/gsudo",
        "main/ffmpeg",
        "main/hugo-extended",
        # "main/rclone", # Uncomment if needed
        "main/restic",
        "main/wget",
        "main/curl",
        "main/uutils-coreutils",
        "main/7zip",
        "main/neovim",
        "main/helix",
        "main/zoxide",
        "main/fzf",
        "main/fd",
        "extras/winmtr",
        "main/nmap",
        "main/bottom",
        "main/bat",
        "main/chezmoi",
        "main/nu",
        "main/eza",
        "main/file",
        "main/grep",
        "main/ripgrep",
        "main/bitwarden-cli",
        "main/gawk",
        "main/which"
    )
    " guiProductivity" = @(
        "extras/pdfsam",
        "extras/flameshot",
        "extras/flow-launcher",
        "extras/everything",
        "extras/thunderbird",
        "extras/onecommander",
        "extras/simplenote"
    )
    "guiDevelopment" = @(
        "extras/vscodium",
        "extras/lapce",
        "versions/firefox-developer",
        "extras/windows-terminal",
        "extras/wezterm",
        "nonportable/virtualbox-np"
    )
    "guiCreative" = @(
        "extras/vlc",
        "extras/mpc-qt",
        "extras/jellyfin-mpv-shim",
        "extras/makemkv",
        "extras/handbrake"
    )
    "guiUtilities" = @(
        "extras/teamviewer",
        "extras/etcher",
        "extras/windirstat",
        "extras/bitwarden",
        # "mremoteng", # Uncomment if needed
        "extras/clamav",
        "extras/quicklook",
        "extras/komorebi",
        "extras/whkd",
        "extras/f.lux",
        "extras/painter"
    )
    "guiGaming" = @(
        "extras/playnite",
        "extras/nvcleanstall",
        "nonportable/logitech-gaming-software-np",
        "versions/steam",
        "games/battlenet"
    )
    "guiFiles" = @(
        "extras/winscp",
        "extras/librewolf",
        "extras/nextcloud",
        "extras/transmission"
    )
    "Fonts" = @(
        "nerd-fonts/AnonymousPro-NF-Mono",
        "nerd-fonts/Hack-NF-Mono",
        "nerd-fonts/FiraCode-NF-Mono",
        "nerd-fonts/JetBrainsMono-NF-Mono",
        "nerd-fonts/Meslo-NF-Mono"
    )
}

# Additional installations with Winget
$wingetInstallations = @(
    "Microsoft.PowerShell",
    "Beeper.Beeper",
    "Corsair.iCUE.4",
    "PrivateInternetAccess.PrivateInternetAccess",
    "tailscale.tailscale"
)


# Install tools by category
foreach ($category in $tools.GetEnumerator()) {
    Write-Output "Installing tools for $($category.Key)..."
    foreach ($tool in $category.Value) {
        Write-Output "Installing $tool..."
        scoop install $tool
    }
}

# Install additional packages via Winget
Write-Output "Installing tools with Winget..."
foreach ($package in $wingetInstallations) {
    winget install -e --id $package
}

Write-Output "Installation process completed!"




# Manually Install the Following:
# anytype
# filejuggler
