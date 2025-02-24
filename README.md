# 📖 Kader Pokédex

Kader Pokédex es una aplicación desarrollada en Flutter que permite explorar Pokémon utilizando la API de [PokéAPI](https://pokeapi.co/). La aplicación carga y muestra una lista de Pokémon con imágenes, permite búsqueda y carga infinita a medida que el usuario se desplaza.

## 🚀 Características
- 📜 Lista de Pokémon con imágenes y nombres.
- 🔍 Búsqueda en tiempo real.
- 🔄 Carga automática de más Pokémon al desplazarse.
- 🔄 Funcionalidad de "pull to refresh" para actualizar la lista.

## 🛠️ Tecnologías Utilizadas
- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [PokéAPI](https://pokeapi.co/)

## 📂 Estructura del Proyecto
La estructura del proyecto está organizada de la siguiente manera:

📂 lib/  
├── 📂 models/          # Modelos de datos  
│   ├── pokemon.dart    # Modelo de Pokémon con conversión desde JSON  
│  
├── 📂 data/            # Módulo de acceso a datos  
│   ├── character_api.dart  # Clase para obtener Pokémon desde la API  
│  
├── 📂 screens/         # Pantallas de la aplicación  
│   ├── pokewidget.dart # Widget principal con la lista de Pokémon  
│  
├── main.dart           # Archivo principal que inicializa la app  

