<#
.SYNOPSIS
    Crea un nuevo modulo de Atlas como repositorio git completamente independiente,
    a partir de la plantilla compartida del harness.

.DESCRIPTION
    - Copia atlas-system/_harness/template a un directorio nuevo (hermano del repo atlas
      por defecto), rellenando los placeholders con el nombre y dominio del modulo.
    - Inicializa un repositorio git propio en ese directorio, sin ninguna referencia a Atlas.
    - Registra el modulo en atlas-system/_harness/registry.json.

.PARAMETER Name
    Nombre del modulo (ej. "Agenda"). Se usa tal cual en los documentos y en minusculas
    para el nombre del directorio/repositorio.

.PARAMETER Domain
    Descripcion breve del dominio del proyecto, en una o dos frases, como si fuera el
    brief de un producto standalone (ej. "Gestion de citas, recordatorios y calendario
    personal.").

.PARAMETER Tagline
    Frase corta tipo tagline (opcional). Si no se indica, se genera una por defecto.

.PARAMETER BasePath
    Carpeta donde se creara el repositorio del modulo. Por defecto, la carpeta padre
    del repo atlas (mismo nivel que atlas, agenda, finanzas, etc.).

.EXAMPLE
    ./new-module.ps1 -Name "Agenda" -Domain "Gestion de citas, recordatorios y calendario personal."
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [string]$Tagline,

    [string]$BasePath
)

$ErrorActionPreference = "Stop"

# --- Resolucion de rutas -----------------------------------------------------

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$harnessDir = Split-Path -Parent $scriptDir
$atlasSystemDir = Split-Path -Parent $harnessDir
$atlasRoot = Split-Path -Parent $atlasSystemDir
$templateDir = Join-Path $harnessDir "template"
$registryPath = Join-Path $harnessDir "registry.json"

if (-not $BasePath) {
    $BasePath = Split-Path -Parent $atlasRoot
}

$moduleSlug = $Name.ToLower() -replace '[^a-z0-9\-]', '-'
$targetDir = Join-Path $BasePath $moduleSlug

if (Test-Path $targetDir) {
    throw "El directorio '$targetDir' ya existe. Elige otro nombre o eliminalo antes de continuar."
}

if (-not $Tagline) {
    $Tagline = "$Name - Personal Life Assistant module."
}

Write-Host "Creando modulo '$Name' en $targetDir ..." -ForegroundColor Cyan

# --- Copia de plantilla con sustitucion de placeholders -----------------------

$modulePackage = $moduleSlug -replace '[^a-z0-9]', ''
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$replacements = @{
    "{{MODULE_NAME}}"    = $Name
    "{{MODULE_DOMAIN}}"  = $Domain
    "{{MODULE_TAGLINE}}" = $Tagline
    "{{MODULE_SLUG}}"    = $moduleSlug
    "{{MODULE_PACKAGE}}" = $modulePackage
}

function Copy-TemplateItem {
    param(
        [string]$SourcePath,
        [string]$RelativePath
    )

    # Las rutas tambien llevan placeholder: __pkg__ es el paquete base del modulo.
    $destRelative = $RelativePath -replace '__pkg__', $modulePackage
    $isTemplate = $destRelative -match '\.tpl$'
    $destRelative = $destRelative -replace '\.tpl$', ''
    $destPath = Join-Path $targetDir $destRelative
    $destParent = Split-Path -Parent $destPath

    if (-not (Test-Path $destParent)) {
        New-Item -ItemType Directory -Path $destParent -Force | Out-Null
    }

    if (-not $isTemplate) {
        # Copia binaria: no se toca el contenido (wrapper de Gradle, imagenes, etc.).
        Copy-Item -LiteralPath $SourcePath -Destination $destPath -Force
        return
    }

    $content = Get-Content -Raw -LiteralPath $SourcePath -Encoding UTF8
    foreach ($key in $replacements.Keys) {
        $content = $content -replace [regex]::Escape($key), $replacements[$key]
    }

    # UTF-8 SIN BOM: Set-Content -Encoding UTF8 lo anade en PowerShell 5.1, y javac
    # rechaza el ﻿ inicial de un fichero fuente.
    [System.IO.File]::WriteAllText($destPath, $content, $script:Utf8NoBom)
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

Get-ChildItem -Path $templateDir -Recurse -File | ForEach-Object {
    $relative = $_.FullName.Substring($templateDir.Length + 1)
    Copy-TemplateItem -SourcePath $_.FullName -RelativePath $relative
}

# --- Wrapper de Gradle -------------------------------------------------------
# Se reutiliza el del shared-kernel para no duplicar el jar binario en la plantilla.

$kernelDir = Join-Path $atlasSystemDir "shared-kernel"
foreach ($item in @("gradlew", "gradlew.bat", "gradle")) {
    $source = Join-Path $kernelDir $item
    if (Test-Path $source) {
        Copy-Item -LiteralPath $source -Destination $targetDir -Recurse -Force
    }
}

# --- Inicializacion del repo git independiente --------------------------------

$currentTemplateVersion = (Get-Content -Raw -LiteralPath $registryPath | ConvertFrom-Json).templateVersion

Push-Location $targetDir
try {
    git init | Out-Null
    git add -A | Out-Null
    git commit -m "Initial scaffold from atlas harness template v$currentTemplateVersion" | Out-Null
}
finally {
    Pop-Location
}

# --- Registro del modulo --------------------------------------------------------

$registry = Get-Content -Raw -LiteralPath $registryPath | ConvertFrom-Json

$newEntry = [PSCustomObject]@{
    name            = $moduleSlug
    displayName     = $Name
    path            = $targetDir
    domain          = $Domain
    templateVersion = $registry.templateVersion
    createdAt       = (Get-Date).ToString("yyyy-MM-dd")
}

$modulesList = @($registry.modules) + $newEntry
$registry.modules = $modulesList
[System.IO.File]::WriteAllText($registryPath, ($registry | ConvertTo-Json -Depth 5), $script:Utf8NoBom)

Write-Host ""
Write-Host "Modulo '$Name' creado correctamente." -ForegroundColor Green
Write-Host "  Ruta:        $targetDir"
Write-Host "  Repo git:    inicializado, commit inicial creado"
Write-Host "  Registrado:  atlas-system/_harness/registry.json"
Write-Host ""
Write-Host "Siguiente paso: abre una sesion de Claude Code en '$targetDir' para empezar a trabajar en el modulo."
