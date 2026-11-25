# Guía de Despliegue: Anaquel v1.0.0 (iPad, iOS y Android)

Esta guía cubre la compilación e instalación final en los dispositivos del proyecto: **iPad (modo Caja)** y **teléfonos Android e iOS (modo Terminal)**.

---

## 1. Android (Teléfonos Terminal — Gratis por APK)

### 1.1 Generar el Keystore de producción (una sola vez)
```bash
cd app/android/app
keytool -genkey -v -keystore anaquel-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias anaquel
```
> Guarda `anaquel-release.jks` y sus contraseñas en un lugar seguro. **Nunca los subas a Git** (`.gitignore` ya los ignora).

### 1.2 Configurar `app/android/key.properties`
Copia la plantilla y pon tus contraseñas reales:
```bash
cp app/android/key.properties.example app/android/key.properties
```

### 1.3 Compilar el APK final e instalar
```bash
cd app
fvm flutter build apk --release
```
El archivo quedará en `app/build/app/outputs/flutter-apk/app-release.apk`. Puedes instalarlo por USB (`adb install app/build/app/outputs/flutter-apk/app-release.apk`) o enviándolo directo al teléfono Android.

---

## 2. iPad e iPhone (Instalación directa por Xcode)

Para el proyecto y pruebas en dispositivos reales sin subir a App Store:

1. Conecta el **iPad** (o iPhone) por cable USB a tu Mac y confía en la computadora cuando el dispositivo lo pida.
2. Prepara la compilación de Flutter desde la terminal:
   ```bash
   cd app
   fvm flutter build ios --release --no-codesign
   ```
3. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. En Xcode:
   - Selecciona el target **Runner** → pestaña **Signing & Capabilities**.
   - Marca **Automatically manage signing** y elige tu **Team** (tu Apple ID).
   - Selecciona tu **iPad** (o iPhone) en la barra superior de dispositivos y presiona **Run (⌘R)** para instalar en modo Release directamente en el dispositivo.
5. En el iPad/iPhone: entra a **Ajustes → General → Gestión de dispositivos y VPN** y confía en tu certificado de desarrollador la primera vez que abras Anaquel.

> [!NOTE]
> Si usas un Apple ID gratuito (sin membresía de $99 USD/año), Apple firma la app por **7 días**. Si pasa ese tiempo y vas a volver a presentar o probar el proyecto, solo conecta el dispositivo a la Mac y vuelve a presionar **Run (⌘R)** en Xcode (los datos en SQLite del iPad se conservan).

---

## 3. Configuración del iPad y Red Wi-Fi del Local

Para que el iPad funcione como servidor estable de **Caja**:

1. **Red Wi-Fi (IP fija):** En el router del local, asigna una **reserva DHCP** a la dirección MAC del iPad para que siempre reciba la misma IP local (ej. `192.168.1.50`). Así las terminales nunca pierden conexión si se va la luz.
2. **Permisos al primer arranque:** Acepta los permisos de **Red local**, **Cámara** y **Fotos** cuando iPadOS/iOS los solicite.
3. **Pantalla y energía:**
   - Anaquel mantiene la pantalla encendida automáticamente mientras estás en modo Caja.
   - Aun así, configura en iPadOS **Ajustes → Pantalla y brillo → Bloqueo automático → Nunca** y mantén el iPad conectado al cargador.
   - Opcional recomendado para mostrador: activa **Acceso Guiado** (*Ajustes → Accesibilidad → Acceso Guiado*) para que nadie salga de Anaquel por error.
