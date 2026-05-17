$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

$iconPng = Join-Path $PSScriptRoot "assets\logo\Nextdeck logo.png"
$iconIco = Join-Path $PSScriptRoot "assets\icons\NextDeck.ico"
$roundedPng = Join-Path $PSScriptRoot "assets\icons\NextDeck-rounded.png"
$assetsDir = Join-Path $PSScriptRoot "assets"
$distDir = Join-Path $PSScriptRoot "dist"
$exePath = Join-Path $distDir "NextDeck.exe"
$workDir = Join-Path $env:TEMP "NextDeck-pyinstaller-work"
$specDir = Join-Path $env:TEMP "NextDeck-pyinstaller-spec"

if (Test-Path $iconPng) {
    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Bitmap]::FromFile($iconPng)
    $size = 256
    $radius = 72
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(0, 0, $radius, $radius, 180, 90)
    $path.AddArc($size - $radius, 0, $radius, $radius, 270, 90)
    $path.AddArc($size - $radius, $size - $radius, $radius, $radius, 0, 90)
    $path.AddArc(0, $size - $radius, $radius, $radius, 90, 90)
    $path.CloseFigure()
    $graphics.SetClip($path)
    $graphics.DrawImage($source, 0, 0, $size, $size)
    $bitmap.Save($roundedPng, [System.Drawing.Imaging.ImageFormat]::Png)

    $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
    $stream = [System.IO.File]::Open($iconIco, [System.IO.FileMode]::Create)
    $icon.Save($stream)
    $stream.Close()
    $icon.Dispose()
    $path.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
    $source.Dispose()
}

if (Test-Path $exePath) {
    try {
        Remove-Item -LiteralPath $exePath -Force
    }
    catch {
        throw "Could not replace dist\NextDeck.exe. Close NextDeck if it is open, then run build_app.ps1 again."
    }
}

$args = @(
    "-m", "PyInstaller",
    "--noconfirm",
    "--clean",
    "--windowed",
    "--onefile",
    "--name", "NextDeck",
    "--distpath", $distDir,
    "--workpath", $workDir,
    "--specpath", $specDir,
    "--add-data", "${assetsDir};assets"
)

if (Test-Path $iconIco) {
    $args += @("--icon", $iconIco)
}

$args += "app.py"

python @args
