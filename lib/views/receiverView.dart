import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';

class ReceiverView extends StatefulWidget {
  const ReceiverView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReceiverViewState();
}

class _ReceiverViewState extends State<ReceiverView> {
  WifiInfoWrapper? _wifiObject;
  String? _ipAddress;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _textController.addListener(_handleText);
  }

  Future<void> initPlatformState() async {
    WifiInfoWrapper? wifiObject = WifiInfoWrapper();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      wifiObject = await  WifiInfoPlugin.wifiDetails;

    }
    on PlatformException{}
    if (!mounted) return;

    setState(() {

      _wifiObject = wifiObject;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  _handleText() {
    debugPrint("*********** The string received : ${_textController.text}");
  }


  @override
  Widget build(BuildContext context) {
    _ipAddress = _wifiObject != null ? _wifiObject!.ipAddress.toString() : "...";
    debugPrint("*********** Receiver IP : $_ipAddress");
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: TextField(
              controller: _textController,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: const Divider(),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _startReceivingData,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
            )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Receive file"),
        ),
      ),
    );
  }


  void _startReceivingData() async {
    debugPrint("*********** _startReceivingData()");
    final server = await ServerSocket.bind(_ipAddress, 4567);
    server.listen((client) {
      handleClient(client);
    });
  }

  void handleClient(Socket client) async{
    debugPrint('Connection from ${client.remoteAddress.address}:${client.remotePort}');
    client.listen((Uint8List data) async {
      await Future.delayed(const Duration(seconds: 1));
      final request = String.fromCharCodes(data);
      if (request.isNotEmpty) {
        _textController.text = request;
      }
      else{
        debugPrint("*********** data empty");
      }
      client.close();
    });
  }


}