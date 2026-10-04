# Guía Visual y Sistema de Diseño — Nexo POS

Documento de referencia para el equipo de frontend. Define los tokens visuales, tipografía, paleta de colores y componentes base según el diseño de Figma.

---

## 1. Identidad de Marca

- **Nombre de marca:** `nexo POS`
- **"nexo":** Tipografía Inter Bold, color `#1F2937`
- **"POS":** Tipografía Inter SemiBold, color `#4285F4`

---

## 2. Tipografía

- **Fuente primaria:** Inter
- **Pesos:**
  - Light (300)
  - Regular (400)
  - Medium (500)
  - SemiBold (600)
  - Bold (700)

### Escala de Tamaños
| Elemento | Tamaño | Peso |
| --- | --- | --- |
| **Título de pantalla** | 24–32px | SemiBold (600) |
| **Título de modal** | 18–20px | SemiBold (600) |
| **Título de tarjeta** | 16px | SemiBold (600) |
| **Texto normal** | 13–14px | Regular (400) |
| **Texto secundario** | 12px | Regular (400) |
| **Etiquetas / Badges** | 10–11px | Medium (500) / SemiBold (600) |
| **Cifras importantes** | 28–48px | Medium (500) |

---

## 3. Paleta de Colores

### 3.1 Colores Principales
- **Azul principal:** `#4285F4` (Acciones primarias)
- **Azul presionado:** `#2F6FDB`
- **Fondo azul suave:** `#F4F8FF`
- **Borde azul suave:** `#C9DCFF`

### 3.2 Superficies y Textos
- **Fondo principal:** `#FFFFFF`
- **Fondo secundario:** `#F9FAFB`
- **Bordes y divisores:** `#E5E7EB`
- **Texto principal:** `#111827`
- **Texto secundario:** `#1F2937`
- **Texto gris:** `#6B7280`
- **Texto tenue:** `#9CA3AF`

### 3.3 Colores de Estado
- **Error:** `#EF4444` \| **Fuerte:** `#DC2626` \| **Fondo:** `#FEF2F2` \| **Borde:** `#FECACA`
- **Éxito:** `#15803D` \| **Texto:** `#166534` \| **Fondo:** `#F0FDF4`
- **Advertencia:** `#B45309` \| **Fondo:** `#FFFBEB` \| **Borde:** `#FDE68A`

---

## 4. Bordes y Radios (Border Radius)

- **Borde estándar:** 1px solid `#E5E7EB`
- **Borde activo:** 1px solid `#4285F4`
- **Borde de error:** 1px solid `#EF4444`
- **Focus ring:** Azul `#4285F4` con opacidad del 12% al 24%

### Esquinas Redondeadas
- **Inputs:** 10–11px
- **Botones:** 11–13px
- **Tarjetas:** 14–15px
- **Modales:** 18–20px
- **Bottom sheets:** 24px
- **Badges:** 999px (Pill shape)
- **Avatares:** 50% (Circular)

---

## 5. Especificaciones de Componentes

### 5.1 Botones
- **Principal:** Fondo `#4285F4`, texto `#FFFFFF` (Inter SemiBold), altura 48–56px, radio 11–13px. Presionado: `#2F6FDB`.
- **Deshabilitado:** Fondo `#E5E7EB`, texto `#9CA3AF`, sin sombra.
- **Secundario:** Fondo `#FFFFFF`, texto `#1F2937`, borde `#E5E7EB`.
- **Danger (Peligro):** Fondo `#FEF2F2`, texto `#DC2626`, borde `#FECACA`.

### 5.2 Campos de Entrada (Inputs)
- **Fondo:** `#FFFFFF`
- **Texto / Placeholder:** `#111827` / `#9CA3AF`
- **Bordes:** Normal `#E5E7EB` \| Focus `#4285F4` \| Error `#EF4444`
- **Altura:** 44–48px
- **Radio:** 10–11px

### 5.3 Tarjetas
- **Estado Normal:** Fondo `#FFFFFF`, borde `#E5E7EB`
- **Estado Seleccionado:** Fondo `#F4F8FF`, borde `#4285F4`
- **Radio:** 14–15px

---

## 6. Sombras y Animaciones

### Sombras
- **Sombra para tarjetas:** Negro al 7% opacidad, Offset Y: 8px, Blur: 24px
- **Sombra para modales:** Negro al 24% opacidad, Offset Y: 24px, Blur: 60px
- **Overlay modal normal:** Negro al 40% opacidad
- **Overlay modal crítico:** Negro al 48% opacidad

### Animaciones
- **Duración normal:** 160–180ms
- **Entrada de modal:** 300ms
- **Entrada de bottom sheet:** 350ms
- **Escala al presionar:** 0.96–0.98
- **Curva:** `easeOut`
