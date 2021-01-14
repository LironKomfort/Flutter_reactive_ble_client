import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_test/src/ble/ble_device_connector.dart';
import 'package:provider/provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({@required this.device}) : assert(device != null);

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleDeviceConnector, ConnectionStateUpdate>(
        builder: (_, deviceConnector, connectionStateUpdate, __) =>
            _DeviceDetail(
          device: device,
          connectionUpdate: connectionStateUpdate != null &&
                  connectionStateUpdate.deviceId == device.id
              ? connectionStateUpdate
              : ConnectionStateUpdate(
                  deviceId: device.id,
                  connectionState: DeviceConnectionState.disconnected,
                  failure: null,
                ),
          connect: deviceConnector.connectToAdvertisingDevice,
          disconnect: deviceConnector.disconnect,
          clearGattCache: deviceConnector.clearGattCache,
          discoverServices: deviceConnector.discoverServices,
          requestMTU: deviceConnector.requestMTU,
          subscribeCharacteristic: deviceConnector.subscribeCharacteristic,
          subscribeCharacteristic2: deviceConnector.subscribeCharacteristic2,
          readCharacteristic: deviceConnector.readCharacteristic,
          writeCharacteristic: deviceConnector.writeCharacteristic,
        ),
      );
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    @required this.device,
    @required this.connectionUpdate,
    @required this.connect,
    @required this.disconnect,
    @required this.clearGattCache,
    @required this.discoverServices,
    @required this.requestMTU,
    @required this.subscribeCharacteristic,
    @required this.subscribeCharacteristic2,
    @required this.readCharacteristic,
    @required this.writeCharacteristic,
    Key key,
  })  : assert(device != null),
        assert(connectionUpdate != null),
        assert(connect != null),
        assert(disconnect != null),
        assert(clearGattCache != null),
        assert(discoverServices != null),
        assert(requestMTU != null),
        assert(subscribeCharacteristic != null),
        assert(subscribeCharacteristic2 != null),
        assert(readCharacteristic != null),
        assert(writeCharacteristic != null),
        super(key: key);

  final DiscoveredDevice device;
  final ConnectionStateUpdate connectionUpdate;
  final void Function(String deviceId) connect;
  final void Function(String deviceId) disconnect;
  final void Function(String deviceId) clearGattCache;
  final void Function(String deviceId) discoverServices;
  final void Function(String deviceId) requestMTU;
  final void Function(String deviceId) subscribeCharacteristic;
  final void Function(String deviceId) subscribeCharacteristic2;
  final void Function(String deviceId) readCharacteristic;
  final void Function(String deviceId) writeCharacteristic;

  bool _deviceConnected() =>
      connectionUpdate.connectionState == DeviceConnectionState.connected;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          disconnect(device.id);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(device.name ?? "unknown"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "ID: ${connectionUpdate.deviceId}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Status: ${connectionUpdate.connectionState}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: !_deviceConnected()
                            ? () => connect(device.id)
                            : null,
                        child: const Text("Connect"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => disconnect(device.id)
                            : null,
                        child: const Text("Disconnect"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => clearGattCache(device.id)
                            : null,
                        child: const Text("Clear"),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => requestMTU(device.id)
                            : null,
                        child: const Text("Request MTU"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => discoverServices(device.id)
                            : null,
                        child: const Text("Discover Services"),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => readCharacteristic(device.id)
                            : null,
                        child: const Text("Read Characteristic"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => writeCharacteristic(device.id)
                            : null,
                        child: const Text("Write Characteristic"),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => subscribeCharacteristic(device.id)
                            : null,
                        child: const Text("Subscribe Notification"),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => subscribeCharacteristic2(device.id)
                            : null,
                        child: const Text("Subscribe Notification 2"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
