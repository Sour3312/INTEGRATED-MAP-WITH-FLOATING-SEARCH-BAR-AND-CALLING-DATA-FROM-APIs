// +=+=+=+=+=+=+=+=+=+=+ INTEGRATED MAP WITH FLOATING SEARCH BAR AND CALLING DATA FROM APIs +=+=+=+=+=+=+=+=+=+=+=+=

// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, unused_field, prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // ========== global variables =============
  var userInput,
      AT,
      request,
      myToken,
      sorted,
      acc_tok,
      SortedData,
      ApiData,
      setOnTextfield,
      DataLength;

// ============= 1st Function for token generation =============================
  getToken() async {
    print("getToken() called");
    request = https.Request(
        'POST',
        Uri.parse(
            'https://outpost.mapmyindia.com/api/security/oauth/token?grant_type=client_credentials&client_id=33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==&client_secret=lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww'));
    https.StreamedResponse response = await request.send();

    //CHECKING STATUS OF RETRIVED DATA
    if (response.statusCode == 200) {
      var statusOfRespnse = response.reasonPhrase;
      print("Your current status is : $statusOfRespnse");

      AT = await response.stream.bytesToString();
      myToken = json.decode(AT);
      print(myToken);

      //sorted acess token from mytoken
      acc_tok = myToken["access_token"];
      print("Your access token is: ${acc_tok}");
    } else {
      print(response.reasonPhrase);
    }
    setState(() {
      getApi(userInput); //calling 2nd function
    });
  }

//==============2nd  Function for calling API===================================
  getApi(value) async {
    final respon = await https.get(
        Uri.parse(
            // 'https://atlas.mappls.com/api/places/search/json?query=ranchi }'), //static
            'https://atlas.mappls.com/api/places/search/json?query=${{
          userInput
        }}}'), //dynamic
        headers: {
          'Access-Control-Allow-Origin': "*",
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
          'cors': '*',
          HttpHeaders.authorizationHeader: "bearer ${acc_tok}",
        });
    try {
      ApiData = await json.decode(respon.body); //actual data coming from API
      print(ApiData);
      DataLength = ApiData["suggestedLocations"].length; //length of coming data
      print("This is Apidata length: ${DataLength}");
      return ApiData;
    } catch (e) {
      print(e);
    }
  }

//==============3rd Function form Listtile(OnTap)===============================

  colorCng(selectedOp) {
    setState(() {
      setOnTextfield = selectedOp;
    });
    print(setOnTextfield);
  }

//==============Map integration starts here=====================================
  final Completer<MapmyIndiaMapController> _controller = Completer();

  final CameraPosition _MmiPlex = CameraPosition(
      target: LatLng(28.550844565376654, 77.26890518202649), zoom: 6);

  @override
  void initState() {
    // MapmyIndiaAccountManager.setMapSDKKey("30eb2d59-335d-452d-adb4-e51d77090b08"); //static way
    MapmyIndiaAccountManager.setMapSDKKey("${acc_tok}"); //dynamic way
    MapmyIndiaAccountManager.setRestAPIKey("47e0624fbd6e55e8dd13e4453f089aa7");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww");
    super.initState();
  }

//===============Main body starts here==========================================
  @override
  Widget build(BuildContext context) {
    FloatingSearchBarController _controller = FloatingSearchBarController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Integration with Sourabh"),
      ),
      body: Stack(children: [
        //1.-------------------MAp render--------------------
        MapmyIndiaMap(
            initialCameraPosition: _MmiPlex,
            myLocationRenderMode: MyLocationRenderMode.COMPASS,
            compassEnabled: true,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.NoneCompass,
            onMapCreated: (MapmyIndiaMapController controller) {
              // _controller.completer((controller));
              // }
            }),
        //2.-------------------Searchbar render--------------------
        FloatingSearchBar(
          controller: _controller,
          hint: 'Search here ex: Ranchi/Delhi...',

          //onchanged function fron input field
          onQueryChanged: (value) {
            userInput = value;
            setState(() {
              getToken();
            });
            print(userInput);
          },
          openAxisAlignment: 0.0,
          axisAlignment: 0.0,
          scrollPadding: EdgeInsets.only(top: 5, bottom: 0),
          elevation: 40.0,
          physics: BouncingScrollPhysics(),
          transitionCurve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 500),
          transition: CircularFloatingSearchBarTransition(),
          debounceDelay: Duration(milliseconds: 400),
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                icon: Icon(Icons.place),
                onPressed: () {
                  print('Places Pressed');
                  // Navigator.pop(context);
                },
              ),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          builder: (context, transition) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: Material(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Container(
                    height: 400.0,
                    color: Colors.white,
                    child: Expanded(
                      child: Column(
                        children: [
                          //creating suggestions here through listtile
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    tileColor: Colors.grey[200],
                                    // leading: Icon(Icons.location_on_outlined),
                                    trailing: Icon(Icons.location_on_outlined),
                                    title: Text(
                                      ApiData["suggestedLocations"][index]
                                          ["placeAddress"],
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      ApiData["suggestedLocations"][index]
                                          ["placeName"],
                                      style: TextStyle(color: Colors.blue[300]),
                                    ),
                                    onTap: () {
                                      colorCng(ApiData["suggestedLocations"]
                                          [index]["placeAddress"]);
                                    },
                                    hoverColor: Colors.pinkAccent,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}
