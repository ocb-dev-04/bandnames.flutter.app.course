import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', handleActivesBands);
    super.initState();
  }

  void handleActivesBands(dynamic data) {
    bands = (data as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Band Names",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketProvider.serverStatus == ServerStatus.online
                ? const Icon(Icons.online_prediction, color: Colors.blue)
                : const Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bands.isEmpty
                ? const SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ShowCharts(list: bands),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => BandListTile(band: bands[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addBand,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addBand() async {
    if (Platform.isAndroid) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New band name'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              onPressed: addBandToList,
              elevation: 5,
              textColor: Colors.blue,
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } else {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Add'),
              isDefaultAction: true,
              onPressed: addBandToList,
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  void addBandToList() {
    final value = textController.text;
    if (value.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    textController.clear();
    Navigator.of(context).pop();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.emit('add-band', {'name': value});
  }
}

class BandListTile extends StatelessWidget {
  const BandListTile({
    Key? key,
    required this.band,
  }) : super(key: key);

  final Band band;

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketProvider.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 5),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete band?',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2).toUpperCase()),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          band.votes.toString(),
        ),
        onTap: () => socketProvider.socket.emit('vote', {'id': band.id}),
      ),
    );
  }
}

class ShowCharts extends StatelessWidget {
  const ShowCharts({Key? key, required this.list}) : super(key: key);
  final List<Band> list;
  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = <String, double>{};
    list.forEach((band) => dataMap.putIfAbsent(band.name, () => band.votes.toDouble()));

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 20,
        chartRadius: MediaQuery.of(context).size.width * .4,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 10,
        centerText: "Votes",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          decimalPlaces: 0,
          showChartValuesInPercentage: true,
          showChartValuesOutside: true,
        ),
      ),
    );
  }
}
