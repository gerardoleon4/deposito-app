# Guía de instalación por sistema operativo

El equipo trabaja en **Linux, Windows y macOS**. El código y los comandos son los mismos; lo que cambia es cómo se instalan las herramientas. Esta guía va en `docs/SETUP.md`.

## Qué se puede hacer en cada sistema

| Tarea | Linux | Windows | macOS |
| --- | --- | --- | --- |
| Programar el backend y correr el servidor | Sí | Sí | Sí |
| Programar la app y probarla en Android (teléfono o emulador) | Sí | Sí | Sí |
| Compilar e instalar en iPad o iPhone | No | No | **Sí (requiere Xcode)** |

Quien use Mac es la persona natural para instalar en el iPad y el iPhone. Si nadie tiene Mac, se usa Codemagic (compila iOS en la nube).

## Reglas para todos

- **Versión de Flutter: 3.47.5** (incluye Dart 3.13.4). Todos la misma. Se verifica con `flutter --version`.
- **Los comandos del proyecto se escriben en una terminal tipo bash:** Terminal en Linux y macOS, **Git Bash en Windows**. No usar PowerShell ni CMD, porque `mkdir -p`, `cat`, `printf` y `~` no funcionan igual.
- Los saltos de línea ya están normalizados en el repo con `.gitattributes` (`* text=auto eol=lf`), así que un archivo editado en Windows no aparece "todo modificado" en los PR.
- Editor recomendado: **VS Code** con las extensiones **Dart** y **Flutter**.

---

## 1. Instalación

### Linux (Mint o Ubuntu)

```bash
sudo apt update
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa
mkdir -p ~/development
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
```

Si tu terminal usa bash en lugar de zsh, cambia `~/.zshrc` por `~/.bashrc`. Cierra y abre la terminal, y comprueba con `flutter --version`.

### Windows

1. Instala **Git para Windows** desde git-scm.com con las opciones por defecto. Incluye **Git Bash**.
2. Abre **Git Bash** y clona Flutter en una ruta corta, sin espacios y fuera de `Program Files`:
   ```bash
   mkdir -p /c/src
   git clone https://github.com/flutter/flutter.git -b stable /c/src/flutter
   ```
3. Agrega Flutter al PATH: busca **"Editar las variables de entorno del sistema"** → **Variables de entorno** → en **Path** del usuario, **Nuevo** → `C:\src\flutter\bin`.
4. Cierra Git Bash, ábrelo de nuevo y comprueba con `flutter --version`.
5. **Activa el Modo de desarrollador:** Configuración → Privacidad y seguridad → Para desarrolladores → Modo de desarrollador. Flutter lo necesita para enlazar los plugins; sin esto, `flutter pub get` puede fallar.
6. Activa las rutas largas de Git, en Git Bash:
   ```bash
   git config --global core.longpaths true
   ```

Clona el repo en una carpeta corta como `C:\dev`, no dentro de OneDrive ni de Documentos.

### macOS

```bash
xcode-select --install
mkdir -p ~/development
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
```

Cierra y abre la Terminal y comprueba con `flutter --version`.

**Solo si vas a compilar para iPad o iPhone:**
1. Instala **Xcode** desde la App Store.
2. Ejecuta `sudo xcodebuild -runFirstLaunch`.
3. Instala CocoaPods: `brew install cocoapods` (o `sudo gem install cocoapods`).
4. En Xcode, inicia sesión con tu Apple ID en **Settings → Accounts**.

### Fijar la versión (si `stable` ya avanzó)

Si `flutter --version` no muestra 3.47.5, fija la versión en la carpeta donde instalaste Flutter:

```bash
git -C ~/development/flutter checkout 3.47.5
flutter --version
```

En Windows la ruta es `/c/src/flutter` en lugar de `~/development/flutter`.

---

## 2. Android (todos los sistemas)

1. Instala **Android Studio** desde developer.android.com/studio.
2. Ábrelo y completa el asistente: instala el **Android SDK**.
3. En **More Actions → SDK Manager → SDK Tools**, marca **Android SDK Command-line Tools** y aplica.
4. Acepta las licencias:
   ```bash
   flutter doctor --android-licenses
   ```
5. Para probar en un teléfono: activa **Opciones de desarrollador** y **Depuración USB**, conéctalo y verifica que aparezca con `flutter devices`.
6. Para probar en emulador: crea uno en **Device Manager**. En Windows puede pedir activar la virtualización en la BIOS.

Si en Linux el teléfono no aparece en `flutter devices`, instala `sudo apt install android-sdk-platform-tools-common`.

---

## 3. Git y GitHub (una sola vez)

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-correo-de-github"
git config --global init.defaultBranch main
```

Si tu correo es privado en GitHub, usa el que aparece en **GitHub → Settings → Emails**, con esta forma: `12345678+usuario@users.noreply.github.com`.

**Iniciar sesión:**
- **Windows:** la primera vez que hagas `git clone` o `git push`, se abre el navegador para iniciar sesión.
- **macOS:** `brew install gh` y luego `gh auth login`. También funciona el inicio de sesión por el navegador al primer push.
- **Linux:** `sudo apt install -y gh` y luego `gh auth login`.

En `gh auth login` elige: **GitHub.com → HTTPS → Yes → Login with a web browser**.

---

## 4. Clonar y preparar el proyecto (igual en los tres)

En Git Bash (Windows) o la terminal (Linux y macOS):

```bash
mkdir -p ~/deposito && cd ~/deposito
git clone https://github.com/gerardoleon4/deposito-app.git
cd deposito-app
git checkout develop
```

```bash
cd backend
dart pub get
cd ../app
flutter pub get
cd ..
```

Verifica que todo esté bien:

```bash
flutter doctor
```

Lo que aparezca en rojo sobre **Xcode** o **CocoaPods** se puede ignorar si no vas a compilar para iOS. En Windows, lo relacionado con **Visual Studio** también, porque el proyecto solo compila para Android e iOS.

### Probar el backend

```bash
cd backend
dart run bin/server.dart
```

Abre <http://localhost:8080/salud>: debe responder `ok`. Detén el servidor con `Ctrl + C`.

La primera vez puede tardar unos segundos, porque se prepara la librería de SQLite. Hazlo con internet. Si marca un error en ese paso, mándale la captura a Gerardo.

---

## 5. Firewall: para que los teléfonos vean el servidor de tu laptop

Cuando corras el backend en tu computadora y otro dispositivo quiera conectarse, el firewall puede bloquearlo:

- **Windows:** la primera vez aparece un aviso de Windows Defender. Marca **Redes privadas** y **Permitir acceso** para `dart`.
- **macOS:** aparece "¿Quieres que dart acepte conexiones entrantes?". Elige **Permitir**.
- **Linux:** si tienes `ufw` activo, ejecuta `sudo ufw allow 8080/tcp`.

Tu laptop y el teléfono deben estar en la **misma red Wi-Fi**. Para conocer la IP de tu laptop:

| Sistema | Comando |
| --- | --- |
| Linux | `hostname -I` |
| macOS | `ipconfig getifaddr en0` |
| Windows (Git Bash) | `ipconfig` y busca la **Dirección IPv4** |

---

## 6. Diferencias que conviene conocer

| Tema | Linux | Windows (Git Bash) | macOS |
| --- | --- | --- | --- |
| Reemplazar texto en un archivo | `sed -i 's/a/b/' archivo` | igual que Linux | `sed -i '' 's/a/b/' archivo` (lleva comillas vacías) |
| Carpeta de descargas | `~/Descargas` o `~/Downloads` | `~/Downloads` | `~/Downloads` |
| Abrir la carpeta actual | `xdg-open .` | `explorer .` | `open .` |
| Ruta de la carpeta de usuario | `/home/usuario` | `/c/Users/usuario` | `/Users/usuario` |
| Archivos basura que Git ignora | `.idea/` | `Thumbs.db`, `.idea/` | `.DS_Store` |

**Rutas en el código:** en `backend/`, arma las rutas de archivos con el paquete `path` (`p.join(...)`), nunca con `/` o `\` escritas a mano. En `pubspec.yaml` las rutas siempre llevan `/`, también en Windows (`path: ../backend`).

---

## 7. Si algo falla

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| `flutter: command not found` | El PATH no se aplicó | Cierra y abre la terminal; revisa el PATH |
| `flutter pub get` falla en Windows con un error de symlink | Falta el Modo de desarrollador | Actívalo (paso de Windows) |
| Un archivo aparece completamente modificado en Git | Saltos de línea de Windows | Confirma que existe `.gitattributes` en la raíz y ejecuta `git add --renormalize .` |
| `flutter devices` no muestra el teléfono | Depuración USB apagada o cable de solo carga | Activa la depuración USB y prueba otro cable |
| El teléfono no llega al servidor de la laptop | Firewall o red distinta | Sección 5 y verifica que estén en el mismo Wi-Fi |
| `Waiting for another flutter command to release the startup lock` | Otro proceso de Flutter abierto | Cierra VS Code y las terminales; vuelve a intentar |
| Versión distinta de Flutter | `stable` avanzó | Sección "Fijar la versión" |
