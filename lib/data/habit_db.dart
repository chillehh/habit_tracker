import 'package:habit_tracker/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Reference the box
final _myBox = Hive.box('habit_tracker_db');

class HabitDB {
  List todaysHabitList = [];
  Map<DateTime, int> heatmapDataSet = {};

  // Create initial data for first time use on app
  void createDefaultData() {
    todaysHabitList = [
      ['Go for a walk', false],
      ['Do the dishes', false],
    ];

    _myBox.put('START_DATE', todaysDateFormatted());
  }

  // Load data if it already exists
  void loadData() {
    // Check if the day has changed
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      // Reset habits for the new day
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    } else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  // Update database
  void updateData() {
    // Update today's entry
    _myBox.put(todaysDateFormatted(), todaysHabitList);

    // Update universal habit list
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    // Calculate habit complete percentages for each day
    calculateHabitPercentages();

    // Load heatmap
    loadHeatmap();
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percentage = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // key: PERCENTAGE_SUMMARY_yyyymmdd
    // value: string of 1dp number between 0.0 & 1.0 inclusive
    _myBox.put('PERCENTAGE_SUMMARY_${todaysDateFormatted()}', percentage);
  }

  void loadHeatmap() {
    DateTime startDate = createDateTimeObject(_myBox.get('START_DATE'));

    // Count number of days to load onto heatmap
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // Go from start date to today and add each percentage to the dataset
    // PERCENTAGE_SUMMARY_yyyymmdd will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get('PERCENTAGE_SUMMARY_$yyyymmdd') ?? '0.0',
      );

      // Year
      int year = startDate.add(Duration(days: i)).year;

      // Month
      int month = startDate.add(Duration(days: i)).month;

      // Day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatmapDataSet.addEntries(percentForEachDay.entries);
    }
  }
}
