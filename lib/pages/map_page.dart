import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  List<Marker> _bioskopMarkers = [];

  @override
  void initState() {
    super.initState();
    _loadBioskopMarkers();
  }

  Future<void> _loadBioskopMarkers() async {
    final geojsonStr =
        await rootBundle.loadString('assets/bioskop_diy.geojson');
    final data = jsonDecode(geojsonStr);
    final features = data['features'] as List;

    List<Marker> markers = [];

    for (var feature in features) {
      final geometry = feature['geometry'];
      final properties = feature['properties'];

      if (geometry['type'] == 'Point') {
        final coords = geometry['coordinates'];
        final lon = coords[0];
        final lat = coords[1];
        final name = properties['name'] ?? 'Bioskop';

        print('Marker: $name at ($lat, $lon)');

        markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(lat, lon),
            child: Tooltip(
              message: name,
              child: const Icon(Icons.movie, color: Colors.red),
            ),
          ),
        );
      } else {
        print('Skipped geometry type: ${geometry['type']}');
      }
    }

    setState(() {
      _bioskopMarkers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peta Bioskop di Yogyakarta')),
      body: FlutterMap(
        mapController: _mapController, // pasang controller
        options: MapOptions(
          center: LatLng(-7.797068, 110.370529),
          zoom: 11.5,
          interactiveFlags: InteractiveFlag.all,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _bioskopMarkers),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            child: const Icon(Icons.zoom_in),
            onPressed: () {
              _mapController.move(
                  _mapController.center, _mapController.zoom + 1);
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            child: const Icon(Icons.zoom_out),
            onPressed: () {
              _mapController.move(
                  _mapController.center, _mapController.zoom - 1);
            },
          ),
        ],
      ),
    );
  }
}
