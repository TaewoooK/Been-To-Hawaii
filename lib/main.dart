//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'dart:collection';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid Map Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Hawaii Covid Map Data'),
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

  GoogleMapController _mapController;

  String searchAddress;

  static double lat = 20.765865;
  static double lng = -156.311697;

  PermissionStatus status;
  static Set<Circle> _circles = HashSet<Circle>();

  void initState() {
    super.initState();
    addCircles();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(lat, lng),
    zoom: 7.0,
  );
  
  Future findSearchedLocation(String location) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(location);
    var first = addresses.first;
   
    lat = first.coordinates.latitude;
    lng = first.coordinates.longitude;
  }

  Future findLocation(String location, int i, int casesFixed) async {
    print('lskfa');
    var addresses = await Geocoder.local.findAddressesFromQuery(location);
    print("here");
    print(location);
    var first = addresses.first;
   
    lat = first.coordinates.latitude;
    lng = first.coordinates.longitude;

    print(lat);

    if (casesFixed < 1) {
        setCircles(i, lat, lng, 0, 0, 0, 0.1, 15000, casesFixed);
      } else if (casesFixed < 10) {
        setCircles(i, lat, lng, 255, 215, 0, 0.5, 20000, casesFixed);
      } else if (casesFixed < 52) {
        setCircles(i, lat, lng, 255, 100, 0, 0.5, 30000, casesFixed);
      } else {
        setCircles(i, lat, lng, 255, 50, 0, 0.5, 70000, casesFixed);
      }
  }

  void setCircles(int id, double lat, double lng, int r, int g, int b, double op, double rad, int cases_number) {
    _circles.add(
      Circle(
        circleId: CircleId(id.toString()),
        center: LatLng(lat, lng),
        radius: rad,
        strokeWidth: 1,
        consumeTapEvents: true,
        fillColor: Color.fromRGBO(r, g, b, op),
        onTap: (){
            _showMyDialog(cases_number, id);
            // createAlertDialog(context);
        }
      ),
    );
  }

  static SharedPreferences prefs;
  String places = "Recent: \n";

  Future<void> _showMyDialog(int caseNumber, int id) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Location ID: ' + id.toString()),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Cases: ' + caseNumber.toString()),
              Text('Have you been here?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Yes'),
            onPressed: () async{
              Navigator.of(context).pop();
              // save value locally
              
              // places = prefs.getString('Places');
              setState(() {
               places = places + "ID: " + id.toString() + "\n";
              });
             // prefs.setString('Places', places);
            },
           ),
           TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
           ),
         ],
        );
      },
   );
  }


  //---------------Backup analog box----------------------
  createAlertDialog(BuildContext context){

  TextEditingController customController = TextEditingController();

  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Did you been to.."),
      content: TextField(
        controller: customController,
      ),
      actions: <Widget>[
        MaterialButton(
          elevation: 5.0,
          child: Text("Yes"),
          onPressed: (){

            Navigator.of(context).pop(customController.text.toString());
            
          },
        ),
                MaterialButton(
          elevation: 5.0,
          child: Text("No"),
          onPressed: (){
            Navigator.of(context).pop(customController.text.toString());
          },
        )
      ],
    );
  });
}
  //-------------------------------------------------
  
  Future addCircles() async {

    List<String> county = [
      "Hawaii County, HI", 
      "Honolulu County, HI", 
      "Kalawao County, HI", 
      "Kauai County, HI", 
      "Maui County, HI"
      ];

    List<int> casesFixed = [59,51,0,0,3];

    // prefs = await SharedPreferences.getInstance();
    // prefs.setString('Places', "Recent: \n");

    for (int i = 0; i < 5; i++) {
      // print(casesFixed[i]);
      findLocation(county[i], i, casesFixed[i]);
      //print('' + lat.toString() + " " + lng.toString());
    }
  }
/*
/*function: Map state name with value;
  status: one state only map to one value
  Purpose: pull out cases for each state
*/
  void Map_state_value(){
//map
  Map<String, int> someMap = {};
//open up csv
    final File file = new File('out.csv');

  Stream<List> inputStream = file.openRead();

  inputStream
      .transform(utf8.decoder)       // Decode bytes to UTF-8.
      .transform(new LineSplitter()) // Convert stream to individual lines.
      .listen((String line) {        // Process results.

       List row = line.split(','); // split by comma

        String state = row[0];
        //String symbol = row[1];
        int cases = int.parse(row[2]);

        someMap[state]=cases;
        print(someMap);
      },
      onDone: () { print('File is now closed.'); },
      onError: (e) { print(e.toString()); });
    }
*/
  @override
  Widget build(BuildContext context) {


    return new Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Places you have been to\n' + places)
            ),
          ],
        ),
      ),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _controller.complete(controller);
              },
              circles: _circles,
              // myLocationEnabled: true,
            ),
            Positioned(
                top: 20.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Enter Address or Zip Code',
                          suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              iconSize: 30.0,
                              onPressed: () => {
                                    findSearchedLocation(searchAddress),
                                    _mapController.moveCamera(
                                        CameraUpdate.newLatLng(
                                            LatLng(lat, lng)))
                                  })),
                      onChanged: (val) => setState(() {
                            searchAddress = val;
                          })),
                ))
          ],
        ));
  }
}
