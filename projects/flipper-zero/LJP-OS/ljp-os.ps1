<#
LJP-OS helper. The official firmware source is NOT stored in git (it's ~280 MB);
it's cloned into .\firmware\ at a pinned release, and LJP-OS's changes live in
.\patches\ljp-os.patch.

  .\ljp-os.ps1 setup    clone the pinned upstream release into .\firmware and apply the patch
  .\ljp-os.ps1 build    build the flashable update package (dist\ in firmware\)
  .\ljp-os.ps1 flash    build and install over USB (qFlipper must be closed)
  .\ljp-os.ps1 save     export your edits in .\firmware back into .\patches\ljp-os.patch
  .\ljp-os.ps1 reset    throw away edits in .\firmware and re-apply the saved patch
#>
param([Parameter(Position = 0)][ValidateSet("setup", "build", "flash", "save", "reset")][string]$Command = "build")

$ErrorActionPreference = "Stop"
$Upstream = "https://github.com/flipperdevices/flipperzero-firmware.git"
$UpstreamTag = "1.5.1"
$Root = $PSScriptRoot
$Fw = Join-Path $Root "firmware"
$Patch = Join-Path $Root "patches\ljp-os.patch"

function Invoke-Git { & git -C $Fw @args; if ($LASTEXITCODE) { throw "git $args failed" } }
function Invoke-Fbt { Push-Location $Fw; try { & (Join-Path $Fw "fbt.cmd") @args; if ($LASTEXITCODE) { throw "fbt $args failed" } } finally { Pop-Location } }

function Apply-Patch {
    if ((Test-Path $Patch) -and (Get-Item $Patch).Length -gt 0) {
        Invoke-Git apply --whitespace=nowarn $Patch
        Write-Host "Applied $Patch"
    }
}

switch ($Command) {
    "setup" {
        if (Test-Path $Fw) { throw "$Fw already exists; use 'reset' to re-apply the patch" }
        & git clone --depth 1 --branch $UpstreamTag --recurse-submodules --shallow-submodules $Upstream $Fw
        if ($LASTEXITCODE) { throw "clone failed" }
        Apply-Patch
    }
    # Release flags, same as official builds (debug builds are larger and slower)
    "build" { Invoke-Fbt COMPACT=1 DEBUG=0 updater_package }
    "flash" { Invoke-Fbt COMPACT=1 DEBUG=0 flash_usb_full }
    "save" {
        # Stage everything (including new files) so it lands in the diff, then unstage.
        Invoke-Git add -A
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
