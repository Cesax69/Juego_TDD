# 🤠 Momias de Guanajuato — Juego de Plataformas 2D con TDD

Un explorador debe cruzar los callejones de Guanajuato saltando entre plataformas de cantera rosa, esquivando o derrotando momias que patrullan de un lado a otro y recolectando calaveritas de azúcar hasta llegar al legendario **Callejón del Beso**.

Este proyecto fue desarrollado siguiendo estrictamente la metodología **TDD (Test-Driven Development)**: toda la física, combate, IA y reglas del juego están implementadas como **funciones puras en Dart**, probadas de forma exhaustiva antes de vincular cualquier widget de Flutter.

---

## 🎮 Captura del Juego en Ejecución

![Juego en Ejecución](evidencias/06_juego_en_ejecucion.png)

---

## 📋 Checklist de este proyecto TDD

| Estado | Verificación | Explicación y Referencia de Código |
| :---: | :--- | :--- |
| **[x]** | **La colisión AABB (Rectangulo) se probó de forma aislada antes de usarse en cualquier otra parte** | Se implementó y verificó en [`test/rectangulo_test.dart`](momias_guanajuato/test/rectangulo_test.dart) probando casos de solapamiento y separación antes de usar [`Rectangulo`](momias_guanajuato/lib/logica/rectangulo.dart) en piso, momias o calaveritas. |
| **[x]** | **`resolverColisionConPiso` usa la posición anterior del personaje, no solo la actual** | En [`lib/logica/motor_fisica.dart`](momias_guanajuato/lib/logica/motor_fisica.dart), el método recibe `yAnterior` como "parámetro-costura", distinguiendo si el personaje venía cayendo desde arriba (`yAnterior <= plataforma.y` y `pieActual >= plataforma.y`) o ya estaba dentro/debajo de la plataforma. Probado en [`test/motor_fisica_test.dart`](momias_guanajuato/test/motor_fisica_test.dart). |
| **[x]** | **El criterio de 'stomp' exige caer Y estar en la mitad superior de la momia, no solo intersectar** | En [`lib/logica/motor_combate.dart`](momias_guanajuato/lib/logica/motor_combate.dart), para derrotar a la momia se exige `velocidadY > 0` **Y** que el pie del personaje esté en la mitad superior (`pie <= momia.y + momia.alto / 2`). Si choca lateralmente sin caer desde arriba, el jugador pierde una vida. Probado en [`test/motor_combate_test.dart`](momias_guanajuato/test/motor_combate_test.dart). |
| **[x]** | **`patrullar()`, aleatoriedad y lógica sensible al tiempo son deterministas en las pruebas** | En [`lib/logica/momia.dart`](momias_guanajuato/lib/logica/momia.dart), la IA de patrullaje avanza por velocidad determinista e invierte el signo al tocar los límites (`limiteIzquierdo` y `limiteDerecho`). Probado en [`test/momia_test.dart`](momias_guanajuato/test/momia_test.dart). |
| **[x]** | **`MotorJuego.mover()` es el único lugar que decide el orden de física, combate, recolección y meta** | En [`lib/logica/motor_juego.dart`](momias_guanajuato/lib/logica/motor_juego.dart), el método `mover()` orquesta secuencialmente: 1) Desplazamiento horizontal y límites, 2) Gravedad y colisión de piso, 3) Patrullaje de momias y combate, 4) Recolección de calaveritas, y 5) Verificación de llegada a la meta. Probado en [`test/motor_juego_test.dart`](momias_guanajuato/test/motor_juego_test.dart). |
| **[x]** | **La interfaz no decide colisiones ni puntajes — solo traduce el estado de `MotorJuego` a píxeles** | En [`lib/presentation/juego_screen.dart`](momias_guanajuato/lib/presentation/juego_screen.dart), el widget únicamente invoca `_motor.mover(...)` y `_motor.saltar()`, proyectando el estado puro a la pantalla con una cámara que sigue al personaje. |

---

## 📸 Guía de Evidencias

Las capturas deben guardarse en la carpeta [`evidencias/`](evidencias/):

### 1. Evidencia: Colisión AABB Aislada
- **Archivo a capturar:** [`momias_guanajuato/test/rectangulo_test.dart`](momias_guanajuato/test/rectangulo_test.dart) junto con [`momias_guanajuato/lib/logica/rectangulo.dart`](momias_guanajuato/lib/logica/rectangulo.dart).
- **Qué mostrar:** Las pruebas de colisión positiva y negativa pasando en verde con la clase pura `Rectangulo`.
- **Ruta de imagen sugerida:** `evidencias/01_colision_aabb.png`

### 2. Evidencia: Costura Temporal de Aterrizaje
- **Archivo a capturar:** Método `resolverColisionConPiso` en [`momias_guanajuato/lib/logica/motor_fisica.dart`](momias_guanajuato/lib/logica/motor_fisica.dart) y las pruebas correspondientes en [`momias_guanajuato/test/motor_fisica_test.dart`](momias_guanajuato/test/motor_fisica_test.dart).
- **Qué mostrar:** El uso del parámetro `yAnterior` verificando que el personaje aterriza solo si venía cayendo desde arriba.
- **Ruta de imagen sugerida:** `evidencias/02_costura_aterrizaje.png`

### 3. Evidencia: Combate Stomp vs Impacto Lateral
- **Archivo a capturar:** [`momias_guanajuato/lib/logica/motor_combate.dart`](momias_guanajuato/lib/logica/motor_combate.dart) y [`momias_guanajuato/test/motor_combate_test.dart`](momias_guanajuato/test/motor_combate_test.dart).
- **Qué mostrar:** Las condiciones `velocidadY > 0` y mitad superior para `momiaDerrotada`, y choque lateral para `jugadorGolpeado`.
- **Ruta de imagen sugerida:** `evidencias/03_combate_stomp.png`

### 4. Evidencia: Patrullaje Determinista de la Momia
- **Archivo a capturar:** [`momias_guanajuato/lib/logica/momia.dart`](momias_guanajuato/lib/logica/momia.dart) y [`momias_guanajuato/test/momia_test.dart`](momias_guanajuato/test/momia_test.dart).
- **Qué mostrar:** El método `patrullar()` con inversión de límites y las 3 pruebas unitarias pasando.
- **Ruta de imagen sugerida:** `evidencias/04_patrullaje_momia.png`

### 5. Evidencia: Bucle Orquestador `MotorJuego.mover()`
- **Archivo a capturar:** [`momias_guanajuato/lib/logica/motor_juego.dart`](momias_guanajuato/lib/logica/motor_juego.dart) y [`momias_guanajuato/test/motor_juego_test.dart`](momias_guanajuato/test/motor_juego_test.dart).
- **Qué mostrar:** El orden estricto de ejecución en `mover()` y las pruebas de vidas, Game Over y meta.
- **Ruta de imagen sugerida:** `evidencias/05_motor_juego_orquestador.png`

### 6. Evidencia: Juego en Ejecución (Interfaz Desacoplada)
- **Archivo a capturar:** La pantalla del juego corriendo en navegador web o emulador/desktop.
- **Qué mostrar:** HUD con corazones de vida, puntaje, personaje vaquero 🤠, momias 🧟, plataformas de Guanajuato, calaveritas 💀 y meta del Callejón del Beso 💋.
- **Imagen ya incluida:** [`evidencias/06_juego_en_ejecucion.png`](evidencias/06_juego_en_ejecucion.png)

### 7. Evidencia: Suite Completa de Pruebas (23/23 en Verde)
- **Terminal a capturar:** Salida del comando `flutter test --reporter=expanded`.
- **Qué mostrar:** La ejecución completa de los 5 archivos de prueba con `All tests passed!`.
- **Ruta de imagen sugerida:** `evidencias/07_pruebas_totales_verde.png`

---

## 🏛️ Estructura del Proyecto

```
momias_guanajuato/
├── lib/
│   ├── logica/               # Capa Dart puro (sin Flutter)
│   │   ├── rectangulo.dart   # Bounding box AABB
│   │   ├── personaje.dart    # Estado del jugador
│   │   ├── momia.dart        # IA patrullaje
│   │   ├── calaverita.dart   # Ítem coleccionable
│   │   ├── motor_fisica.dart # Gravedad, salto, piso y límites
│   │   ├── motor_combate.dart# Stomp vs daño lateral
│   │   ├── estado_juego.dart # jugando / ganado / perdido
│   │   └── motor_juego.dart  # Bucle principal
│   ├── presentation/
│   │   └── juego_screen.dart # Cámara, sprites, HUD y controles táctiles/teclado
│   └── main.dart
└── test/
    ├── rectangulo_test.dart
    ├── motor_fisica_test.dart
    ├── momia_test.dart
    ├── motor_combate_test.dart
    └── motor_juego_test.dart
```

---

## 🚀 Cómo Ejecutar

### 1. Ejecutar las Pruebas Unitarias
```bash
cd momias_guanajuato
flutter test
```

### 2. Ejecutar la Aplicación en Web (Chrome / Edge)
```bash
cd momias_guanajuato
flutter run -d chrome
```

### 3. Controles
- **En pantalla:** Botones táctiles virtuales (Izquierda, Derecha y Salto).
- **En teclado (Web / Desktop):**
  - **Moverse a la izquierda:** `A` o `← Flecha izquierda`
  - **Moverse a la derecha:** `D` o `→ Flecha derecha`
  - **Saltar:** `Barra espaciadora`, `W` o `↑ Flecha arriba`
