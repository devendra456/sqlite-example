import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_file/open_file.dart';
import 'package:untitled1/helpers/path_helper.dart';

import '../../helpers/sqflite_database_helper.dart';

class SQLFLiteCreateAndUpdateScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const SQLFLiteCreateAndUpdateScreen({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<SQLFLiteCreateAndUpdateScreen> createState() =>
      _SQLFLiteCreateAndUpdateScreenState();
}

class _SQLFLiteCreateAndUpdateScreenState
    extends State<SQLFLiteCreateAndUpdateScreen> {
  final formKey = GlobalKey<FormState>();
  num? lat;
  num? lng;
  File? selectedFile;
  String name = '';

  TimeOfDay? time;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      name = widget.userData!["name"];
      lat = num.parse(widget.userData!["lat"]);
      lng = num.parse(widget.userData!["lng"]);
      selectedFile = File(widget.userData!["filePath"]);
      time = TimeOfDay(
          hour: int.parse(
              widget.userData!["time"].toString().split(":").first),
          minute: int.parse(
              widget.userData!["time"].toString().split(":").last));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fill And Save"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Your Name",
                  label: Text("Name"),
                ),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please Enter Your Name";
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    name = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    (lat == null || lng == null)
                        ? "Location Not Selected"
                        : "$lat, $lng",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  MaterialButton(
                    onPressed: () {
                      getLocation();
                    },
                    child: const Text("Get Location"),
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    selectedFile == null
                        ? "File Not Selected"
                        : selectedFile?.path.split("/").last ?? "",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (selectedFile != null)
                    CloseButton(
                      onPressed: () {
                        selectedFile = null;
                        setState(() {});
                      },
                    ),
                  selectedFile == null
                      ? MaterialButton(
                          onPressed: () {
                            selectImage();
                          },
                          child: const Text("Select any file"),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            await OpenFile.open("${selectedFile?.path}");
                          },
                          child: const Text("Preview"),
                        ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    time == null
                        ? "Time Not Selected"
                        : time?.format(context) ?? "",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      setState(() {});
                    },
                    child: const Text("Select any file"),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    saveToDataBase();
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveToDataBase() async {
    if (lat == null || lng == null) {
      Fluttertoast.showToast(msg: "please select location");
      return;
    }
    if (selectedFile == null) {
      Fluttertoast.showToast(msg: "please choose file");
      return;
    }
    if (time == null) {
      Fluttertoast.showToast(msg: "please select time");
      return;
    }
    final path = selectedFile?.path.split("/").last ?? "";
    final filePath = await getFilePath(path);
    File(filePath)
        .writeAsBytesSync(selectedFile?.readAsBytesSync().toList() ?? []);
    print(filePath);
    if (widget.userData == null) {
      await SQFLiteDatabaseHelper.instance.saveUserDataToSQFLITE({
        "name": name,
        "lat": "$lat",
        "lng": "$lng",
        "filePath": filePath,
        "time": "${time?.format(context)}"
      });
    } else {
      await SQFLiteDatabaseHelper.instance.updateUserDetails({
        "srn": widget.userData!["srn"],
        "name": name,
        "lat": "$lat",
        "lng": "$lng",
        "filePath": filePath,
        "time": "${time?.format(context)}"
      });
    }

    Navigator.pop(context);
  }

  void getLocation() async {
    final Position? position = await getCurrentLocation();
    print(position);
    if (position != null) {
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
      });
    }
  }

  void selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      selectedFile = File(result.files.single.path!);
      setState(() {});
    }
  }

  Future<bool> checkGPS() async {
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (serviceStatus) {
      print("GPS service is Enabled");
      return true;
    } else {
      print("GPS service is disabled.");
      await Geolocator.openLocationSettings();
      return false;
    }
  }

  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied2');
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        print('Location permissions are deniedForever');
        //You can also show a dialog to user for giving manual permission.
        await Geolocator.openAppSettings();
        return false;
      } else if (permission == LocationPermission.unableToDetermine) {
        print('Location permissions are unableToDetermine');
        return false;
      } else {
        print('Location permissions are Granted');
        return true;
      }
    } else {
      print('Location permissions are Granted');
      return true;
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (await checkGPS()) {
      if (await checkPermission()) {
        return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      }
    }
    return null;
  }
}
