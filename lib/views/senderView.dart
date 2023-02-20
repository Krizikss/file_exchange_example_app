
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/scheduler_implementation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_bootstrap_channel/qr_code_bootstrap_channel.dart';
import 'package:wifi_data_channel/wifi_data_channel.dart';

class SenderView extends StatefulWidget {
  const SenderView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];
  final _textController = TextEditingController();

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
        _checkAssociatedPermissions(type);
      }
    });
  }

  void _checkAssociatedPermissions(DataChannelType type) async {
    switch(type) {
      case DataChannelType.wifi:
        await Permission.locationWhenInUse.request();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleText);
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
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            child: TextField(
              controller: _textController,
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
        ]
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _canSendData() ? () => _startSendingData(context) : null,
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

  bool _canSendData() {
    return _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startSendingData(BuildContext context) async {
    if(_textController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Type a String before starting the sending."
      );
      return;
    }
    BootstrapChannel bootstrapChannel = QrCodeBootstrapChannel(context);
    Scheduler scheduler = SchedulerImplementation(bootstrapChannel);
    for (var type in _dataChannelTypes) {
      switch(type) {
        case DataChannelType.wifi:
          scheduler.useChannel( WifiDataChannel("wifi_data_channel") );
          break;
      }
    }
    //Adapt the chunksize to the size of the String
    await scheduler.sendData(_textController.text, 1);
    Fluttertoast.showToast( msg: "File successfully sent!" );
  }

}
