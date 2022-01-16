import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status page'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Server status : ${socketService.serverStatus}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          socketService.socket.emit('emitir-mensaje', {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'});
        },
      ),
    );
  }
}
