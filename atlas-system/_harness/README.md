# Harness de módulos de Atlas

Este directorio es el "motor" que genera y mantiene coherentes los módulos de Atlas
(Agenda, Finanzas, Salud, ...) manteniéndolos **completamente independientes** entre sí.

## Principio

Cada módulo de Atlas se desarrolla como si fuera un producto standalone real:

- Vive en su propio repositorio git, en su propia carpeta (hermana de `atlas`, no dentro).
- Su `CLAUDE.md` está redactado como el brief de un proyecto propio — sin mencionar
  "Atlas" ni otros módulos.
- El agente de IA que trabaje en ese repo solo ve lo que hay dentro de él.

Lo que sí comparten todos los módulos es **el mismo tipo de arquitectura, stack y
convenciones**, definidas una sola vez aquí y propagadas por copia (no por referencia)
a cada módulo, para que cada uno sea autocontenido.

## Estructura

```
shared-kernel/          Proyecto Gradle real del Shared Kernel (codigo Java compartido).
                         Se publica con `gradle publishToMavenLocal` como
                         dev.sharedkernel:sharedkernel:<version> — coordenadas neutras,
                         sin rastro de Atlas, para no romper el aislamiento de los modulos.
archunit-rules/         Proyecto Gradle con las reglas de arquitectura compartidas.
                         Se publica como dev.sharedkernel:sharedkernel-archunit:<version>
                         y cada modulo lo consume como testImplementation.
_harness/
  template/           Plantilla base: se copia entera al crear un módulo nuevo.
    CLAUDE.md.tpl      Brief del proyecto (placeholders: {{MODULE_NAME}}, {{MODULE_DOMAIN}}, {{MODULE_TAGLINE}})
    README.md.tpl
    docs/
      architecture.md       Patrones arquitectónicos y estructura de carpetas compartida
      stack.md              Stack técnico compartido (Java 25, JPMS, Gradle, SQLite...)
      ddd-conventions.md    Patrón concreto de cada building block de DDD
      cqrs-conventions.md   Commands, Queries, handlers y cómo se despachan sin framework
      id-conventions.md     Tipado de IDs (prefijo legible vs UUID, generación de secuencias)
      error-conventions.md  Error/Result, catálogo de errores, Guard clauses, traducción a HTTP
      rich-domain-conventions.md  Checklist + ArchUnit para evitar un dominio anémico
      repository-conventions.md  Repositorios y consecuencias del aislamiento fisico entre contextos
      enum-conventions.md   Smart enums: comportamiento, persistencia por nombre, enum vs Value Object
      mapping-conventions.md  Dominio -> DTO, sin logica de negocio ni acceso a datos
      testing-conventions.md  Naming, estructura por modulo JPMS, mocks, cobertura, mutation testing
      validation-specification-conventions.md  Por que no se adoptan Validator/Specification
      logging-conventions.md  Decoradores, politica de privacidad, formato y niveles
      conventions.md        Cero comentarios, formatter obligatorio en el build
    config/
      formatter.properties  Configuracion del formatter (Spotless + Eclipse JDT)
  generator/
    new-module.ps1     Crea un módulo nuevo a partir de template/
  sync/
    update-modules.ps1 Repropaga docs/architecture.md, stack.md, conventions.md
                        a todos los módulos ya creados, sin tocar CLAUDE.md ni el código
  registry.json        Catálogo de módulos: nombre, ruta, dominio, versión de plantilla
```

## Flujo de trabajo

### 1. Definir (o evolucionar) el estándar compartido

Edita los docs de `template/docs/`. Sube `templateVersion` en `registry.json` cuando el
cambio sea significativo.

Si el cambio es de código compartido (Shared Kernel): edita `../shared-kernel/`, sube
su `version` en `build.gradle.kts` y ejecuta:

```powershell
cd ..\shared-kernel
gradle publishToMavenLocal
```

Cada módulo decide cuándo subir su versión de dependencia — las versiones antiguas
siguen disponibles en `~/.m2`, así que actualizar el kernel nunca rompe módulos que aún
fijan una versión anterior.

### 2. Crear un módulo nuevo

```powershell
./generator/new-module.ps1 -Name "Agenda" -Domain "Gestión de citas, recordatorios y calendario personal."
```

Esto crea `C:\develop\agenda` como repo git independiente, ya inicializado con commit
inicial, y lo registra en `registry.json`.

### 3. Trabajar en el módulo

Abre una sesión de Claude Code con el directorio de trabajo apuntando al módulo
(`C:\develop\agenda`), no al repo `atlas`. El agente solo tendrá visibilidad de ese
repositorio.

### 4. Sincronizar módulos existentes tras un cambio de estándar

```powershell
./sync/update-modules.ps1 -Commit
```

Sobrescribe los ficheros compartidos en cada módulo registrado: los 13 docs de
`docs/` (`architecture.md`, `stack.md`, `conventions.md`, `ddd-conventions.md`,
`cqrs-conventions.md`, `id-conventions.md`, `error-conventions.md`,
`rich-domain-conventions.md`, `repository-conventions.md`, `enum-conventions.md`,
`mapping-conventions.md`, `testing-conventions.md`,
`validation-specification-conventions.md`) y `config/formatter.properties`.

La lista vive en `$sharedFiles` dentro del script, como rutas relativas — añadir un
fichero compartido nuevo es añadir una línea ahí, sea de `docs/` o de cualquier otra
carpeta.

Si un módulo tiene cambios locales sin commitear en esos ficheros, se omite y se avisa
(para no pisar trabajo en curso).

## Qué NO comparten los módulos

- Código, ni siquiera librerías comunes (cada uno decide su propia implementación
  dentro del estándar compartido).
- Historial git.
- Visibilidad entre ellos ni del repo `atlas`.

## Qué genera el esqueleto

Un módulo nuevo nace **compilable y ejecutable**: proyecto Gradle multi-módulo con un
subproyecto y un `module-info.java` por anillo (`domain`, `application`,
`infrastructure`, `presentation`) más `app`, el composition root — que según
`architecture.md` no pertenece a ninguna capa.

```powershell
gradle build     # compila los 5, pasa spotless y los tests de arquitectura
gradle :app:run  # arranca e imprime la linea de inicio
```

Las rutas de la plantilla usan `__pkg__` como marcador del paquete base; el generador lo
sustituye por el slug del módulo (sin guiones, para que sea un identificador Java válido).

## Pendiente
- Diseñar la capa de integración final (cómo se ensamblan los módulos en la app
  Atlas real) — deliberadamente fuera de alcance por ahora.
