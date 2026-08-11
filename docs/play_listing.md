# Ficha de Google Play — Nexa Voice AI

Borrador listo para copiar y pegar en Play Console.

---

## 1. Nombre y datos básicos

- **Nombre de la aplicación**: `Nexa Voice AI`
- **ApplicationId**: `com.nexa.voiceai`
- **Versión**: `1.0.0 (1)`
- **Categoría**: Comunicación → Comunicación / Social

## 2. Título corto / Short description (máx. 80 caracteres)

```
Traduce conversaciones y llamadas de voz en tiempo real.
```
*(54 caracteres. Alternativa EN: `Translate voice conversations and calls in real time.`)*

## 3. Descripción completa (máx. 4000 caracteres)

### Español

```
Habla sin barreras. Nexa Voice AI traduce tus conversaciones y llamadas de voz en tiempo real, entre dos idiomas distintos, con un solo toque.

¿CÓMO FUNCIONA?
• Mantén pulsado el micrófono y habla en tu idioma.
• La app transcribe tu voz y la traduce al idioma de tu interlocutor al instante.
• La traducción aparece en pantalla y, si lo activas, se lee en voz alta para que la conversación fluya de forma natural.

CARACTERÍSTICAS PRINCIPALES
• Conversación cara a cara: dos personas, dos idiomas, una sola pantalla.
• Llamadas en línea: conversaciones traducidas entre dos teléfonos en tiempo real.
• Reconocimiento de voz para más de 100 idiomas.
• Traducción en el dispositivo (offline) con Google ML Kit cuando no hay conexión.
• Traducción en la nube de mayor calidad cuando hay internet.
• Texto a voz para escuchar las traducciones.
• Perfiles personalizables con nombre y foto para cada participante.

PRIVACIDAD
• El audio solo se convierte a texto; no se guardan grabaciones.
• Tus ajustes y fotos permanecen en tu dispositivo.
• No mostramos anuncios ni vendemos tus datos.
```

### English

```
Speak without barriers. Nexa Voice AI translates your voice conversations and calls in real time, between two different languages, with a single touch.

HOW IT WORKS
• Hold the microphone and speak in your language.
• The app transcribes your voice and instantly translates it to your partner's language.
• The translation appears on screen and, if enabled, is read aloud so the conversation flows naturally.

KEY FEATURES
• Face-to-face conversation: two people, two languages, one screen.
• Online calls: real-time translated calls between two phones.
• Speech recognition for 100+ languages.
• On-device (offline) translation with Google ML Kit when there is no connection.
• Higher-quality cloud translation when online.
• Text-to-speech to hear translations.
• Customizable profiles with name and photo for each participant.

PRIVACY
• Audio is only converted to text; no recordings are stored.
• Your settings and photos stay on your device.
• No ads and no selling of your data.
```

## 4. Release notes (v1.0.0)

```
Primera versión de Nexa Voice AI: traducción de conversaciones cara a cara y llamadas en línea en tiempo real, reconocimiento de voz en más de 100 idiomas, traducción offline en el dispositivo y texto a voz.
```

## 5. Elementos gráficos

- **Icono**: `branding/app_icon_512.png` (512×512) — ya generado.
- **Capturas de pantalla**: mínimo 2 (teléfono). Recomendado: pantalla de inicio, conversación cara a cara, llamada en línea, ajustes.
- **Feature graphic** (1024×500, opcional pero recomendado): no generado.
- **Vídeo promocional**: opcional.

## 6. Cuestionario de clasificación por contenido (Content rating)

- Categoría de la app: **Comunicación**.
- Sin violencia, sin contenido sexual, sin drogas ni juegos de azar, sin lenguaje inapropiado.
- Resultado esperado: **3+ (Todos) / PEGI 3**.

## 7. Declaración "Seguridad de los datos" (Data safety)

### 7.1. ¿Se recogen o comparten datos?
**Sí, se recogen algunos datos.** (No se comparten con terceros para publicidad; el texto se envía a Google para la traducción en la nube, que debe declararse como "compartido con terceros" en el uso de la función).

### 7.2. Datos declarados y cómo

| Tipo de dato | Recogido | Compartido | Uso | Tratamiento |
|---|---|---|---|---|
| **Audio o grabaciones de sonido** | **No** (el audio solo se transcribe en el momento, no se guarda) | — | — | — |
| **Datos personales: Nombre** | Sí | Sí (con el otro participante de la llamada vía Firebase) | Características de la app / personalización | Cifrado en tránsito |
| **Mensajes / otro contenido del usuario (texto transcrito y traducciones)** | Sí | Sí (con el otro participante y con Google en la traducción en la nube) | Características de la app (traducción de la llamada) | Cifrado en tránsito |
| **Actividad en la app (idiomas usados, marcas de tiempo de sesión)** | Sí | No | Análisis interno / funcionamiento | Agregada o cifrada en tránsito |

> Nota: en el formulario de Play, marca el **micrófono** en "Permisos de la aplicación". El audio no se guarda, por lo que en "Audio o grabaciones de sonido" responde **No** (se usa el permiso pero no se almacena contenido de audio).

### 7.3. Promesas del formulario
- **Cifrado en tránsito**: Sí (HTTPS/TLS).
- **Eliminación de datos**: Sí — el usuario puede eliminar los datos de la app (ajustes locales) y las sesiones de llamada.
- **No se permite la venta de datos**: Sí (marcar "La app no vende datos de usuarios").
- **¿La app recopila datos con fines publicitarios?** No.

## 8. Declaración de política y acceso

- **Política de privacidad**: URL donde alojes `docs/privacy_policy.html` (ver guía de publicación).
- **Correo electrónico de contacto**: tu correo.
- **¿La app requiere "acceso total" (Accessibility) o Notificaciones B2B?** No.
- **¿La app incluye anuncios?** No.

## 9. Pruebas internas (antes de producción)

1. Sube el AAB en "Testers internos" → "Tracks" → "Internal testing".
2. Añade tus correos como testers y descarga desde Play con el mismo AAB firmado.
3. Prueba: cara a cara, llamada en línea, traducción offline (modo avión) y ajustes.
4. Cuando valides, crea el release en "Production".
