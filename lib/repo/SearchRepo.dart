import 'package:rentors/event/SearchEvent.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rentors/model/SearchModel.dart';
import 'package:rentors/repo/FreshDio.dart' as dio;
import '../util/Utils.dart';

Future<SearchModel> searchResult(String query,{SearchEvent event,LatLng currentLocation}) async {
  var model = await Utils.getUser();
  var map = Map();
  map['user_id'] = model.data.id;
  map["value"] = query;
  map["category"]=event.category;
  map["sub_category"]=event.sub_category;
  map["city"]=event.city;
  map["price_start"]=event.price_start;
  map["price_end"]=event.price_end;
  map["distance_start"]=event.distance_start;
  map["distance_end"]=event.distance_end;
  map["lat"] = event.location.latitude;
  map["lng"] = event.location.longitude;
  if(currentLocation!=null) {
    map["lat"] = currentLocation.latitude;
    map["lng"] = currentLocation.longitude;
  }
  print(map);
  var response = await dio.httpClient().post("product/search", data: map);
  return SearchModel.fromJson(response.data);
}
Future<SearchModel> nearBySearchResult(LatLng query) async {
  var model = await Utils.getUser();
  var map = Map();
  map['user_id'] = model.data.id;
  map["lat"] = '${query.latitude}';
  map["lng"] = '${query.longitude}';
  var response = await dio.httpClient().post("product/nearbysearch", data: map);
  return SearchModel.fromJson(response.data);
}