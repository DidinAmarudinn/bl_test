package com.example.ble_test

import android.bluetooth.BluetoothDevice
import android.content.IntentFilter
import android.content.IntentFilter.SYSTEM_HIGH_PRIORITY
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity


class MainActivity: FlutterActivity() {
    private var bluetoothPairingReceiver: BluetoothPairingReceiver = BluetoothPairingReceiver()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var filter = IntentFilter(BluetoothDevice.ACTION_PAIRING_REQUEST)
        filter.priority = IntentFilter.SYSTEM_HIGH_PRIORITY
        registerReceiver(bluetoothPairingReceiver, filter)
    }
}
