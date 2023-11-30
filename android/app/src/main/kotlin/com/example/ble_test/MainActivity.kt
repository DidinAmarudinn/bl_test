package com.example.ble_test

import android.bluetooth.BluetoothDevice
import android.content.IntentFilter
import android.content.IntentFilter.SYSTEM_HIGH_PRIORITY
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private var bluetoothPairingReceiver: BluetoothPairingReceiver = BluetoothPairingReceiver()
    private val chanelName = "ble"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        var chanel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, chanelName)

        chanel.setMethodCallHandler { call, result ->
            if (call.method == "registerBroadcastReciver") {
                var filter = IntentFilter(BluetoothDevice.ACTION_PAIRING_REQUEST)
                filter.priority = IntentFilter.SYSTEM_HIGH_PRIORITY
                registerReceiver(bluetoothPairingReceiver, filter)
                Toast.makeText(this, "Broadcast registerd", Toast.LENGTH_LONG).show()
            }
        }
    }
}
