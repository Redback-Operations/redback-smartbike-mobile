import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttTest extends StatefulWidget {
  @override
  _MqttTestState createState() => _MqttTestState();
}

class _MqttTestState extends State<MqttTest> {
  late MqttServerClient _client;
  final String topic = 'myhome/temperature';
  String _textValue = 'Yet to get topic message';

  @override
  void initState() {
    // Host: 	broker.hivemq.com
    // TCP Port: 	1883
    // Websocket Port: 	8000
    // TLS TCP Port: 	8883
    // TLS Websocket Port: 	8884

    // client.logging(on: true);
    _client = MqttServerClient.withPort(
        'broker.hivemq.com', 'q2904387q29038742432r3', 1883);
    // _client.keepAlivePeriod = 20;
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    _client.onUnsubscribed = onUnsubscribed;
    _client.onSubscribed = onSubscribed;
    _client.onSubscribeFail = onSubscribeFail;
    _client.connect(); // un password?
    super.initState();
  }

  void _publishMessage() {
    final builder = MqttClientPayloadBuilder();
    final random = Random();
    int randomNumber = 20 + random.nextInt(16); // Generates a random number between 20 and 35
    builder.addString("$randomNumber degrees");
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void onConnected() {
    print('MQTT_LOGS:: Connected');
    _client.subscribe(topic, MqttQos.atMostOnce);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        _textValue = pt;
      });
      print(
          'MQTT_LOGS:: New data arrived: topic is <${c[0].topic}>, payload is $pt');
    });
  }

  void onDisconnected() {
    print('MQTT_LOGS:: Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTT_LOGS:: Subscribed topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void onUnsubscribed(String? topic) {
    print('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_textValue),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _publishMessage,
              child: Text('Publish current temperature'),
            ),
          ],
        ),
      ),
    );
  }
}
