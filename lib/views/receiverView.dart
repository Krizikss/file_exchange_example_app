import 'package:flutter/material.dart';
import 'dart:async';
import 'package:qr_code_bootstrap_channel/qr_code_bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wifi_data_channel/wifi_data_channel.dart';

class ReceiverView extends StatefulWidget {
  const ReceiverView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReceiverViewState();
}

class _ReceiverViewState extends State<ReceiverView> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];

  final textController = TextEditingController();

  void _setBootstrapChannelType(BootstrapChannelType type) {
    setState(() {
      _bootstrapChannelType = type;
    });
  }

  void _toggleDataChannelType(DataChannelType type) {
    setState(() {
      if (_dataChannelTypes.contains(type)) {
        _dataChannelTypes.remove(type);
      } else {
        _dataChannelTypes.add(type);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    textController.addListener(_handleText);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _handleText() {
    debugPrint("*********** The string received : ${textController.text}");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: TextField(
              controller: textController,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: const Divider(),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select bootstrap channel:',
            ),
          ),
          ListTile(
            title: const Text('QR code'),
            onTap: () => _setBootstrapChannelType(BootstrapChannelType.qrCode),
            trailing: Checkbox(
                value: _bootstrapChannelType == BootstrapChannelType.qrCode,
                onChanged: (v) => _setBootstrapChannelType(BootstrapChannelType.qrCode)),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select data channels (at least one):',
            ),
          ),
          ListTile(
            title: const Text('Wi-Fi'),
            onTap: () => _toggleDataChannelType(DataChannelType.wifi),
            trailing: Checkbox(
                value: _dataChannelTypes.contains(DataChannelType.wifi),
                onChanged: (v) => _toggleDataChannelType(DataChannelType.wifi)
            ),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _canReceiveData() ? () => _startReceivingData(context) : null,
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

  bool _canReceiveData() {
    return textController.text.isEmpty && _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startReceivingData(BuildContext context) async {
    if (textController.text.isNotEmpty) {
      Fluttertoast.showToast(
          msg: "Select a destination directory before starting file reception."
      );
      return;
    }
    Fluttertoast.showToast(
        msg: "Starting data reception..."
    );
    BootstrapChannel bootstrapChannel = QrCodeBootstrapChannel(context);
    Receiver receiver = Receiver(bootstrapChannel);
    for (var type in _dataChannelTypes) {
      switch(type) {
        case DataChannelType.wifi:
          receiver.useChannel( WifiDataChannel("wifi_data_channel") );
          break;
      }
    }
    await receiver.receiveData(textController);
    Fluttertoast.showToast( msg: "File successfully received!" );
  }

}