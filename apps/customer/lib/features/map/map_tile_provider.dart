// Map tile provider — strategy pattern.
//
// Strategy selection: MapTileProvider.fromEnv() reads MAP_PROVIDER from the
// compile-time env. Add MAP_PROVIDER=google|vietmap|general to your .env file.
//
// | MAP_PROVIDER  | Strategy                  | Key required          |
// |---------------|---------------------------|-----------------------|
// | google (dflt) | GoogleMapsTileProvider    | GOOGLE_MAP_API_KEY    |
// | vietmap       | VietMapGLProvider         | VIETMAP_API_KEY       |
// | general       | OpenStreetMapTileProvider | none (flutter_map)    |
// | (missing key) | OpenStreetMapTileProvider | none (dev fallback)   |

import 'package:customer/core/env/env.dart';

/// Discriminated union for the active map rendering backend.
///
/// - [RasterTileProvider] subtypes supply a [urlTemplate] for flutter_map's
///   `TileLayer` (Google raster, OSM, VietMap raster).
/// - [VietMapGLProvider] supplies a [styleUrl] for `vietmap_flutter_gl`'s
///   `VietMapGL` widget (vector tiles, native GL renderer).
sealed class MapTileProvider {
  const MapTileProvider();

  /// Selects the active provider from compile-time env vars.
  factory MapTileProvider.fromEnv() {
    switch (Env.mapProvider) {
      case 'vietmap':
        // Trim: env-injected keys can carry trailing whitespace, which would
        // corrupt the `?apikey=` query and silently blank the vector map.
        final key = Env.vietmapApiKey.trim();
        if (key.isEmpty) return const OpenStreetMapTileProvider();
        return VietMapGLProvider(apiKey: key);
      case 'general':
        return const OpenStreetMapTileProvider();
      case 'google':
      default:
        return GoogleMapsTileProvider(apiKey: Env.googleMapApiKey);
    }
  }
}

// ---------------------------------------------------------------------------
// Raster providers — used with flutter_map TileLayer
// ---------------------------------------------------------------------------

/// Base for all raster-tile providers.
sealed class RasterTileProvider extends MapTileProvider {
  const RasterTileProvider();

  /// XYZ tile URL template with `{x}`, `{y}`, `{z}` placeholders consumed by
  /// flutter_map's `TileLayer`.
  String get urlTemplate;
}

/// Google Maps raster tile strategy.
///
/// When [apiKey] is empty the unofficial `mt1.google.com` endpoint is used,
/// which is suitable for development. Set `GOOGLE_MAP_API_KEY` in `.env` for
/// production to avoid rate-limiting.
final class GoogleMapsTileProvider extends RasterTileProvider {
  const GoogleMapsTileProvider({this.apiKey = ''});

  final String apiKey;

  static const _baseUrl =
      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';

  @override
  String get urlTemplate =>
      apiKey.isEmpty ? _baseUrl : '$_baseUrl&key=$apiKey';
}

/// OpenStreetMap tile strategy — no API key required.
///
/// Used automatically as a fallback when the active provider's key is missing
/// (e.g. CI, local dev without a key).
final class OpenStreetMapTileProvider extends RasterTileProvider {
  const OpenStreetMapTileProvider();

  @override
  String get urlTemplate => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}

// ---------------------------------------------------------------------------
// VietMap GL provider — used with vietmap_flutter_gl VietMapGL widget
// ---------------------------------------------------------------------------

/// VietMap vector tile strategy backed by the native GL SDK.
///
/// Requires a valid [apiKey] from the VietMap developer portal
/// (https://maps.vietmap.vn/console-v2/). Set `VIETMAP_API_KEY` in `.env`.
///
/// Renders via `vietmap_flutter_gl`'s `VietMapGL` widget (Metal on iOS,
/// OpenGL ES on Android) — NOT flutter_map's `TileLayer`.
final class VietMapGLProvider extends MapTileProvider {
  const VietMapGLProvider({required this.apiKey});

  final String apiKey;

  /// Mapbox-style `style.json` URL consumed by `VietMapGL(styleString: ...)`.
  String get styleUrl =>
      'https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=$apiKey';
}
