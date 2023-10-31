import 'dart:async';
import 'dart:convert';

import 'package:ble_test/widget/descriptor_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CharacteristicItem extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorItem> descriptorTiles;

  const CharacteristicItem(
      {Key? key, required this.characteristic, required this.descriptorTiles})
      : super(key: key);

  @override
  State<CharacteristicItem> createState() => _CharacteristicItemState();
}

class _CharacteristicItemState extends State<CharacteristicItem> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  Future onReadPressed() async {
    try {
      await c.read();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future onWritePressed(List<int> data) async {
    try {
      await c.write(data, withoutResponse: c.properties.writeWithoutResponse);

      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      debugPrint(op.toString());
      if (c.properties.read) {
        await c.read();
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.toString().toUpperCase()}';
    return Text(uuid, style: const TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    String data = _value.toString();
    return Text(data, style: const TextStyle(fontSize: 13, color: Colors.grey));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: const Text("Read"),
        onPressed: () async {
          await onReadPressed();
          setState(() {});
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"),
        onPressed: () async {
          await onWritePressed(utf8.encode(tController.value.text));
          setState(() {});
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          setState(() {});
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  final tController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'),
            buildUuid(context),
            buildValue(context),
            SizedBox(
              height: 50,
              child: TextField(
                controller: tController,
                decoration: const InputDecoration.collapsed(
                    hintText: "Masukan Pesan", border: OutlineInputBorder()),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await c.write(utf8.encode(tController.value.text));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Message sent")));
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text(
                "Send",
              ),
            ),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: widget.descriptorTiles,
    );
  }
}
