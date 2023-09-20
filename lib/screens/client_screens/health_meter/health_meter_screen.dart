import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthonify_mobile/constants/theme_data.dart';
import 'package:healthonify_mobile/models/hra_model/hra_model.dart';
import 'package:healthonify_mobile/models/http_exception.dart';
import 'package:healthonify_mobile/models/vitals/all_vitals.dart';
import 'package:healthonify_mobile/providers/health_risk_assessment/hra_provider.dart';
import 'package:healthonify_mobile/providers/user_data.dart';
import 'package:healthonify_mobile/providers/vitals/blood_glucose_data.dart';
import 'package:healthonify_mobile/providers/vitals/blood_pressure_data.dart';
import 'package:healthonify_mobile/screens/client_screens/health_meter/HRA/hra_screen.dart';
import 'package:healthonify_mobile/screens/client_screens/health_meter/blood_pressure/blood_pressure_screen.dart';
import 'package:healthonify_mobile/screens/client_screens/vitals_screens/blood_glucose_screen.dart';
import 'package:healthonify_mobile/widgets/buttons/custom_buttons.dart';
import 'package:healthonify_mobile/widgets/cards/custom_appbar.dart';
import 'package:provider/provider.dart';

class HealthMeterScreen extends StatefulWidget {
  const HealthMeterScreen({Key? key}) : super(key: key);

  @override
  State<HealthMeterScreen> createState() => _HealthMeterScreenState();
}

class _HealthMeterScreenState extends State<HealthMeterScreen> {
  late String userId;
  List<HraAnswerModel> hraAnswers = [];
  Future<void> getHraAnswers() async {
    try {
      hraAnswers = await Provider.of<HraProvider>(context, listen: false)
          .getHraScore(userId);
      log('hra score fetched');
    } on HttpException catch (e) {
      log("Unable to fetch hra score $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    } catch (e) {
      log("Error loading hra score $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  Future<void> getbloodPressure(BuildContext context) async {
    try {
      await Provider.of<BloodPressureData>(context, listen: false)
          .getBpData(userId, "today");
    } on HttpException catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: "Something went wrong");
    } catch (e) {
      log("Error enquiry widget $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  BloodGlucose bloodGlucose = BloodGlucose();

  Future<void> getBloodGlucose() async {
    String userId = Provider.of<UserData>(context, listen: false).userData.id!;
    try {
      bloodGlucose = await Provider.of<BloodGlucoseData>(context, listen: false)
          .getBloodGlucose(userId, "today");
    } on HttpException catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: "Something went wrong");
    } catch (e) {
      log("Error blood glucose $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserData>(context, listen: false).userData.id!;

    getbloodPressure(context);
    getBloodGlucose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(appBarTitle: 'Health Meter'),
      body: FutureBuilder(
        future: getHraAnswers(),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        healthMeterCard(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'HRA Report',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: whiteColor),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      'Borderline',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Colors.transparent,
                                            decoration:
                                                TextDecoration.underline,
                                            shadows: [
                                              const Shadow(
                                                color: whiteColor,
                                                offset: Offset(0, -5),
                                              ),
                                            ],
                                            decorationColor: Colors.white,
                                            decorationThickness: 2,
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Score: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(color: whiteColor),
                                    ),
                                    hraAnswers.isNotEmpty
                                        ? Text(
                                            '${hraAnswers[0].hraScore}/${hraAnswers[0].maxScore}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(color: whiteColor),
                                          )
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(right: 6),
                                            child: Text(
                                              '0',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(color: whiteColor),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GradientButton(
                                      title: 'View',
                                      func: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return HraScreen(
                                            hraData: hraAnswers,
                                          );
                                        }));
                                      },
                                      gradient: blueGradient,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return HraScreen(
                                hraData: hraAnswers,
                              );
                            }));
                          },
                        ),
                        Consumer<BloodPressureData>(
                          builder: (context, value, child) {
                            return healthMeterCard(
                              context,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      'BP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(color: whiteColor),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Latest Score",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: whiteColor,
                                              ),
                                        ),
                                        const Spacer(),
                                        // Text(
                                        //   'Score: ',
                                        //   style: Theme.of(context)
                                        //       .textTheme
                                        //       .labelMedium!
                                        //       .copyWith(color: whiteColor),
                                        // ),
                                        if (value.bpData.latestData != null)
                                          Text(
                                            "${value.bpData.latestData!['systolic'] ?? "0"}/${value.bpData.latestData!['diastolic'] ?? "0"}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(color: whiteColor),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Average Score',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: whiteColor,
                                              ),
                                        ),
                                        const Spacer(),
                                        // Text(
                                        //   'Score: ',
                                        //   style: Theme.of(context)
                                        //       .textTheme
                                        //       .labelMedium!
                                        //       .copyWith(color: whiteColor),
                                        // ),
                                        if (value.bpData.averageData != null)
                                          Text(
                                            value.bpData.averageData != null
                                                ? "${value.bpData.averageData!['systolic']}/${value.bpData.averageData!['diastolic']}"
                                                : "No data available",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: whiteColor),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const BloodPressureScreen();
                                }));
                              },
                            );
                          },
                        ),
                        healthMeterCard(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Blood Glucose',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: whiteColor),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      "Latest Reading",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: whiteColor,
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      bloodGlucose.recentLogs == null
                                          ? "0 mg/dl"
                                          : bloodGlucose.recentLogs![0]
                                                      .bloodGlucoseLevel ==
                                                  null
                                              ? 'No data available'
                                              : '${bloodGlucose.recentLogs![0].bloodGlucoseLevel} mg/dl',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: whiteColor),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      'Average Reading',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: whiteColor,
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      bloodGlucose.averageData == null
                                          ? "0 mg/dl"
                                          : bloodGlucose.averageData![
                                                      'fastingTypeAverage'] ==
                                                  null
                                              ? 'No data available'
                                              : '${bloodGlucose.averageData!['fastingTypeAverage']} mg/dl',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: whiteColor),
                                    ),
                                  ],
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 16, vertical: 10),
                              //   child: Row(
                              //     children: [
                              //       Text(
                              //         "Today's PP",
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .bodyMedium!
                              //             .copyWith(
                              //               color: whiteColor,
                              //             ),
                              //       ),
                              //       const Spacer(),
                              //       Text(
                              //         'Score: ',
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .labelMedium!
                              //             .copyWith(color: whiteColor),
                              //       ),
                              //       Text(
                              //         '-',
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .bodyLarge!
                              //             .copyWith(color: whiteColor),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 16, vertical: 10),
                              //   child: Row(
                              //     children: [
                              //       Text(
                              //         'Weekly average PP',
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .bodyMedium!
                              //             .copyWith(
                              //               color: whiteColor,
                              //             ),
                              //       ),
                              //       const Spacer(),
                              //       Text(
                              //         'Score: ',
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .labelMedium!
                              //             .copyWith(color: whiteColor),
                              //       ),
                              //       Text(
                              //         '-',
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .bodyLarge!
                              //             .copyWith(color: whiteColor),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const BloodGlucoseScreen();
                            }));
                          },
                        ),
                        // healthMeterCard(
                        //   context,
                        //   Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.all(8),
                        //         child: Text(
                        //           'Daily Calorie Goal',
                        //           style: Theme.of(context)
                        //               .textTheme
                        //               .titleLarge!
                        //               .copyWith(color: whiteColor),
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //             horizontal: 16, vertical: 10),
                        //         child: Row(
                        //           children: [
                        //             Text(
                        //               "Weekly average calorie balance",
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .bodyMedium!
                        //                   .copyWith(
                        //                     color: whiteColor,
                        //                   ),
                        //             ),
                        //             const Spacer(),
                        //             Text(
                        //               '-',
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .bodyLarge!
                        //                   .copyWith(color: whiteColor),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //             horizontal: 16, vertical: 10),
                        //         child: Row(
                        //           children: [
                        //             Text(
                        //               'Monthly average calorie balance',
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .bodyMedium!
                        //                   .copyWith(
                        //                     color: whiteColor,
                        //                   ),
                        //             ),
                        //             const Spacer(),
                        //             Text(
                        //               '-',
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .bodyLarge!
                        //                   .copyWith(color: whiteColor),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        //   () {
                        //     Navigator.push(context, MaterialPageRoute(builder: (context) {
                        //       return const CalorieDetailScreen();
                        //     }));
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget healthMeterCard(context, Widget text, Function onClicked) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: InkWell(
          onTap: () {
            onClicked();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // height: 125,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8C0000),
                  Color(0xFFFF5757),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: text,
          ),
        ),
      ),
    );
  }
}
