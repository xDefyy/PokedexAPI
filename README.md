# 🎮 Kader Pokédex

Kader Pokédex es una aplicación desarrollada en Flutter que permite explorar Pokémon utilizando la API de [PokéAPI](https://pokeapi.co/). La aplicación carga y muestra una lista de Pokémon con imágenes, permitiendo búsqueda, favoritos, filtros por tipo y ordenamiento.

---

## ✨ Funcionalidades Principales
- 📌 **Explora Pokémon** con imágenes y nombres.
- 🔎 **Búsqueda en tiempo real** de Pokémon por nombre.
- 📜 **Carga infinita**: Se cargan más Pokémon automáticamente al hacer scroll.
- 🔄 **Actualización rápida** con "pull to refresh".
- ⭐ **Sistema de favoritos** con almacenamiento local.
- 🎨 **Diseño atractivo** con Material Design y colores dinámicos según el tipo de Pokémon.
- 🌙 **Modo oscuro** para una experiencia visual optimizada.
- 🎲 **Modo aleatorio**: Descubre un Pokémon al azar.
- 📊 **Ordenamiento flexible** por nombre o número en la Pokédex.
- 🔔 **Notificaciones locales** al marcar un Pokémon como favorito.
- ⚠️ **Manejo de errores** para garantizar una experiencia sin interrupciones.

---

## 🛠️ Tecnologías y Herramientas
- 🚀 **[Flutter](https://flutter.dev/)** - Framework principal.
- 💻 **[Dart](https://dart.dev/)** - Lenguaje de programación.
- 🎮 **[PokéAPI](https://pokeapi.co/)** - API de datos de Pokémon.
- 💾 **[SharedPreferences](https://pub.dev/packages/shared_preferences)** - Almacenamiento de favoritos.
- 🔔 **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)** - Notificaciones locales.

---

## 📁 Estructura del Proyecto
La estructura del proyecto está organizada de la siguiente manera:

```
lib/
├── 📂 class/           # Clases generales y controladores
│   ├── theme.dart     # Configuración de temas
│
├── 📂 data/            # Módulo de acceso a datos
│   ├── api_service.dart  # Clase para obtener datos de la API
│
├── 📂 screens/         # Pantallas de la aplicación
│   ├── home_screen.dart   # Pantalla principal con la lista de Pokémon
│   ├── detail_screen.dart # Vista detallada de un Pokémon
│
├── 📂 widgets/         # Componentes reutilizables
│   ├── pokemon_card.dart  # Tarjetas de Pokémon con diseño atractivo
│
├── main.dart           # Archivo principal que inicializa la app
```

---

## 🔧 Instalación y Configuración
### 1️⃣ Clonar el repositorio
```sh
git clone https://github.com/tu-usuario/kader-pokedex.git
```
### 2️⃣ Navegar al directorio del proyecto
```sh
cd kader-pokedex
```
### 3️⃣ Instalar las dependencias necesarias
```sh
flutter pub get
```
### 4️⃣ Ejecutar la aplicación
```sh
flutter run
```

---

## 📷 Capturas de Pantalla
_Añade aquí capturas de pantalla de la aplicación en funcionamiento._

---

## 🔮 Mejoras Futuras
- 📂 **Base de datos local (sqflite)** para optimizar la carga de datos.
- 🎵 **Sonidos al interactuar con los Pokémon** para mayor inmersión.
- ⚖️ **Comparador de Pokémon** con estadísticas detalladas.

---

## 📜 Licencia
Este proyecto está bajo la licencia MIT. Consulta más detalles en el archivo [LICENSE](LICENSE).

---

🚀 ¡Disfruta explorando el mundo de los Pokémon con Kader Pokédex! 🎉

