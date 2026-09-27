<div align="center">
  <img src="../../assets/public-png/lockup/lockup-horizontal-dark.png" alt="Harness de módulos de Atlas" width="100%" />
</div>

<div align="center">

# Harness de módulos de Atlas

</div>

<div align="center">
  What you need to see, when you look up.
</div>

<div align="center">
  <a href="../../assets/public-png/lockup/">assets</a>
</div>

<br />

<div align="center">
  <a href="https://go-skill-icons.vercel.app/">
    <img src="https://go-skill-icons.vercel.app/api/icons?i=java,gradle,sqlite,js,html,css,git&titles=true" alt="Technology stack" />
  </a>
</div>

---

<div align="center">

## 🎯 Purpose

</div>

Este directorio es el "motor" que genera y mantiene coherentes los módulos de Atlas
(Agenda, Finanzas, Salud, ...) manteniéndolos **completamente independientes** entre sí.

<div align="center">

## 🏗️ Architecture

</div>

Cada módulo de Atlas se desarrolla como si fuera un producto standalone real:

- Vive en su propio repositorio git, en su propia carpeta (hermana de `atlas`, no dentro).
- Su `CLAUDE.md` está redactado como el brief de un proyecto propio — sin mencionar
  "Atlas" ni otros módulos.
- El agente de IA que trabaje en ese repo solo ve lo que hay dentro de él.

Lo que sí comparten todos los módulos es **el mismo tipo de arquitectura, stack y
convenciones**, definidas una sola vez aquí y propagadas por copia (no por referencia)
a cada módulo, para que cada uno sea autocontenido.

### El aislamiento es un método de desarrollo, no una arquitectura de despliegue

Cada módulo se desarrolla **como si fuera un microservicio**: producto completo,
autónomo y arrancable por sí solo, con sus propios requisitos, su propio dominio y sus
propios casos de uso. Pero el destino no es un despliegue de microservicios — al final
los módulos se ensamblan en una sola aplicación Atlas.

Dos consecuencias que conviene no olvidar al revisar decisiones:

- **El outbox no se justifica por el límite de proceso**, sino porque hay un fichero
  SQLite por bounded context: no existe una transacción única que abarque dos contextos,
  estén o no en el mismo JVM. Si algún día todo corre en un proceso, el outbox sigue
  siendo necesario por la misma razón.
- Las tres reglas de "El proyecto como producto autónomo" en `architecture.md` (nombrar
  todo desde el propio dominio, no asumirse dueño de la raíz HTTP ni único componente del
  proceso, exponer el cableado como algo arrancable y no solo como un `main`) **son los
  requisitos del ensamblaje final**, redactadas de forma neutra: leídas desde el módulo
  parecen simple higiene, y no filtran que exista un sistema que lo componga.

<div align="center">

## 📦 Project layout

</div>

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

<div align="center">

## 🚀 Development setup

</div>

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

<div align="center">

## 🔹 Module boundaries

</div>

- Código, ni siquiera librerías comunes (cada uno decide su propia implementación
  dentro del estándar compartido).
- Historial git.
- Visibilidad entre ellos ni del repo `atlas`.

<div align="center">

## 🔹 Generated project

</div>

Un módulo nuevo nace **compilable y ejecutable**: un único proyecto Gradle con un solo
`src/main/java` y `src/test/java`, y un `module-info.java` para todo el proyecto. Los
anillos (`domain`, `application`, `infrastructure`, `presentation` y `app`, el
composition root) son paquetes dentro de ese árbol, no subproyectos.

```powershell
gradle build  # compila, pasa spotless y los tests de arquitectura
gradle run    # arranca el servidor HTTP en loopback
```

> **Consecuencia de tener un solo `module-info.java`:** JPMS ya no puede impedir que
> `domain` dependa de `infrastructure`, porque todo vive en el mismo módulo Java. La
> regla de dependencia la sostiene **solo ArchUnit**, en la fase de tests. Sigue fallando
> el build, pero más tarde que antes.

Las rutas de la plantilla usan `__pkg__` como marcador del paquete base; el generador lo
sustituye por el slug del módulo (sin guiones, para que sea un identificador Java válido).

<div align="center">

## 🔬 Scope and status

</div>

- Diseñar la capa de integración final (cómo se ensamblan los módulos en la app
  Atlas real) — deliberadamente fuera de alcance por ahora. Lo único que se exige desde
  ya es que cada módulo cumpla las tres reglas de producto autónomo, para que ensamblar
  no obligue a reescribirlo.
