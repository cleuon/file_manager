import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final FileManagerController controller = FileManagerController();

  @override
  Widget build(BuildContext context) {
    // Creates a widget that registers a callback to veto attempts by the user to dismiss the enclosing
    // or controllers the system's back button
    return WillPopScope(
      onWillPop: () async => (await controller.goToParentDirectory()),
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => sort(context),
                icon: Icon(Icons.sort_rounded),
              ),
              IconButton(
                onPressed: () => selectStorage(context),
                icon: Icon(Icons.sd_storage_rounded),
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                await controller.goToParentDirectory();
              },
            ),
          ),
          body: Container(
            margin: EdgeInsets.all(10),
            child: FileManager(
              controller: controller,
              builder: (context, snapshot) {
                final List<FileSystemEntity> entities = snapshot;
                return ListView.builder(
                  itemCount: entities.length,
                  itemBuilder: (context, index) {
                    FileSystemEntity entity = entities[index];
                    return Card(
                      child: ListTile(
                        leading: isFile(entity)
                            ? Icon(Icons.feed_outlined)
                            : Icon(Icons.folder),
                        title: Text(basename(entity)),
                        subtitle: subtitle(entity),
                        onTap: () async {
                          if (isDirectory(entity)) {
                            // open the folder
                            controller.openDirectory(entity);

                            // delete a folder
                            // await entity.delete(recursive: true);

                            // rename a folder
                            // await entity.rename("newPath");

                            // Check weather folder exists
                            // entity.exists();

                            // get date of file
                            // DateTime date = (await entity.stat()).modified;
                          } else {
                            // delete a file
                            // await entity.delete();

                            // rename a file
                            // await entity.rename("newPath");

                            // Check weather file exists
                            // entity.exists();

                            // get date of file
                            // DateTime date = (await entity.stat()).modified;

                            // get the size of the file
                            // int size = (await entity.stat()).size;
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )),
    );
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;
            return Text(
              "$size",
            );
          }
          return Text(
            "${snapshot.data!.modified}",
          );
        } else {
          return Text("");
        }
      },
    );
  }

  selectStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                              title: Text(
                                "${basename(e)}",
                              ),
                              onTap: () {
                                controller.openDirectory(e);
                                Navigator.pop(context);
                              },
                            ))
                        .toList()),
              );
            }
            return Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  sort(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                        title: Text("Name"),
                        onTap: () {
                          controller.sortedBy = SortBy.name;
                          Navigator.pop(context);
                        }),
                    ListTile(
                        title: Text("Size"),
                        onTap: () {
                          controller.sortedBy = SortBy.size;
                          Navigator.pop(context);
                        }),
                    ListTile(
                        title: Text("Date"),
                        onTap: () {
                          controller.sortedBy = SortBy.date;
                          Navigator.pop(context);
                        }),
                    ListTile(
                        title: Text("type"),
                        onTap: () {
                          controller.sortedBy = SortBy.type;
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
            ));
  }
}
