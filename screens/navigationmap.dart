import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
class MapNav extends StatefulWidget {
  var dest_Latitude;
  var dest_Longitude;
  MapNav(this.dest_Latitude,this.dest_Longitude);
  @override
  _MapNavState createState() => _MapNavState();
}

class _MapNavState extends State<MapNav> {
  bool isVisible = false;
  Completer<GoogleMapController> _controller = Completer();
  Location location;
  Set<Polyline> _polyLine = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polyLinePoints = PolylinePoints();
  GoogleMapsServices _googleMapsServices = new GoogleMapsServices();
  String googleApiKey = "AIzaSyD1QQwpp3kGQlPLkYBdwXO59iDkQBwYoQ8";

  Set<Marker> _marker = Set<Marker>();
  LocationData currentLocation;
  LocationData destLocation;
  double cAMERA_ZOOM = 16;
  double cAMERA_TILT = 80;
  double cAMERA_BEARING = 30;
// LatLng dest_LOCATION = LatLng(42.747932,-71.167889);
  LatLng sOURCE_LOCATION = LatLng(82.8888, -71.167889);
  LatLng dest_LOCATION;
  List snap_points = [];
  BitmapDescriptor sourceIcon;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    print(widget.dest_Longitude.runtimeType);
    dest_LOCATION = LatLng(widget.dest_Latitude, widget.dest_Longitude);
    print("Entered");
    location = new Location();

    super.initState();

    setInitialLocations();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
  setInitialLocations() async {
   /* sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 2.5,
        size: Size(2, 2)),
        
         'assets/car-gps-2-512.png',
         );*/
    //final Uint8List markerIcon = await getBytesFromAsset('assets/images/flutter.png', 100);
    getBytesFromAsset('assets/car-gps-2-512.png', 200).then((onValue) {
      sourceIcon =BitmapDescriptor.fromBytes(onValue);

    });
    print("Getting Location");
    currentLocation = await location.getLocation();
    setState(() {});
    print(currentLocation);
    destLocation = LocationData.fromMap({
      'latitude': dest_LOCATION.latitude,
      'longitude': dest_LOCATION.longitude
    });
    print(destLocation);
     
  }

  showPins(controller) {
    
    print("showing");
    print(currentLocation);

    if (currentLocation != null) {
      print("showing pins");
      var sourcePosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      var destPosition =
          LatLng(dest_LOCATION.latitude, dest_LOCATION.longitude);
      setState(() {
        _marker.add(Marker(
          infoWindow: InfoWindow(title: "That's You!"),
          markerId: MarkerId('sourcePin'),
          position: sourcePosition,
         // icon : sourceIcon
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));

        _marker.add(Marker(
          infoWindow: InfoWindow(title: "That's Your Friend"),
          markerId: MarkerId('destPin'),
          position: destPosition,
          icon: BitmapDescriptor.defaultMarker,
        ));
      });
      //print
      setPolyLines();
      updateCameraLocation(
          LatLng(currentLocation.latitude, currentLocation.longitude),
          LatLng(destLocation.latitude, destLocation.longitude),
          controller);
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();
    setState(() {
      isVisible = true;
    });
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  void createRoute(String encondedPoly) {
   setState(() {
     
   
    _polyLine.add(Polyline(
        polylineId: PolylineId("PolyId"),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
  });
  
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
     do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
       if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

     for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }
  setPolyLines() async {
   
  //  String route = await _googleMapsServices.getRouteCoordinates(
  //      LatLng(currentLocation.latitude, currentLocation.longitude), LatLng(destLocation.latitude, destLocation.longitude));
  //  createRoute(route);
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(currentLocation.latitude, currentLocation.longitude),
      PointLatLng(destLocation.latitude, destLocation.longitude),
     // optimizeWaypoints: true,
    //  travelMode: TravelMode.walking  
      travelMode: TravelMode.driving
    );

    print(result.status);
    if (result.points.isNotEmpty) {
      print("adding points");
      result.points.forEach((point) {
        snap_points.add(point.latitude.toString() + "," + point.longitude.toString());
   //     param = param + point.latitude.toString() + "," + point.longitude.toString() + "|";
     //   polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    String param = "";
    if(snap_points.length > 1){
    var routeSnap = chunk(snap_points, 100);
    print(routeSnap.length);
    for (var snaps in routeSnap){
      print(snaps.length);
      for (var points in snaps){
      //  print("Inner loop");
        param = param + points + "|";
        
      }
      var parm_new = param.substring(0,param.length-1);
        var url = "https://roads.googleapis.com/v1/snapToRoads?path=" + parm_new + "&interpolate=true&key=AIzaSyD1QQwpp3kGQlPLkYBdwXO59iDkQBwYoQ8";   
        var response = await http.get(url);
        //print(response.body);
        var jsonRoad = jsonDecode(response.body);
        for (var points in jsonRoad["snappedPoints"]){
        //  print(points["location"]["latitude"]);
          
          polylineCoordinates.add(LatLng(points["location"]["latitude"].toDouble(),points["location"]["longitude"].toDouble()));
        }
      param = "";
    }
    }
 
    print(polylineCoordinates.length);
    setState(() {
      _polyLine.add(Polyline(
          polylineId: PolylineId("Poly"),
          width: 5,
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates));
    });
  }

  setCamera(cPosition) async {
    CameraPosition cPosition = CameraPosition(
      zoom: cAMERA_ZOOM,
      tilt: 90,
      bearing: cAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    setState(() {});
  }

  updatePinOnMap() {
    CameraPosition cposition = CameraPosition(
      target: null,
    );
  }

  startNavigating() async{
  
  print(sourceIcon);
  setState(() {
    _marker.removeWhere(
      (m) => m.markerId.value == 'sourcePin');
      _marker.add(Marker(
         markerId: MarkerId('sourcePin'),
         position: LatLng(currentLocation.latitude, currentLocation.longitude), // updated position
         icon: sourceIcon
      ));

    _polyLine.removeWhere((element) => element.polylineId.value == "Poly");

     _polyLine.add(Polyline(
          polylineId: PolylineId("Poly"),
          width: 14,
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates));
    
});
    
    
    CameraPosition zoomCam = CameraPosition(
      bearing: 50,
      tilt: 70,
      zoom: 19,
      target: LatLng(currentLocation.latitude,currentLocation.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(zoomCam));

    location.onLocationChanged.listen((clocation) {
      currentLocation = clocation;

      // updatePinOnMap();
    });
  }

  List chunk(List list, int chunkSize) {
  List chunks = [];
  int len = list.length;
  for (var i = 0; i < len; i += chunkSize) {
    int size = i+chunkSize;
    chunks.add(list.sublist(i, size > len ? len : size));
  }
  return chunks;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: AppBar(
      //     title: Text("Map"),
      //    ),
      body: currentLocation != null
          ? GoogleMap(
              
              //   trafficEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: true,
              tiltGesturesEnabled: false,
              initialCameraPosition: CameraPosition(
                zoom: cAMERA_ZOOM,
                tilt: cAMERA_TILT,
                bearing: cAMERA_BEARING,
                target: currentLocation != null
                    ? LatLng(
                        currentLocation.latitude, currentLocation.longitude)
                    : sOURCE_LOCATION,
              ),
              markers: _marker,
              polylines: _polyLine,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                showPins(controller);
                
              })
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Visibility(
        visible: isVisible,
        child: FloatingActionButton.extended(
          elevation: 8,
          backgroundColor: Colors.tealAccent.shade700,
          splashColor: Colors.white70,
          //    hoverElevation: 10000.0,
          //    hoverColor: Colors.black,
          onPressed: () {
            startNavigating();
          },
          // shape: ,
          label: Text(
            "Directions",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class GoogleMapsServices{

  String googleApiKey = "AIzaSyD1QQwpp3kGQlPLkYBdwXO59iDkQBwYoQ8";
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2)async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$googleApiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }
}