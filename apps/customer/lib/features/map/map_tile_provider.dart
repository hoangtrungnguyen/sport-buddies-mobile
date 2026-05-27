// Map tile provider — strategy pattern.
//
// Strategy selection: MapTileProvider.fromEnv() reads MAP_PROVIDER from the
// compile-time env. Add MAP_PROVIDER=google|vietmap to your .env file.
//
// | MAP_PROVIDER  | Strategy                  | Key required          |
// |---------------|---------------------------|-----------------------|
// | google (dflt) | GoogleMapsTileProvider    | GOOGLE_MAP_API_KEY    |
// | vietmap       | VietMapTileProvider       | VIETMAP_API_KEY       |
// | (missing key) | OpenStreetMapTileProvider | none (dev fallback)   |

import 'package:customer/core/env/env.dart';

/// Supplies the tile URL template consumed by flutter_map's TileLayer.
///
/// Concrete strategies implement [urlTemplate]. The active strategy is
/// resolved once at startup via [MapTileProvider.fromEnv].
abstract class MapTileProvider {
  const MapTileProvider();

  /// Selects the active provider from compile-time env vars.
  ///
  /// - `MAP_PROVIDER=google` (default) → [GoogleMapsTileProvider]
  ///   Uses `GOOGLE_MAP_API_KEY`; falls back to keyless Google endpoint
  ///   when the key is empty (dev/CI).
  /// - `MAP_PROVIDER=vietmap` → [VietMapTileProvider]
  ///   Requires `VIETMAP_API_KEY`; falls back to [OpenStreetMapTileProvider]
  ///   when the key is empty.
  factory MapTileProvider.fromEnv() {
    switch (Env.mapProvider) {
      case 'vietmap':
        final key = Env.vietmapApiKey;
        if (key.isEmpty) return const OpenStreetMapTileProvider();
        return VietMapTileProvider(apiKey: key);
      case 'google':
      default:
        return GoogleMapsTileProvider(apiKey: Env.googleMapApiKey);
    }
  }

  /// Tile URL template for flutter_map's [TileLayer].
  ///
  /// Must contain `{x}`, `{y}`, `{z}` placeholders — flutter_map substitutes
  /// them per tile request.
  String get urlTemplate;
}

// ---------------------------------------------------------------------------
// Concrete strategies
// ---------------------------------------------------------------------------

/// Google Maps raster tile strategy.
///
/// When [apiKey] is empty the unofficial `mt1.google.com` endpoint is used,
/// which is suitable for development. Set `GOOGLE_MAP_API_KEY` in `.env` for
/// production to avoid rate-limiting.
class GoogleMapsTileProvider implements MapTileProvider {
  const GoogleMapsTileProvider({this.apiKey = ''});

  final String apiKey;

  static const _baseUrl =
      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';

  @override
  String get urlTemplate =>
      apiKey.isEmpty ? _baseUrl : '$_baseUrl&key=$apiKey';
}

/// VietMap raster tile strategy (production, Vietnam-focused).
///
/// Requires a valid [apiKey] obtained from the VietMap developer portal.
/// Set `VIETMAP_API_KEY` in `.env`.
class VietMapTileProvider implements MapTileProvider {
  const VietMapTileProvider({required this.apiKey});

  final String apiKey;

  @override
  String get urlTemplate =>
      'https://maps.vietmap.vn/api/maps/raster/v1/{z}/{x}/{y}.png?apikey=$apiKey';
}

/// OpenStreetMap tile strategy — no API key required.
///
/// Used automatically as a fallback when the active provider's key is
/// missing (e.g. CI, local dev without a key).
class OpenStreetMapTileProvider implements MapTileProvider {
  const OpenStreetMapTileProvider();

  @override
  String get urlTemplate => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
