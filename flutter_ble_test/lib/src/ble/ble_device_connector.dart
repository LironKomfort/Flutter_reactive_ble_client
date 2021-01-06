import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_test/src/ble/reactive_state.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnector(this._ble);

  final FlutterReactiveBle _ble;

  final Uuid serviceId = Uuid.parse('06391ebb-4050-42b6-ab55-8282a15fa094');
  final Uuid descriptorId = Uuid.parse('7385e060-b9a8-4853-848d-c70178b0e01e');
  final Uuid readCharacteristicId =
      Uuid.parse('010d815c-031c-4de8-ac10-1ffebcf874fa');
  final Uuid writeCharacteristicId =
      Uuid.parse('f2926f0f-336a-4502-9948-e4e8fd2316e9');

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    if (_connection != null) {
      await _connection.cancel();
    }

    _connection = _ble
        .connectToDevice(
          id: deviceId,
          servicesWithCharacteristicsToDiscover: {
            serviceId: [readCharacteristicId, writeCharacteristicId]
          },
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          _deviceConnectionController.add,
        );
  }

  Future<void> connectToAdvertisingDevice(String deviceId) async {
    if (_connection != null) {
      await _connection.cancel();
    }

    _connection = _ble
        .connectToAdvertisingDevice(
          id: deviceId,
          withServices: [serviceId],
          prescanDuration: const Duration(seconds: 5),
          servicesWithCharacteristicsToDiscover: {
            serviceId: [readCharacteristicId, writeCharacteristicId]
          },
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          _deviceConnectionController.add,
        );
  }

  Future<void> disconnect(String deviceId) async {
    if (_connection != null) {
      try {
        await _connection.cancel();
      } on Exception catch (e, _) {
        print("Error disconnecting from a device: $e");
      } finally {
        // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
        _deviceConnectionController.add(
          ConnectionStateUpdate(
            deviceId: deviceId,
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        );
      }
    }
  }

  Future<void> clearGattCache(String deviceId) async {
    await _ble.clearGattCache(deviceId);
  }

  Future<void> discoverServices(String deviceId) async {
    await _ble.discoverServices(deviceId).then(
          printServices,
        );
  }

  void printServices(List<DiscoveredService> list) {
    print('Print discovered services');
    for (final service in list) {
      print('Discovered service id = ${service.serviceId}');
      for (final id in service.characteristicIds) {
        print('Characteristic id = ${id.toString()}');
      }
    }
  }

  Future<void> requestMTU(String deviceId) async {
    await _ble.requestMtu(deviceId: deviceId, mtu: 512).then(
          (value) => print('MTU changed. MTU=$value'),
        );
  }

  Future<void> readCharacteristic(String deviceId) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: readCharacteristicId,
        deviceId: deviceId);
    await _ble.readCharacteristic(characteristic).then(
          printCharacteristic,
        );
  }

  void characteristicValueStream() {
    _ble.characteristicValueStream.listen((event) {
      print('characteristicValueStream $event.result');
    });
  }

  void subscribeCharacteristic(String deviceId) {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: readCharacteristicId,
        deviceId: deviceId);

    _ble.subscribeToCharacteristic(characteristic).listen((data) {
      // code to handle incoming data
      print('Data received $data');
    }, onError: (dynamic error) {
      // code to handle errors
      print('Subscribe error $error');
    });
  }

  void printNotificationCB(List<int> list) {
    print('printNotificationCB');
    if (list.isNotEmpty) {
      print(
          'printNotificationCB. ReadCharacteristic: ${list.elementAt(0)} packet '
          '${list.elementAt(1)}/${list.elementAt(2)} length=${list.length}');
    } else {
      print('printNotificationCB. ReadCharacteristic. data size = 0');
    }
  }

  void printCharacteristic(List<int> list) {
    if (list.isNotEmpty) {
      print('ReadCharacteristic CB: ${list.elementAt(0)} packet '
          '${list.elementAt(1)}/${list.elementAt(2)} length=${list.length}');
    } else {
      print('ReadCharacteristic CB. data size = 0');
    }
  }

  Future<void> writeCharacteristic(String deviceId) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: writeCharacteristicId,
        deviceId: deviceId);
    await _ble.writeCharacteristicWithResponse(characteristic, value: [8]).then(
      (value) => print('writeCharacteristic CB'),
    );
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
