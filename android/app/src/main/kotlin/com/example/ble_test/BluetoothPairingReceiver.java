package com.example.ble_test;

import android.Manifest;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.core.app.ActivityCompat;

public class BluetoothPairingReceiver extends BroadcastReceiver {
    private static final String TAG = "BluetoothPairReceiver";
    // hardoced pin most of bluetooth device using 1234 as PIN
    private static final String BLE_PIN = "1234";

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (BluetoothDevice.ACTION_PAIRING_REQUEST.equals(action)) {
            BluetoothDevice bluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                return;
            }
            bluetoothDevice.setPin(BLE_PIN.getBytes());
            abortBroadcast();
            Log.e(TAG, "Auto-entering pin: " + BLE_PIN);
            bluetoothDevice.createBond();
            Log.e(TAG, "Pin entered, and request sent...");
        }
    }
}
