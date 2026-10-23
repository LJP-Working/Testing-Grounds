<#
LJP-OS helper. The official firmware source is NOT stored in git (it's ~280 MB);
it's cloned into .\firmware\ at a pinned release, and LJP-OS's changes live in
.\patches\ljp-os.patch.

  .\ljp-os.ps1 setup    clone the pinned upstream release into .\firmware and apply the patch
  .\ljp-os.ps1 build    build the flashable update package (dist\ in firmware\), bundling
                        every app in -AppsSource (default: your flipper-custom apps)
  .\ljp-os.ps1 flash    build and install over USB (qFlipper must be closed)
  .\ljp-os.ps1 save     export your edits in .\firmware back into .\patches\ljp-os.patch
  .\ljp-os.ps1 reset    throw away edits in .\firmware and re-apply the saved patch
#>
param(
    [Parameter(Position = 0)][ValidateSet("setup", "build", "flash", "save", "reset")][string]$Command = "build",
    [string]$AppsSource = "C:\dev\flipper\flipper-custom\apps"
)

$ErrorActionPreference = "Stop"
$Upstream = "https://github.com/flipperdevices/flipperzero-firmware.git"
$UpstreamTag = "1.5.1"
$Root = $PSScriptRoot
$Fw = Join-Path $Root "firmware"
$Patch = Join-Path $Root "patches\ljp-os.patch"
$UserApps = Join-Path $Fw "applications_user"
# Bundled app copies live here at build time and are never part of the patch
$UserAppsExclude = ":(exclude,glob)applications_user/*/**"

function Invoke-Git { & git -C $Fw @args; if ($LASTEXITCODE) { throw "git $args failed" } }
function Invoke-Fbt {
    # fbt prints warnings to stderr; only its exit code should fail the build
    $ErrorActionPreference = "Continue"
    Push-Location $Fw
    try { & (Join-Path $Fw "fbt.cmd") @args 2>&1 | ForEach-Object { "$_" }; if ($LASTEXITCODE) { throw "fbt $args failed" } }
    finally { Pop-Location }
}

function Apply-Patch {
    if ((Test-Path $Patch) -and (Get-Item $Patch).Length -gt 0) {
        Invoke-Git apply --whitespace=nowarn $Patch
        Write-Host "Applied $Patch"
    }
}

# Copy each app (a folder with application.fam) from $AppsSource into
# applications_user\ and return their appids for --extra-ext-apps
function Sync-Apps {
    Get-ChildItem $UserApps -Directory | Remove-Item -Recurse -Force
    if (-not (Test-Path $AppsSource)) {
        Write-Host "No apps bundled: $AppsSource not found"
        return @()
    }
    $appids = @()
    foreach ($app in Get-ChildItem $AppsSource -Directory) {
        $fam = Join-Path $app.FullName "application.fam"
        if (-not (Test-Path $fam)) { continue }
        $match = Select-String -Path $fam -Pattern 'appid\s*=\s*"([^"]+)"' | Select-Object -First 1
        if (-not $match) { continue }
        $dest = Join-Path $UserApps $app.Name
        Copy-Item $app.FullName $dest -Recurse
        # ufbt build output from the app's own repo
        Remove-Item (Join-Path $dest "dist") -Recurse -Force -ErrorAction SilentlyContinue
        $appids += $match.Matches[0].Groups[1].Value
    }
    Write-Host "Bundling apps: $($appids -join ', ')"
    return $appids
}

function Get-BuildArgs {
    # Release flags, same as official builds (debug builds are larger and slower)
    $buildArgs = @("COMPACT=1", "DEBUG=0")
    $appids = @(Sync-Apps)
    if ($appids.Count) { $buildArgs += "--extra-ext-apps=$($appids -join ',')" }
    return $buildArgs
}

switch ($Command) {
    "setup" {
        if (Test-Path $Fw) { throw "$Fw already exists; use 'reset' to re-apply the patch" }
        & git clone --depth 1 --branch $UpstreamTag --recurse-submodules --shallow-submodules $Upstream $Fw
        if ($LASTEXITCODE) { throw "clone failed" }
        Apply-Patch
    }
    "build" { $buildArgs = Get-BuildArgs; Invoke-Fbt @buildArgs updater_package }
    "flash" { $buildArgs = Get-BuildArgs; Invoke-Fbt @buildArgs flash_usb_full }
    "save" {
        # Stage everything (including new files) so it lands in the diff, then unstage.
        Invoke-Git add -A -- . $UserAppsExclude
        $diff = & git -C $Fw diff --cached --binary
        Invoke-Git reset -q
        New-Item -ItemType Directory -Force (Split-Path $Patch) | Out-Null
        [IO.File]::WriteAllText($Patch, (($diff -join "`n") + "`n"))
        Write-Host "Saved $Patch"
    }
    "reset" {
        Invoke-Git reset -q --hard
        Invoke-Git clean -fdq
        Apply-Patch
    }
}
