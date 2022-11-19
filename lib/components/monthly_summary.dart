import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/datetime/date_time.dart';

class MonthlySummaryChart extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final String startDate;

  const MonthlySummaryChart({
    super.key,
    required this.datasets,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 25, bottom: 25),
      child: HeatMap(
        startDate: createDateTimeObject(startDate),
        endDate: DateTime.now().add(const Duration(days: 0)),
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: Colors.grey[200],
        textColor: Colors.white,
        showColorTip: false,
        showText: true,
        scrollable: true,
        size: 30,
        colorsets: const {
          1: Color.fromARGB(20, 179, 79, 8),
          2: Color.fromARGB(40, 179, 79, 8),
          3: Color.fromARGB(60, 179, 79, 8),
          4: Color.fromARGB(80, 179, 79, 8),
          5: Color.fromARGB(100, 179, 79, 8),
          6: Color.fromARGB(120, 179, 79, 8),
          7: Color.fromARGB(150, 179, 79, 8),
          8: Color.fromARGB(180, 179, 79, 8),
          9: Color.fromARGB(220, 179, 79, 8),
          10: Color.fromARGB(255, 179, 79, 8),
        },
        onClick: (value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value.toString())));
        },
      ),
    );
  }
}
