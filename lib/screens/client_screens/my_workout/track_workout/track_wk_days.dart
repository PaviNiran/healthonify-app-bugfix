import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:healthonify_mobile/models/workout/workout_model.dart';
import 'package:healthonify_mobile/screens/client_screens/my_workout/track_workout/track_workout.dart';
import 'package:healthonify_mobile/widgets/cards/custom_appbar.dart';

class TrackWkDays extends StatefulWidget {
  final WorkoutModel workoutModel;
  const TrackWkDays({required this.workoutModel, Key? key}) : super(key: key);

  @override
  State<TrackWkDays> createState() => _TrackWkDaysState();
}

class _TrackWkDaysState extends State<TrackWkDays> {
  List<String> notes = [];
  late String title;
  void popScreen() {
    Navigator.of(context).pop();
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    log("hey");
    title = widget.workoutModel.name ?? "";
    if (widget.workoutModel.schedule != null) {
      log("inside");
      notes = List.generate(widget.workoutModel.schedule!.length,
          (index) => widget.workoutModel.schedule![index].note ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        appBarTitle: 'Track your workout',
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Text(
                  widget.workoutModel.name!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  "${widget.workoutModel.daysInweek}  ${widget.workoutModel.daysInweek == "1" ? "day" : "days"} a week, for ${widget.workoutModel.validityInDays} days",
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Text(
              widget.workoutModel.description ?? "",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.workoutModel.schedule!.length,
            itemBuilder: (context, index) {
              return dayCards(
                  widget.workoutModel.schedule![index], notes[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget dayCards(Schedule schedule, String note, int index) {
    return ListTile(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: ((context) => TrackWorkout(
                  schedule: schedule,
                  workoutPlanId: widget.workoutModel.id!,
                  title: widget.workoutModel.name ?? "",
                )),
          ),
        )
            .then((value) {
          if (value != null) {
            List<ExerciseWorkoutModel> exmodel = value;
            // log("ex model ${exmodel.toString()}");
            setState(() {
              schedule.exercises = exmodel;
            });
          }
        });
      },
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                schedule.day ?? "",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child:
                      Text(note, style: Theme.of(context).textTheme.bodySmall!),
                ),
              ],
            )
          ],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onBackground,
        size: 30,
      ),
    );
  }
}
