📖 Kader Pokédex

Kader Pokédex es una aplicación desarrollada en Flutter que permite explorar Pokémon utilizando la API de PokéAPI. La aplicación carga y muestra una lista de Pokémon con imágenes, permitiendo búsqueda, favoritos, filtros por tipo y ordenamiento.

🚀 Características

📜 Lista de Pokémon con imágenes y nombres.

🔍 Búsqueda en tiempo real de Pokémon por nombre.

🔄 Carga infinita: Se cargan más Pokémon automáticamente al hacer scroll.

🔄 Pull to refresh para actualizar la lista.

⭐ Sistema de favoritos con almacenamiento local.

🎨 Interfaz mejorada con Material Design y colores según tipo de Pokémon.

🌙 Modo oscuro para mejor experiencia visual.

🔀 Modo aleatorio: Muestra un Pokémon al azar.

📊 Ordenamiento por nombre o número en la Pokédex.

🔔 Notificaciones locales al marcar un Pokémon como favorito.

⚠️ Manejo de errores si la API falla o no hay conexión a Internet.

🛠️ Tecnologías Utilizadas

Flutter - Framework principal.

Dart - Lenguaje de programación.

PokéAPI - API de datos de Pokémon.

SharedPreferences - Almacenamiento de favoritos.

Flutter Local Notifications - Notificaciones locales.

📂 Estructura del Proyecto

La estructura del proyecto está organizada de la siguiente manera:

lib/
├── 📂 class/          # Clases generales y controladores
│   ├── theme.dart    # Configuración de temas
│
├── 📂 data/           # Módulo de acceso a datos
│   ├── api_service.dart  # Clase para obtener datos de la API
│
├── 📂 screens/        # Pantallas de la aplicación
│   ├── home_screen.dart   # Pantalla principal con la lista de Pokémon
│   ├── detail_screen.dart # Vista detallada de un Pokémon
│
├── 📂 widgets/        # Componentes reutilizables
│   ├── pokemon_card.dart # Tarjetas de Pokémon con diseño atractivo
│
├── main.dart          # Archivo principal que inicializa la app

📦 Instalación y Ejecución

Clona el repositorio:

git clone https://github.com/tu-usuario/kader-pokedex.git

Navega al directorio del proyecto:

cd kader-pokedex

Instala las dependencias:

flutter pub get

Ejecuta la aplicación:

flutter run

📸 Capturas de Pantalla

Agrega capturas de pantalla aquí

🛠 Mejoras Futuras

Integración con base de datos local (sqflite) para optimizar la carga de datos.

Sonidos al interactuar con los Pokémon.

Comparador de Pokémon con estadísticas.

📄 Licencia

Este proyecto está bajo la licencia MIT. Puedes ver más detalles en el archivo LICENSE.

¡Esperamos que disfrutes explorando el mundo de los Pokémon con Kader Pokédex! 🎉
