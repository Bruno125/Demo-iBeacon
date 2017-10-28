package upc.edu.pe.beaconTransmitter;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.UUID;

public class MainActivity extends AppCompatActivity {

    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mBluetoothLeScanner;
    private AdvertiseData mAdvertiseData;
    private AdvertiseSettings mAdvertiseSettings;
    private BluetoothLeAdvertiser mBluetoothLeAdvertiser;
    private ScanFilter mScanFilter;
    private UUID setUuid;
    private ScanSettings mScanSettings;
    private TextView txtFound;
    private TextView txtUuid;
    private TextView txtMajor;
    private TextView txtMinor;
    private TextView txtAccuracy;
    private TextView txtDistance;
    private TextView txtRSSI;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setUuid = UUID.fromString("a83c331d-c004-4429-ace9-1a2241a6d12a");
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        mBluetoothLeScanner = mBluetoothAdapter.getBluetoothLeScanner();
        mBluetoothLeAdvertiser = mBluetoothAdapter.getBluetoothLeAdvertiser();


        setAdvertiseData();
        setAdvertiseSettings();
        mBluetoothLeAdvertiser.startAdvertising(mAdvertiseSettings, mAdvertiseData, mAdvertiseCallback);



        /*
        //For scanning
        setScanFilter();
        setScanSettings();
        mBluetoothLeScanner.startScan(Arrays.asList(mScanFilter), mScanSettings, mScanCallback);
        */



    }

    private void setScanFilter() {
        ScanFilter.Builder mBuilder = new ScanFilter.Builder();
        ByteBuffer mManufacturerData = ByteBuffer.allocate(23);
        ByteBuffer mManufacturerDataMask = ByteBuffer.allocate(24);
        byte[] uuid = asBytes(setUuid);
        mManufacturerData.put(0, (byte)0xBE);
        mManufacturerData.put(1, (byte)0xAC);
        for (int i=2; i<=17; i++) {
            mManufacturerData.put(i, uuid[i-2]);
        }
        for (int i=0; i<=17; i++) {
            mManufacturerDataMask.put((byte)0x01);
        }
        mBuilder.setManufacturerData(224, mManufacturerData.array(), mManufacturerDataMask.array());
        mScanFilter = mBuilder.build();
    }

    private void setScanSettings() {
        ScanSettings.Builder mBuilder = new ScanSettings.Builder();
        mBuilder.setReportDelay(0);
        mBuilder.setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY);
        mScanSettings = mBuilder.build();
    }


    protected ScanCallback mScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            Log.d("iBeacons","FOUND");

            ScanRecord mScanRecord = result.getScanRecord();
            byte[] manufacturerData = mScanRecord.getManufacturerSpecificData(224);
            int mRssi = result.getRssi();
            double accuracy = calculateDistance(manufacturerData[22],mRssi);
            String distance = getDistance(accuracy);

            byte[] rawUuid = Arrays.copyOfRange(manufacturerData,2,18);
            UUID uuid = asUuid(rawUuid);





            txtRSSI.setText(Integer.toString(mRssi));
            txtDistance.setText(distance);
            txtAccuracy.setText(Double.toString(accuracy));
            txtMajor.setText(Byte.toString(manufacturerData[19]));
            txtMinor.setText(Byte.toString(manufacturerData[21]));
            txtFound.setText("YES!");
            txtUuid.setText(uuid.toString());
        }
    };

    protected AdvertiseCallback mAdvertiseCallback = new AdvertiseCallback() {
        @Override
        public void onStartSuccess(AdvertiseSettings settingsInEffect) {
            Log.d("iBeacons","Advertising started");
        }

        @Override
        public void onStartFailure(int errorCode) {
            Log.d("iBeacons", "Advertising failed");
        }
    };

    private double calculateDistance(int txPower, double rssi) {
        if (rssi == 0) {
            return -1.0; // if we cannot determine accuracy, return -1.
        }
        double ratio = rssi*1.0/txPower;
        if (ratio < 1.0) {
            return Math.pow(ratio,10);
        }
        else {
            double accuracy =  (0.89976)*Math.pow(ratio,7.7095) + 0.111;
            return accuracy;
        }
    }

    private String getDistance(double accuracy) {
        if (accuracy == -1.0) {
            return "Unknown";
        } else if (accuracy < 1) {
            return "Immediate";
        } else if (accuracy < 3) {
            return "Near";
        } else {
            return "Far";
        }
    }

    private UUID asUuid(byte[] bytes) {
            ByteBuffer bb = ByteBuffer.wrap(bytes);
            long firstLong = bb.getLong();
            long secondLong = bb.getLong();
            return new UUID(firstLong, secondLong);
        }

    public static byte[] asBytes(UUID uuid) {
        ByteBuffer bb = ByteBuffer.wrap(new byte[16]);
        bb.putLong(uuid.getMostSignificantBits());
        bb.putLong(uuid.getLeastSignificantBits());
        return bb.array();
    }

    protected void setAdvertiseData() {
        AdvertiseData.Builder mBuilder = new AdvertiseData.Builder();
        ByteBuffer mManufacturerData = ByteBuffer.allocate(24);
        byte[] uuid = asBytes(setUuid);
        mManufacturerData.put(0, (byte)0xBE); // Beacon Identifier
        mManufacturerData.put(1, (byte)0xAC); // Beacon Identifier
        for (int i=2; i<=17; i++) {
            mManufacturerData.put(i, uuid[i-2]); // adding the UUID
        }
        mManufacturerData.put(18, (byte)0x00); // first byte of Major
        mManufacturerData.put(19, (byte)0x09); // second byte of Major
        mManufacturerData.put(20, (byte)0x00); // first minor
        mManufacturerData.put(21, (byte)0x06); // second minor
        mManufacturerData.put(22, (byte)0xB5); // txPower
        mBuilder.addManufacturerData(224, mManufacturerData.array()); // using google's company ID
        mAdvertiseData = mBuilder.build();
    }

    protected void setAdvertiseSettings() {
        AdvertiseSettings.Builder mBuilder = new AdvertiseSettings.Builder();
        mBuilder.setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY);
        mBuilder.setConnectable(false);
        mBuilder.setTimeout(0);
        mBuilder.setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM);
        mAdvertiseSettings = mBuilder.build();
    }
}
