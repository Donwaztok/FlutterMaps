import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location_permissions/location_permissions.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(-23.5607, -46.6293);
const LatLng DEST_LOCATION = LatLng(-23.5747, -46.6369);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<LatLng> path = [];
  PolylinePoints polylinePoints = PolylinePoints();
  static LatLng latLng;
  LocationData currentLocation;

  static const String googleAPIKey = 'AIzaSyASspOu0rSMaUOR28MNDZlkEhspkWnKkJo';

  @override
  void initState() {
    super.initState();
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(
          Marker(markerId: MarkerId('sourcePin'), position: SOURCE_LOCATION));
      // destination pin
      _markers
          .add(Marker(markerId: MarkerId('destPin'), position: DEST_LOCATION));
    });
  }

  void requestPermission() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    var location = new Location();
    location.onLocationChanged().listen((currentLocation) {
      setState(() {
        latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
        path.add(latLng);
      });
    });
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        SOURCE_LOCATION.latitude,
        SOURCE_LOCATION.longitude,
        DEST_LOCATION.latitude,
        DEST_LOCATION.longitude);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      Polyline polylinePath = Polyline(
          polylineId: PolylineId("polyPath"),
          color: Color.fromARGB(180, 90, 90, 90),
          points: path);

      Polyline polyline = Polyline(

          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      _polylines.add(polyline);
      _polylines.add(polylinePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SOURCE_LOCATION);

    requestPermission();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: GoogleMap(
            myLocationEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            initialCameraPosition: initialLocation,
            onMapCreated: onMapCreated),
      ),
    );
  }
}
