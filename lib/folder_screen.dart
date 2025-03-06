import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'card_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final data = await DatabaseHelper.instance.getFolders();
    setState(() {
      _folders = data;
    });
  }

  Future<void> _addFolder() async {
    TextEditingController folderController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Folder"),
          content: TextField(
            controller: folderController,
            decoration: InputDecoration(hintText: "Enter folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (folderController.text.isNotEmpty) {
                  await DatabaseHelper.instance.addFolder(
                    folderController.text,
                  );
                  _loadFolders();
                }
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFolder(int id) async {
    await DatabaseHelper.instance.deleteFolder(id);
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Organizer')),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CardScreen(
                        folderId: _folders[index]['id'],
                        folderName: _folders[index]['name'],
                      ),
                ),
              );
            },
            child: Card(
              color: Colors.purpleAccent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _folders[index]['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteFolder(_folders[index]['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        child: Icon(Icons.add),
      ),
    );
  }
}
