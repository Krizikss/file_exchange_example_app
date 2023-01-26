import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';

class SenderView extends StatefulWidget {
  const SenderView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {
  WifiInfoWrapper? _wifiObject;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _textController.addListener(_handleText);
  }

  Future<void> initPlatformState() async {
    WifiInfoWrapper? wifiObject;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      wifiObject = await  WifiInfoPlugin.wifiDetails;

    }
    on PlatformException{}
    if (!mounted) return;

    setState(() {

      _wifiObject= wifiObject;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  _handleText() {
    debugPrint("*********** The string to send : ${_textController.text}");
  }

  @override
  Widget build(BuildContext context) {
    String ipAddress = _wifiObject != null ? _wifiObject!.ipAddress.toString() : "...";
    debugPrint("*********** Sender IP : $ipAddress");
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
        ]
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _startSendingData,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
            )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Send file"),
        ),
      ),
    );
  }

  void _startSendingData() async {
    if(_textController.text.isNotEmpty) {
      debugPrint("*********** _startSendingData() : ${_textController.text}");
      final socket = await Socket.connect('192.168.1.81', 4567);
      debugPrint('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.write(_textController.text);
    }
    else{
      debugPrint("Text Empty");
    }
  }
}
