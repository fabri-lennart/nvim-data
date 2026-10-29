# Run from PowerShell: powershell -ExecutionPolicy Bypass -File .\bootstrap-windows.ps1
# Requires a GitHub SSH key with access to fabri-lennart/nvim-data.
$ErrorActionPreference = 'Stop'
$repo = 'git@github.com:fabri-lennart/nvim-data.git'
$configDir = Join-Path $env:LOCALAPPDATA 'nvim'
$dataDir = Join-Path $env:LOCALAPPDATA 'nvim-data'

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
        [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Add-UserPath([string]$directory) {
    if (-not (Test-Path -LiteralPath $directory)) { return }
    $current = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($current -split ';') -notcontains $directory) {
        [Environment]::SetEnvironmentVariable('Path', ($current.TrimEnd(';') + ';' + $directory), 'User')
    }
    Refresh-Path
}

function Install-Tool([string]$command, [string]$package) {
    Refresh-Path
    if (Get-Command $command -ErrorAction SilentlyContinue) { return }
    Write-Host "Installing $package..."
    & winget install --id $package --exact --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "winget could not install $package" }
    Refresh-Path
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required. Install App Installer from Microsoft first.'
}

Install-Tool 'git' 'Git.Git'
Install-Tool 'nvim' 'Neovim.Neovim'
Install-Tool 'go' 'GoLang.Go'
Install-Tool 'node' 'OpenJS.NodeJS.22'
Install-Tool 'python' 'Python.Python.3.12'
Install-Tool 'rg' 'BurntSushi.ripgrep.MSVC'
Install-Tool 'fd' 'sharkdp.fd'
Install-Tool 'lazygit' 'JesseDuffield.lazygit'
Install-Tool 'yazi' 'sxyazi.yazi'
Install-Tool 'zig' 'zig.zig'
Install-Tool 'magick' 'ImageMagick.ImageMagick'
Install-Tool 'gcloud' 'Google.CloudSDK'

Add-UserPath 'C:\Program Files\Neovim\bin'
Add-UserPath 'C:\Program Files\Go\bin'
Add-UserPath (Join-Path $env:USERPROFILE 'go\bin')
Add-UserPath (Join-Path $env:APPDATA 'npm')
Add-UserPath (Join-Path $env:LOCALAPPDATA 'Google\Cloud SDK\google-cloud-sdk\bin')

if (Test-Path -LiteralPath $configDir) {
    if (-not (Test-Path -LiteralPath (Join-Path $configDir '.git'))) {
        throw "$configDir exists but is not a Git checkout. Back it up manually before running this script."
    }
    $origin = & git -C $configDir remote get-url origin
    if ($origin -ne $repo) { throw "Unexpected Git remote: $origin" }
    if (& git -C $configDir status --porcelain) {
        throw "$configDir has local changes. Commit or stash them before updating."
    }
    & git -C $configDir pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw 'Could not update Neovim config' }
} else {
    & git clone $repo $configDir
    if ($LASTEXITCODE -ne 0) { throw 'SSH clone failed; check your GitHub SSH key' }
}

# nvim-data is Neovim's plugin/cache directory. Never move it to install the config.
Write-Host "Config: $configDir"
Write-Host "Plugin data: $dataDir"

& python -m pip install --user pynvim jupyter_client ipykernel jupytext black debugpy sqlfmt ruff
if ($LASTEXITCODE -ne 0) { throw 'Python dependency installation failed' }
& npm.cmd install -g typescript typescript-language-server prettier
if ($LASTEXITCODE -ne 0) { throw 'Node dependency installation failed' }
& go install golang.org/x/tools/gopls@latest
if ($LASTEXITCODE -ne 0) { throw 'gopls installation failed' }
& go install github.com/go-delve/delve/cmd/dlv@latest
if ($LASTEXITCODE -ne 0) { throw 'Delve installation failed' }
& go install golang.org/x/tools/cmd/goimports@latest
if ($LASTEXITCODE -ne 0) { throw 'goimports installation failed' }

& nvim --headless '+Lazy! sync' '+qa'
if ($LASTEXITCODE -ne 0) { throw 'Neovim plugin sync failed' }
& nvim --headless '+UpdateRemotePlugins' '+qa'
if ($LASTEXITCODE -ne 0) { throw 'Neovim Python plugin registration failed' }
& nvim --headless '+MasonInstall js-debug-adapter' '+lua vim.wait(120000, function() return require("mason-registry").is_installed("js-debug-adapter") end, 1000)' '+qa'
if ($LASTEXITCODE -ne 0) { throw 'JavaScript debug adapter installation failed' }
$jsAdapter = Join-Path $dataDir 'mason\packages\js-debug-adapter\js-debug\src\dapDebugServer.js'
if (-not (Test-Path -LiteralPath $jsAdapter)) { throw 'JavaScript debug adapter file is missing' }

$check = & nvim --headless '+lua print("CONFIG=" .. vim.fn.stdpath("config") .. " THEME=" .. tostring(vim.g.colors_name))' '+qa' 2>&1
if (($check -join "`n") -notmatch 'THEME=kanagawa') { throw "Neovim verification failed: $check" }
Write-Host 'Neovim is ready. Restart Nushell, then run nvim.'
Write-Host 'Run gcloud init separately to sign in and select a Google Cloud project.'
