import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  late IO.Socket _socket;
  ServerStatus _serverStatus = ServerStatus.connecting;

  // getters
  ServerStatus get serverStatus => _serverStatus;

  // socket actions
  IO.Socket get socket => _socket;

  // constructor
  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    _socket = IO.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // client actions
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.on('nuevo-mensaje', (data) {
      print('nuevo mensage');
      print(data ?? {});
    });
  }
}
