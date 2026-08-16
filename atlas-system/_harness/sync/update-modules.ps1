<#
.SYNOPSIS
    Propaga los ficheros compartidos de la plantilla del harness (docs de convenciones
    y configuracion del formatter) a todos los modulos ya registrados.

.DESCRIPTION
    Sobrescribe unicamente los ficheros compartidos listados en $sharedFiles en cada
    modulo registrado en registry.json. CLAUDE.md, README.md y el resto del proyecto
    NO se tocan - son propiedad del modulo y evolucionan de forma independiente.

    Si un modulo tiene cambios locales sin commitear en esos ficheros, se avisa y se omite,
    para no pisar trabajo en curso sin que el usuario lo sepa.

.PARAMETER Commit
    Si se indica, crea un commit automatico en cada modulo actualizado
    ("chore: sync shared files from harness template vX").

.EXAMPLE
    ./update-modules.ps1
    ./update-modules.ps1 -Commit
#>

param(
    [switch]$Commit
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$harnessDir = Split-Path -Parent $scriptDir
$templateDir = Join-Path $harnessDir "template"
$registryPath = Join-Path $harnessDir "registry.json"

$registry = Get-Content -Raw -LiteralPath $registryPath | ConvertFrom-Json
$templateVersion = $registry.templateVersion

$sharedFiles = @(
    "docs/architecture.md",
    "docs/stack.md",
    "docs/conventions.md",
    "docs/ddd-conventions.md",
    "docs/cqrs-conventions.md",
    "docs/id-conventions.md",
    "docs/error-conventions.md",
    "docs/rich-domain-conventions.md",
    "docs/repository-conventions.md",
    "docs/enum-conventions.md",
    "docs/mapping-conventions.md",
    "docs/testing-conventions.md",
    "docs/validation-specification-conventions.md",
    "docs/logging-conventions.md",
    "config/formatter.properties"
)

if (-not $registry.modules -or $registry.modules.Count -eq 0) {
    Write-Host "No hay modulos registrados todavia. Nada que sincronizar." -ForegroundColor Yellow
    return
}

foreach ($module in $registry.modules) {
    $modulePath = $module.path

    if (-not (Test-Path $modulePath)) {
        Write-Host "[$($module.name)] Ruta no encontrada ($modulePath) - omitido." -ForegroundColor Yellow
        continue
    }

    Push-Location $modulePath
    try {
        $dirty = $false
        foreach ($file in $sharedFiles) {
            if (Test-Path $file) {
                $status = git status --porcelain -- $file
                if ($status) { $dirty = $true }
            }
        }

        if ($dirty) {
            Write-Host "[$($module.name)] Cambios locales sin commitear en ficheros compartidos - omitido, revisalo manualmente." -ForegroundColor Yellow
            continue
        }

        $changed = $false
        foreach ($file in $sharedFiles) {
            $src = Join-Path $templateDir ($file -replace "/", "\")
            $dest = Join-Path $modulePath ($file -replace "/", "\")
            $destDir = Split-Path -Parent $dest
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }

            $before = if (Test-Path $dest) { Get-Content -Raw -LiteralPath $dest -Encoding UTF8 } else { $null }
            $after = Get-Content -Raw -LiteralPath $src -Encoding UTF8
            if ($before -ne $after) {
                Set-Content -LiteralPath $dest -Value $after -NoNewline -Encoding UTF8
                $changed = $true
            }
        }

        if ($changed) {
            Write-Host "[$($module.name)] Ficheros compartidos actualizados a v$templateVersion." -ForegroundColor Green
            $module.templateVersion = $templateVersion

            if ($Commit) {
                foreach ($file in $sharedFiles) {
                    git add -- $file | Out-Null
                }
                git commit -m "chore: sync shared files from harness template v$templateVersion" | Out-Null
            }
        }
        else {
            Write-Host "[$($module.name)] Ya al dia (v$templateVersion)." -ForegroundColor DarkGray
        }
    }
    finally {
        Pop-Location
    }
}

$registry | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $registryPath -Encoding UTF8
Write-Host ""
Write-Host "Sincronizacion completada." -ForegroundColor Cyan
