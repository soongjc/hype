import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:math';
import 'package:intl/intl.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  await remoteConfig.ensureInitialized();
  await remoteConfig.fetchAndActivate();
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(minutes: 1),
  ));
  return remoteConfig;
}

Future<void> _sendAnalyticsEvent() async {
  // await analytics.logEvent(
  //   name: 'test_event',
  //   parameters: <String, dynamic>{
  //     'string': 'string',
  //     'int': 42,
  //     'long': 12345678910,
  //     'double': 42.0,
  //     'bool': true,
  //   },
  // );
  await analytics.logBeginCheckout(
      value: 10.0,
      currency: 'USD',
      items: [
        AnalyticsEventItem(itemName: 'Socks', itemId: 'xjw73ndnw', price: 10.0),
      ],
      coupon: '10PERCENTOFF');
  print('logEvent succeeded');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _title = 'Hello HyPe';
  late FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();
    setupRemoteConfig();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Notification"),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    setState(() =>
                        _title = remoteConfig.getString('welcome_message'));
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

  String rand_num =
      NumberFormat("#,##0.00", "en_US").format(Random().nextInt(1000000) / 100);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12, top: 12),
              child: Text('Logout',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.black)))
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.dstATop),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 24, top: 16),
                child: Text("CURRENT & \nSAVINGS",
                    style: GoogleFonts.nunito(fontSize: 24))),
            Padding(
                padding: EdgeInsets.only(left: 24, top: 30),
                child: Text("TOTAL EQUIVALENT BALANCE (MYR)",
                    style: GoogleFonts.nunito(fontSize: 10))),
            Padding(
                padding: EdgeInsets.only(left: 24, top: 8),
                child: Text(rand_num,
                    style: GoogleFonts.nunito(
                        fontSize: 20, fontWeight: FontWeight.w700))),
            Padding(
                padding: EdgeInsets.only(left: 24, top: 20),
                child:
                    Text("QUICK PAY", style: GoogleFonts.nunito(fontSize: 10))),
            SizedBox(
                height: 100,
                child: Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, bottom: 8),
                    child: Row(children: <Widget>[
                      Expanded(
                          child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsets.all(8),
                              child: Card(
                                  elevation: 10,
                                  child: Container(
                                    color: Colors.grey.shade300,
                                    width: 80.0,
                                    child: Column(children: <Widget>[
                                      SizedBox(height: 5),
                                      CircleAvatar(
                                        backgroundColor: Colors.grey.shade400,
                                        child: const Text('M'),
                                      ),
                                      SizedBox(height: 5),
                                      Text('Mother')
                                    ]),
                                    alignment: Alignment.center,
                                  )));
                        },
                        scrollDirection: Axis.horizontal,
                      )),
                      Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(Icons.arrow_forward_ios))
                    ]))),
            Padding(
                padding: EdgeInsets.all(6),
                child: Card(
                  child: ListTile(
                    title: Row(children: <Widget>[
                      Text("MYR ",
                          style: GoogleFonts.roboto(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(rand_num,
                          style: GoogleFonts.nunito(
                              fontSize: 18, fontWeight: FontWeight.w700))
                    ]),
                    subtitle: Text("HONG LEONG STAFF SA \n******8392",
                        style: GoogleFonts.nunito(fontSize: 10)),
                    trailing: Icon(Icons.arrow_forward_ios),
                    isThreeLine: true,
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(2),
                child: Card(
                    elevation: 1,
                    color: Color(0xffc0c0c0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            "Note: Protected by PIDM up to MYR 250,000 for each depositor. Click for more details",
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)))))
          ],
        ),
        // title: Text(_title),
      ),
      bottomNavigationBar: BottomAppBar(
          elevation: 1,
          notchMargin: 5,
          clipBehavior: Clip.antiAlias,
          color: const Color(0xffd3d3d3),
          shape: const AutomaticNotchedShape(
              RoundedRectangleBorder(),
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)))),
          child: BottomNavigationBar(
            elevation: 0.5,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Apply',
              ),
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onPressed: () {
            _sendAnalyticsEvent();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.menu),
              Text("MENU",
                  style: GoogleFonts.nunito(fontSize: 9, color: Colors.white)),
            ],
          )),
    );
  }
}
