# Stack técnico

> Documento compartido: gestionado por el harness y sincronizado en todos los proyectos.
> No lo edites manualmente en este repo — los cambios se sobrescribirán en el próximo `sync`.

## Lenguaje y plataforma

- **Java 25**, sin frameworks (ni Spring ni ningún contenedor de inversión de control
  externo). Todo se construye directamente sobre el JDK.
- **Módulos JPMS** (Java Platform Module System): un módulo Java (`module-info.java`)
  por cada anillo de la arquitectura (`Shared Kernel`, `Domain`, `Application`,
  `Infrastructure`, `Presentación`). El propio compilador refuerza la regla de
  dependencia — un anillo solo puede compilar si declara `requires` hacia los anillos
  hacia los que tiene permitido depender; JPMS impide compilar lo contrario.

## Construcción

- **Gradle 9**, proyecto multi-módulo: un subproyecto Gradle por módulo JPMS/anillo.

## Persistencia

- **SQLite**. Un fichero de base de datos por contexto (bounded context).

## Servidor HTTP

- **`jdk.httpserver`** (`com.sun.net.httpserver`), incluido en el JDK. Sin servidor de
  aplicaciones ni framework HTTP externo.

## Actualización de pantalla

- **Server-Sent Events (SSE)** para el push del servidor hacia el cliente.
- **POST** para las acciones del usuario.

### Formato de los eventos SSE (decidido)

```
id: 42
event: appointmentScheduled
data: {"appointmentId":"A00000007"}

```

- `event` es el nombre al que se suscribe el cliente; `data` es JSON en una línea,
  serializado por el módulo (el Shared Kernel no incorpora librería JSON).
- `id` lo asigna `SseHub` con un contador creciente. **Hoy no hay reenvío tras
  reconexión**: el cliente que reconecta recarga su estado con una query normal. Los ids
  se emiten desde el principio para que añadir un búfer de reenvío más adelante no
  obligue a cambiar el formato.
- El `SseHub` del kernel trabaja sobre un `OutputStream`, **no** sobre
  `jdk.httpserver`: así el kernel no declara `requires jdk.httpserver` y el formato de
  cable se testea contra un `ByteArrayOutputStream`, sin levantar un servidor.

Tres detalles que el kernel resuelve una vez y conviene no reimplementar:

- **Un `data` multilínea repite el prefijo `data:` en cada línea.** Si no, el cliente
  recibe el mensaje truncado.
- **Latido periódico** (`: ping`) mediante `SseHub.sendHeartbeat()`: sin tráfico, el
  navegador o un proxy cortan la conexión a los pocos minutos. Quién lo programa es
  decisión del composition root.
- **Nunca se fija `Content-Length`** (ver `SseHeaders.forStream()`). Con longitud fija el
  servidor espera el cuerpo completo y no envía nada — es la causa más común de que
  "SSE no funcione".

Los nombres de evento y los ids rechazan saltos de línea: uno solo permitiría **forjar un
frame del protocolo** desde un dato de usuario.

## JSON

- **Jackson jr** (variante ligera de Jackson, sin el módulo `databind` completo).

## Cliente HTTP saliente

- **`java.net.http.HttpClient`**, incluido en el JDK. Sin librerías HTTP externas.

## Interfaz de usuario

- **HTML, CSS y JavaScript** escritos a mano. Cero npm, cero bundlers, cero frameworks
  de frontend.

## Testing

- **JUnit 5** para pruebas unitarias y de integración.
- **AssertJ** para assertions legibles y encadenables.
- **Mockito** para mockear puertos (repositorios, read models, publishers) — nunca
  objetos de dominio.
- **JaCoCo** para cobertura de línea (suelo mínimo, detector de huecos, no objetivo en
  sí mismo).
- **PIT** para mutation testing en `domain` — criterio de profundidad donde vive la
  lógica de negocio.
- **ArchUnit** para verificar programáticamente las reglas de arquitectura (dependencias
  entre capas, convenciones de paquetes) como parte de la suite de tests — refuerzo
  adicional sobre lo que ya impone JPMS en tiempo de compilación.

Ver [testing-conventions.md](testing-conventions.md) para la convención completa (esta
instancia local de las skills genéricas `test-conventions`/`unit-testing` ya existentes
del usuario, adaptadas a un stack sin Spring/framework).

## Configuración de memoria de la JVM

- `-Xms96m -Xmx96m` (heap fijo y pequeño)
- `-Xss256k` (stack reducido)
- `-XX:+UseSerialGC`
- Metaspace: `64m`

Estos flags reflejan una filosofía deliberada de bajo consumo de recursos: cada
proyecto/módulo debe poder ejecutarse cómodamente con un footprint mínimo.

## Shared Kernel como dependencia

El `Shared Kernel` se consume como dependencia Gradle normal:

```kotlin
repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    implementation("dev.sharedkernel:sharedkernel:0.12.0")
    testImplementation("dev.sharedkernel:sharedkernel-archunit:0.2.0")
}
```

En `module-info.java`, cada anillo que lo use declara `requires sharedkernel;`.

> **Limitación conocida en CI.** `mavenLocal()` es el `~/.m2` de la máquina de
> desarrollo: en un runner de integración continua está vacío, así que el workflow
> fallará al resolver la dependencia hasta que el Shared Kernel se publique en un
> repositorio alcanzable desde la red (un registro de paquetes, o el jar versionado
> dentro del propio repo con `flatDir`). Es una consecuencia directa de haber elegido
> `mavenLocal` para el desarrollo local y está sin decidir.

## Pendiente / a definir más adelante

- Convención de rutas/endpoints HTTP.
- Quién programa el latido del `SseHub` y con qué periodo.
- Si en algún momento hace falta reenvío tras reconexión (`Last-Event-ID` + búfer).
