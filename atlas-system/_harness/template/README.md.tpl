<div align="center">
  <img src="assets/branding/lockup-horizontal-dark.png" alt="{{MODULE_NAME}}" width="100%" />
</div>

<div align="center">

# {{MODULE_NAME}}

</div>

<div align="center">
  {{MODULE_TAGLINE}}
</div>

<div align="center">
  <a href="src/">source</a> · <a href="docs/">docs</a>
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

{{MODULE_TAGLINE}}

{{MODULE_DOMAIN}}

<div align="center">

## 🏗️ Architecture

</div>

The implementation is organized in [src/](src/). See the project layout and source code for the component boundaries.

<div align="center">

## 📦 Project layout

</div>

- [`src/`](src/)
- [`docs/`](docs/)
- [`assets/`](assets/)

<div align="center">

## 🚀 Development setup

</div>

Requiere **JDK 25**. El wrapper de Gradle está incluido en el repositorio.

```
./gradlew build   # compila, aplica el formatter y pasa los tests de arquitectura
./gradlew run     # arranca el servidor HTTP en http://localhost:8080
```

El código vive todo bajo `src/main/java`, con un paquete por anillo de la arquitectura
(`domain`, `application`, `infrastructure`, `presentation`) más `app`, el composition
root. Los tests están en `src/test/java`, replicando esa misma estructura.

<div align="center">

## 🧪 Testing and quality gates

</div>

```bash
./gradlew build
```

The build runs the formatter and architecture tests.

<div align="center">

## 📚 Documentation

</div>

- [CLAUDE.md](CLAUDE.md) — contexto general del proyecto
- [docs/architecture.md](docs/architecture.md)
- [docs/stack.md](docs/stack.md)
- [docs/ddd-conventions.md](docs/ddd-conventions.md)
- [docs/cqrs-conventions.md](docs/cqrs-conventions.md)
- [docs/id-conventions.md](docs/id-conventions.md)
- [docs/error-conventions.md](docs/error-conventions.md)
- [docs/rich-domain-conventions.md](docs/rich-domain-conventions.md)
- [docs/repository-conventions.md](docs/repository-conventions.md)
- [docs/enum-conventions.md](docs/enum-conventions.md)
- [docs/mapping-conventions.md](docs/mapping-conventions.md)
- [docs/testing-conventions.md](docs/testing-conventions.md)
- [docs/validation-specification-conventions.md](docs/validation-specification-conventions.md)
- [docs/conventions.md](docs/conventions.md)

<div align="center">

## 🔬 Scope and status

</div>

{{MODULE_TAGLINE}}
