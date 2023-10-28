import 'dart:async';

import 'package:ble_test/widget/charactheristic_item.dart';
import 'package:ble_test/widget/descriptor_item.dart';
import 'package:ble_test/widget/service_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DetailDeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  const DetailDeviceScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DetailDeviceScreen> createState() => _DetailDeviceScreenState();
}

class _DetailDeviceScreenState extends State<DetailDeviceScreen> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  List<BluetoothService> _services = [];
  final tController = TextEditingController();
  final bool _isConnectingOrDisconnecting = false;
  int? _rssi;
  @override
  void initState() {
    super.initState();
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;

      widget.device.discoverServices().then((value) {
        _services = value;
        setState(() {});
      });

      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connect();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnect();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget buildLoading(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildConnectOrDisconnectButton(BuildContext context) {
    return TextButton(
      onPressed: isConnected ? onDisconnectPressed : onConnectPressed,
      child: Text(
        isConnected ? "DISCONNECT" : "CONNECT",
        style: Theme.of(context)
            .primaryTextTheme
            .labelLarge
            ?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget buildConnectButton(BuildContext context) {
    if (_isConnectingOrDisconnecting) {
      return buildLoading(context);
    } else {
      return buildConnectOrDisconnectButton(context);
    }
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceItem(
            service: s,
            characteristicTiles: s.characteristics.where((element) => element.properties.write)
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicItem _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicItem(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorItem(descriptor: d)).toList(),
    );
  }

  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
            style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  void onSendMessage() {
    final message = tController.text;
    if (message.isNotEmpty) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName),
        actions: [buildConnectButton(context)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: buildRssiTile(context),
              title:
                  Text('Device is ${_connectionState.toString().split('.')[1]}.'),
            ),
            
             ..._buildServiceTiles(context, widget.device),
          ],
        ),
      ),
    );
  }
}
