import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/home_fab.dart';
import 'package:habit_tracker/components/alert_box.dart';
import 'package:habit_tracker/components/monthly_summary.dart';
import 'package:habit_tracker/data/habit_db.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data structure for todays list
  HabitDB db = HabitDB();
  final _myBox = Hive.box('habit_tracker_db');

  @override
  void initState() {
    // Check for a first time startup
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }

    // Update the db
    db.updateData();

    super.initState();
  }

  // Toggle checkbox
  void toggleCheckbox(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateData();
  }

  // Create a new habit
  final _newHabitNameController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertBox(
          controller: _newHabitNameController,
          hintText: 'Enter Habit Name',
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Save a new habit
  void saveNewHabit() {
    // Add new habit to the list
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    db.updateData();

    // Clear text
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  // Cancel a new habit
  void cancelDialogBox() {
    // Clear text
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  // Open habit settings
  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertBox(
          controller: _newHabitNameController,
          hintText: 'Update Habit Name',
          onSave: () => updateExistingHabit(index),
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Update a habit and save the changes
  void updateExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    db.updateData();

    // Clear text
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  // Delete a habit
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: HomeFloatingActionButton(
        onPressed: createNewHabit,
      ),
      body: ListView(
        children: [
          MonthlySummaryChart(
            datasets: db.heatmapDataSet,
            startDate: _myBox.get('START_DATE'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: db.todaysHabitList.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habitName: db.todaysHabitList[index][0],
                habitCompleted: db.todaysHabitList[index][1],
                onChanged: (value) => toggleCheckbox(value, index),
                settingsTapped: (context) => openHabitSettings(index),
                deleteTapped: (context) => deleteHabit(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
