import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "IO",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _enterDatafield = TextEditingController();
  List<String> _dataList = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        title: Text(
          'Read/Write',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(13.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _enterDatafield,
              decoration: InputDecoration(
                labelText: 'Write something here..',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _saveData(_enterDatafield.text);
                  },
                  child: Text('Save Data'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _clearData();
                  },
                  child: Text('Clear Data'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Status: $_statusMessage',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dataList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_dataList[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteData(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<void> _saveData(String message) async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final updatedContents = contents.isEmpty ? message : '$contents\n$message';
      await file.writeAsString(updatedContents);
      _loadData();
      setState(() {
        _statusMessage = 'Data Saved';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving data';
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      setState(() {
        _dataList = contents.split('\n').where((item) => item.isNotEmpty).toList();
      });
    } catch (e) {
      setState(() {
        _dataList = [];
      });
    }
  }

  Future<void> _clearData() async {
    try {
      final file = await _localFile;
      await file.writeAsString('');
      _loadData();
      setState(() {
        _statusMessage = 'Data Cleared';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing data';
      });
    }
  }

  Future<void> _deleteData(int index) async {
    try {
      // Load current data
      final file = await _localFile;
      final contents = await file.readAsString();
      final dataList = contents.split('\n').where((item) => item.isNotEmpty).toList();

      // Remove the item at the specified index
      dataList.removeAt(index);

      // Save the updated data list
      final updatedContents = dataList.join('\n');
      await file.writeAsString(updatedContents);

      // Reload data
      _loadData();

      setState(() {
        _statusMessage = 'Data Deleted';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error deleting data';
      });
    }
  }
}
