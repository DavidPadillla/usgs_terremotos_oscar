# USGS Terremotos — Taller de Computación Móvil

Aplicación Flutter que consume la **USGS Earthquake Catalog API** (FDSN Event
Web Service) para listar sismos recientes, ver su detalle y ubicarlos en un
mapa, siguiendo el mockup entregado en la Actividad 2.

## 1. Cómo ejecutarla

```bash
flutter pub get
flutter run
```

No requiere API Key: el servicio de USGS es público. El mapa usa teselas de
OpenStreetMap (tampoco requiere credenciales).

## 2. Arquitectura de carpetas

El código del profesor venía en un único `main.dart`. Aquí se separó en
capas siguiendo el patrón **presentación → lógica → datos**, que es el
estándar recomendado para proyectos Flutter de tamaño mediano:

```
lib/
├── main.dart                          # Arranque de la app y wiring del Provider
├── config/                            # Configuración y constantes
│   ├── app_constants.dart             # URL base, parámetros por defecto, zoom
│   └── app_theme.dart                 # Colores y ThemeData centralizados
├── data/                              # CAPA DE DATOS
│   ├── models/
│   │   └── terremoto.dart             # Clase Terremoto + fromJson/listFromGeoJson
│   ├── services/
│   │   └── earthquake_api_service.dart# Único punto que hace peticiones http.get
│   └── repositories/
│       └── earthquake_repository.dart # Orquesta el service y entrega objetos de dominio
├── logic/                             # CAPA DE LÓGICA / ESTADO
│   ├── providers/
│   │   └── earthquake_provider.dart   # ChangeNotifier: estado (cargando/error/datos)
│   ├── analytics/
│   │   └── earthquake_chart_catalog.dart # Catálogo y agregaciones para 64 gráficas
│   └── utils/
│       └── date_formatter.dart        # Formato de fechas y "hace X horas"
└── presentation/                      # CAPA DE PRESENTACIÓN
    ├── screens/
    │   ├── main_navigation_screen.dart    # Navegación Lista/Mapa/Gráficas/Contacto
    │   ├── analytics_screen.dart          # Catálogo, filtros y detalle de gráficas
    │   ├── earthquake_list_screen.dart    # Pantalla 1 del mockup
    │   ├── earthquake_detail_screen.dart  # Pantalla 2 del mockup
    │   ├── earthquake_map_screen.dart     # Pantalla 3 del mockup
    │   └── contact_screen.dart
    └── widgets/
        ├── charts/
        │   ├── chart_helpers.dart        # Ejes, escalas y etiquetas compartidos
        │   ├── chart_presentation_helpers.dart # Resúmenes, leyendas y tooltips
        │   ├── chart_style_widgets.dart  # Adaptadores de estilos y librerías
        │   ├── earthquake_chart_renderer.dart # Motor compartido de renderizado
        │   └── earthquake_chart_view.dart # Selector, tarjeta y estado vacío
        ├── earthquake_card.dart       # Tarjeta de la lista
        ├── magnitude_badge.dart       # Círculo de magnitud (reutilizado 3 veces)
        ├── loading_view.dart          # Estado de carga
        └── error_view.dart            # Estado de error + botón reintentar
```

### Por qué esta separación

- **`data/`** no sabe nada de Flutter ni de la UI. Si mañana cambia la API o
  se agrega caché local, solo se toca esta capa.
- **`logic/`** (el `EarthquakeProvider`) es el único puente entre datos y
  pantallas. Las pantallas nunca llaman `http` directamente.
- **`presentation/`** solo se preocupa de pintar según el estado que expone
  el provider (`inicial`, `cargando`, `cargado`, `error`), y de widgets
  reutilizables (`EarthquakeCard`, `MagnitudeBadge`, etc.) para no duplicar
  código entre Lista, Detalle y Mapa.

## 3. Manejo de errores y estados de carga

`EarthquakeProvider` expone un `enum EarthquakeStatus` con cuatro valores.
Cada pantalla que consume datos (`EarthquakeListScreen`, `EarthquakeMapScreen`)
hace un `switch`/`if` sobre ese estado y muestra:

- `LoadingView` mientras se consulta la API.
- `ErrorView` con mensaje legible y botón "Reintentar" si falla la red o la
  API responde con error (manejado con `EarthquakeApiException` en
  `earthquake_api_service.dart`).
- La lista o el mapa cuando los datos llegaron correctamente.

## 4. Integración con la API

- `EarthquakeApiService` arma la URL con los parámetros del contrato
  (`format`, `starttime`, `endtime`, `minmagnitude`, `orderby`, `limit`) y
  hace el `GET` con `http`, con timeout de 15s.
- La consulta usa un límite de 500 eventos (el servicio admite hasta 20.000),
  conserva el rango de 30 días y filtra magnitudes desde 4.5.
- `EarthquakeRepository` decide el rango de fechas (últimos 30 días) y
  convierte el JSON crudo a `List<Terremoto>` usando
  `Terremoto.listFromGeoJson`.
- `EarthquakeProvider.cargarTerremotos()` llama al repositorio, actualiza el
  estado y notifica a la UI con `notifyListeners()`.

## 5. Guion sugerido para el video explicativo

1. **Funcionamiento**: abre la app → pestaña Lista carga sismos recientes →
   toca una tarjeta → Detalle con mapa del epicentro → pestaña Mapa con
   todos los marcadores y tarjeta resumen al tocar uno.
2. **Arquitectura de carpetas**: muestra `lib/` y explica
   `data / logic / presentation`, señalando que replica lo visto en clase
   sobre organización de proyectos Flutter.
3. **Integración de la API**: abre `earthquake_api_service.dart` y
   `earthquake_repository.dart`, explica el `Uri.replace(queryParameters:)`
   y el manejo de errores con `EarthquakeApiException`.
4. **Estado y patrones**: abre `earthquake_provider.dart`, explica el patrón
   `ChangeNotifier` + `Consumer` de `provider`, y el enum de estados.
5. **Diseño**: menciona el `MagnitudeBadge` coloreado por severidad, el tema
   centralizado en `app_theme.dart`, y el mapa con OpenStreetMap sin
   necesidad de API Key.

## 6. Funcionalidades extra agregadas

- Colores dinámicos según magnitud (verde/naranja/rojo) en tarjetas, badge y
  marcadores del mapa.
- Pull-to-refresh en la lista.
- Controles de zoom (+/-) y de centrado en el mapa general.
- Botón para abrir la ficha oficial del sismo en el sitio de USGS.
- Texto de "tiempo transcurrido" (hace X horas/días) como en el mockup.

## 7. Estadísticas y gráficas

La pestaña **Gráficas** presenta 64 gráficas: 32 con `fl_chart` y 32 con
`graphic`. Cada librería ofrece 20 gráficas básicas y 12 avanzadas. Las dos
librerías se pueden filtrar desde la pantalla de estadísticas. Cada gráfica
muestra un resumen calculado con sus datos, resalta el valor máximo y ofrece
leyendas y tooltips al tocar los datos; las líneas incluyen una guía de lectura
interactiva. Barras, líneas, puntos y sectores se animan al entrar o actualizarse.

Las gráficas reutilizan `EarthquakeProvider.terremotos`; no hacen consultas
individuales a USGS. `earthquake_chart_catalog.dart` agrupa y calcula conteos,
promedios, rangos, series cronológicas y relaciones entre magnitud y
profundidad. Se pueden filtrar por nivel y librería y abrir cada gráfica para
verla en detalle. La actualización de la pestaña vuelve a cargar los datos
desde el proveedor compartido.

La consulta actual trae como máximo 500 eventos de los últimos 30 días con
magnitud mínima de 4.5, por lo que los resultados de las gráficas están
limitados a ese conjunto.

La vista selecciona el adaptador según la librería y el tipo de gráfica. Las
tarjetas respetan los temas claro y oscuro y amplían el lienzo si hay muchas
etiquetas. Con menos de dos sismos se muestra una explicación amigable en vez
de una gráfica sin datos comparables.
