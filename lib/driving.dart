import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class DrivingPage extends StatelessWidget {
  const DrivingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DrivingExample();
  }
}

class _DrivingExample extends StatefulWidget {
  final routePoints = <Point>[
    Point(latitude: 59.973325, longitude: 30.297399),
    Point(latitude: 59.971271, longitude: 30.302002),
    Point(latitude: 59.968148, longitude: 30.299633),
    Point(latitude: 59.965728, longitude: 30.305716),
    Point(latitude: 59.957584, longitude: 30.293175),
  ];

  @override
  _DrivingExampleState createState() => _DrivingExampleState();
}

class _DrivingExampleState extends State<_DrivingExample> {
  List<MapObject> mapObjects = <MapObject>[];
  late Polyline polyline;
  Placemark? carPlacemark;

  Placemark get startPlace => Placemark(
        mapId: const MapObjectId('start_place'),
        point: Point(
            latitude: widget.routePoints.first.latitude,
            longitude: widget.routePoints.first.longitude),
        onTap: (Placemark self, Point point) {
          setState(() {
            widget.routePoints.removeAt(0);
            mapObjects.remove(carPlacemark);
            carPlacemark = startPlace;
            mapObjects.add(carPlacemark!);
          });
        },
        opacity: 1,
        direction: bearingBetweenLocations(
            widget.routePoints.first, widget.routePoints[1]),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            anchor: const Offset(0.5, 0.8),
            scale: 1.5,
            image: BitmapDescriptor.fromAssetImage('lib/assets/car2red3.png'),
            rotationType: RotationType.rotate)),
      );
  Placemark get finishPlace => Placemark(
        mapId: const MapObjectId('finish_place'),
        point: Point(
            latitude: widget.routePoints.last.latitude,
            longitude: widget.routePoints.last.longitude),
        //onTap: (Placemark self, Point point) => print('Tapped me at $point'),
        opacity: 0.7,
        direction: 0,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            anchor: const Offset(0.5, 0.8),
            image:
                BitmapDescriptor.fromAssetImage('lib/assets/route_start.png'),
            rotationType: RotationType.rotate)),
      );

  double bearingBetweenLocations(Point latLng1, Point latLng2) {
    double lat1 = latLng1.latitude * pi / 180;
    double long1 = latLng1.longitude * pi / 180;
    double lat2 = latLng2.latitude * pi / 180;
    double long2 = latLng2.longitude * pi / 180;

    double dLon = (long2 - long1);

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double brng = atan2(y, x);

    brng = brng * 180 / pi;
    brng = (brng + 360) % 360;

    return brng;
  }

  @override
  Widget build(BuildContext context) {
    _setMapObjects();
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          Expanded(
              child: YandexMap(
            mapObjects: mapObjects,
            rotateGesturesEnabled: false,
            onMapCreated: (c) => _mapCreate(c),
          )),
          const SizedBox(height: 20),
          // Expanded(
          //     child: SingleChildScrollView(
          //         child: Column(children: [
          // ControlButton(
          //   onPressed: _requestRoutes,
          //   title: 'Build route',
          // ),
          //]
        ]);
  }

  YandexMapController? mapController;
  _mapCreate(YandexMapController c) {
    mapController = c;
    _setMapBounds();
  }

  void _setMapBounds() {
    BoundingBox box = BoundingBox(
        northEast: _getNordEast(polyline.coordinates),
        southWest: _getSouthWest(polyline.coordinates));
    mapController!.setBounds(boundingBox: box, animation: const MapAnimation());
  }

  void _addRoute() {
    polyline = Polyline(
      mapId: const MapObjectId('polylineId'),
      coordinates: widget.routePoints,
      strokeColor: Colors.orange[700]!,
      strokeWidth: 5.0, // default value 5.0, this will be a little bold
      outlineColor: Colors.yellow[200]!,
      outlineWidth: 2.0,
      //onTap: (Polyline self, Point point) => print('Tapped me at $point'),
    );
    mapObjects.add(polyline);
  }

  final delta = 0.002;
  Point _getNordEast(List<Point> list) {
    double maxLatitude = double.negativeInfinity;
    double maxLongitude = double.negativeInfinity;
    for (var item in list) {
      maxLatitude = max(maxLatitude, item.latitude);
      maxLongitude = max(maxLongitude, item.longitude);
    }
    return Point(
        latitude: maxLatitude + delta, longitude: maxLongitude + delta);
  }

  Point _getSouthWest(List<Point> list) {
    double minLatitude = double.infinity;
    double minLongitude = double.infinity;
    for (var item in list) {
      minLatitude = min(minLatitude, item.latitude);
      minLongitude = min(minLongitude, item.longitude);
    }
    return Point(
        latitude: minLatitude - delta, longitude: minLongitude - delta);
  }

  void _setMapObjects() {
    if (mapObjects.isNotEmpty) {
      mapObjects.clear();
      carPlacemark = startPlace;
      mapObjects.add(carPlacemark!);
      mapObjects.add(finishPlace);
      _addRoute();
    }
  }
}
