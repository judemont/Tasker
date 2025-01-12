import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tasker/widget/buttonNew.dart';
import 'package:tasker/models/group.dart';

import 'package:tasker/models/todo.dart';
import 'package:tasker/widget/groupWidget.dart';
import 'package:tasker/widget/settings.dart';
import 'package:tasker/widget/tasksWidget.dart';
import 'package:tasker/services/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> items = [];
  List<Group> groups = [];

  int selectedGroupId = 1;

  @override
  void initState() {
    print("LLLLLLLLLLL");
    _loadGroups();
    _loadTodoFromGroup(selectedGroupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              "Tasker : ${groups.firstWhere((group) => group.id == selectedGroupId).name}"),
          centerTitle: true,
        ),
        body: Container(
            margin: const EdgeInsets.only(left: 30),
            child: SingleChildScrollView(
                child: Column(children: [
              TasksWidget(
                items: items,
                onListChange: () {
                  _loadTodoFromGroup(selectedGroupId);
                },
                removeTask: _removeTask,
                renameTask: renameTask,
              )
            ]))),
        endDrawer: Drawer(
            child: Settings(
          backup: backup,
          restore: restore,
        )),
        drawer: Drawer(
            child: GroupWidget(
          removeGroup: _removeGroup,
          selectedGroupId: selectedGroupId,
          groupItems: groups,
          onListChange: _loadGroups,
          onTodoChange: _loadTodoFromGroup,
        )),
        floatingActionButton: FloatingNewButton(
          onPressed: () {
            _loadTodoFromGroup(selectedGroupId);
          },
          groupeId: selectedGroupId,
        ));
  }

  Future<void> backup() async {
    DatabaseService db = DatabaseService();
    db.generateBackup().then((String result) {
      Share.share(result);
    });
  }

  Future<void> restore(String backup) async {
    DatabaseService db = DatabaseService();
    db.restoreBackup(backup);
  }

  Future<void> _loadTodoFromGroup(int groupId) async {
    selectedGroupId = groupId;
    print("function  _loadTodoFromGroup");
    print("function  _loadTodoFromGroup ID:$selectedGroupId");

    DatabaseService.getItemFromGroup(selectedGroupId).then((value) {
      setState(() {
        print("Todo COUNT:${value.length}");
        items = value;
      });
    });
  }

  Future<void> _loadGroups() async {
    print("function  _loadGroups");
    DatabaseService.getGroups().then((result) {
      setState(() {
        print("AAAAAAFFFFFA");
        print("Group COUNT:${result.length}");
        groups = result;
      });
    });
  }

  Future<void> _removeTask(int taskId) async {
    print("function  _removeTask");
    DatabaseService.removeTask(taskId);
  }

  Future<void> _removeTaskFromGroup(int groupId) async {
    print("function  _removeTaskFromGroup");
    DatabaseService.removeTasksFromGroup(groupId);
  }

  Future<void> _removeGroup(int groupId) async {
    DatabaseService.removeGroup(groupId);
  }

  Future<void> renameTask(
      Todo todo, String newName, String newDescription) async {
    todo.content = newName;
    todo.description = newDescription;
    DatabaseService.updateTask(todo);
  }
}
