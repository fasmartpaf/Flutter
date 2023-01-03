import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_place/google_place.dart';
import 'package:rentors/config/app_config.dart' as config;
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';
typedef Modelcallback = ModelAddress Function(ModelAddress);
class MapScreen extends StatefulWidget {
  Modelcallback callback;
  @override
  State<MapScreen> createState() => _MapScreenState();
  MapScreen({this.callback});
}
class ModelAddress{
  String _address;
  LatLng _latLng;

  LatLng get latLng => _latLng;
  String get address => _address;

  set latLng(LatLng value) {
    _latLng = value;
  }
  set address(String value) {
    _address = value;
  }
}

class MapSampleState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  bool showProgress = false;
  Address addresses;
  final searchOnChange = new BehaviorSubject<String>();
  AutocompleteResponse risult;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng latLng=LatLng(22.5582, 75.252655);
  @override
  void initState() {
    super.initState();
    var googlePlace = GooglePlace("AIzaSyDzT0oICRA3ImAPw8CwoUi0TncNZA_2Gdg");
    searchOnChange.debounceTime(Duration(milliseconds: 500))
        .listen((queryString) async {
       risult = await googlePlace.autocomplete.get(queryString);
       setState(() {
       });
    });
  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:  Stack(
            children: [Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    zoom: 18,
                    target: latLng
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  onLongPress: (latlang) {
                    _addMarkerLongPressed(latlang); //we will call this function when pressed on the map
                  },
                  markers: Set<Marker>.of(markers.values), //all markers are here
                )
            ),
              Column(
                children: [
                  risult!=null?
                  Expanded(child: ListView.builder(
                    primary: false,
                    itemCount: risult.predictions.length,
                    itemBuilder: (context, index) {
                      return Container(
                          color: config.Colors().white,
                          child: ListTile(
                            leading:Icon(Icons.location_history,color: config.Colors().mainDarkColor,),
                            title: Text(risult.predictions[index].description,style: TextStyle(
                                color: config.Colors().secondColor
                            )),
                            onTap: (){
                              locationAddress(risult.predictions[index].description);
                            },
                          )
                      );
                    },)):
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: config.Colors().mainDarkColor),
                        color: config.Colors().mainDarkColor
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    child: Text(addresses==null?'No Result Found':addresses.addressLine,style: TextStyle(
                        color: config.Colors().white
                    ),),
                  ),
                 /* InkWell(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: config.Colors().mainDarkColor,
                      ),
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.all(10),
                      child: Text('Select Current Location',style: TextStyle(
                          fontSize: 18,
                          color: config.Colors().white
                      ),),
                    ),
                    onTap: (){
                      if(latLng!=null) {
                        if(widget.callback!=null){
                          ModelAddress event=new ModelAddress();
                          event.latLng=latLng;
                          event.address=addresses.addressLine;
                          widget.callback(event);
                          Navigator.pop(context);
                        }else{
                          Navigator.of(context).pushNamed('/nearby_page', arguments:latLng);
                        }
                      }else{

                      }
                    },
                  ),*/
                ],
              ),]
        ),
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
              border: Border.all(color: config.Colors().mainDarkColor),
              borderRadius: BorderRadius.circular(20)
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(child: TextField(
                  onChanged: (text) {
                    searchOnChange.add(text);
                  },
                  autofocus: true,
                  style: TextStyle(color: config.Colors().white, fontSize: 16),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Search address',
                      hintStyle: TextStyle(color: config.Colors().white))),flex: 1,)
            ],
          ),
        ),
      ),
    );
  }
  Future _addMarkerLongPressed(LatLng latlang) async {
    setState(() {
      final MarkerId markerId = MarkerId("RANDOM_ID");
      Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position: latlang, //With this parameter you automatically obtain latitude and longitude
        infoWindow: InfoWindow(
          title: "Marker here",
          snippet: 'This looks good',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers[markerId] = marker;
    });

    //This is optional, it will zoom when the marker has been created
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latlang, 17.0));
  }
  locationAddress(String s) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(s);
    var first = addresses.first;
    double latitude=first.coordinates.latitude;
    double longitude=first.coordinates.longitude;
    latLng=new LatLng(latitude, longitude);
    if(widget.callback!=null){
      ModelAddress event=new ModelAddress();
      event.latLng=latLng;
      event.address=first.addressLine;
      widget.callback(event);
      Navigator.pop(context);
    }else{
      Navigator.of(context).pushNamed('/nearby_page', arguments:latLng);
    }
  }

}
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
class _MapScreenState extends State<MapScreen> {
  Address addresses;
  LatLng _latLng=LatLng(22.5255, 75.5682);
  Set<Marker> _markers = Set.of([]);
  GoogleMapController _mapController;
  CameraPosition _cameraPosition;
  bool isLoading=false;
  @override
  void initState() {
    super.initState();
    _determinePosition().then((value) async{
      _latLng=new LatLng(value.latitude, value.longitude);
      setState(() {
        _setMarker();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _latLng, zoom: 12),
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              indoorViewEnabled: true,
              markers:_markers,
              onMapCreated: (controller) => _mapController = controller,
              onCameraMove: (pos){
                setState(() {
                  _cameraPosition=pos;
                });
              },
              onCameraIdle: () {
                _updatePosition(_cameraPosition.target.latitude,_cameraPosition.target.longitude);
              },
            ),
            Positioned(
              left: 10, right: 10, bottom: 10,
              child: InkWell(
                onTap: () {
                  if(_mapController != null) {
                    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 12)));
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[300], spreadRadius: 3, blurRadius: 10)],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child:
                      Text(addresses!=null?"${addresses.addressLine}":"Address"),flex: 1,),
                      isLoading?
                      CircularProgressIndicator():
                          Container(
                            height: 40,width: 40,
                            child: IconButton(onPressed:(){
                              if(widget.callback!=null){
                                ModelAddress event=new ModelAddress();
                                event.latLng=_latLng;
                                event.address=addresses.addressLine;
                                widget.callback(event);
                                Navigator.pop(context);
                              }else{
                                Navigator.of(context).pushNamed('/nearby_page', arguments:_latLng);
                              }
                            }, icon: Icon(Icons.done_rounded,color: config.Colors().white,)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: config.Colors().mainDarkColor
                            ),
                          )
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Image.asset("assets/img/pick_marker.png",height: 40,),
            ),
            Positioned(child: Container(
              child: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
                Navigator.pop(context);
              },),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    blurRadius: 5,
                    spreadRadius: 2
                  )
                ]
              ),
            ),top: 40, left: 10,)
          ]),
        ),
    );
  }

  void _setMarker() async {
    Uint8List destinationImageData = await convertAssetToUnit8List(
     "assets/img/location_marker.png", width: 120,
    );

    _markers = Set.of([]);
    _markers.add(Marker(
      markerId: MarkerId('marker'),
      position: _latLng,
      icon: BitmapDescriptor.fromBytes(destinationImageData),
    ));
    _updatePosition(_latLng.latitude,_latLng.longitude);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 12)));
    setState(() {});
  }
  void _updatePosition(lat,lon)async {
    setState(() {
      isLoading=true;
    });
    var add = await Geocoder.local.findAddressesFromCoordinates(Coordinates(lat, lon));
    setState(() {
      _latLng=LatLng(lat, lon);
      isLoading=false;
      addresses=add.first;
    });
  }
  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
  }

}
