import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthonify_mobile/func/string_date_format.dart';
import 'package:healthonify_mobile/models/consultation.dart';
import 'package:healthonify_mobile/providers/user_data.dart';
import 'package:healthonify_mobile/screens/expert_screens/appointments/physio/expert_physio_consultation_details_screen.dart';
import 'package:healthonify_mobile/widgets/cards/custom_appbar.dart';
import 'package:healthonify_mobile/providers/get_consultation.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExpertViewPhysioConsultations extends StatefulWidget {
  const ExpertViewPhysioConsultations({Key? key, required this.clientID})
      : super(key: key);
  final String? clientID;

  @override
  State<ExpertViewPhysioConsultations> createState() =>
      _ExpertViewPhysioConsultationsState();
}

class _ExpertViewPhysioConsultationsState
    extends State<ExpertViewPhysioConsultations> {
  bool _isLoading = false;
  List<Consultation> data = [];
  var snackBar = const SnackBar(
    content: Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Text('No more Appointments!'),
    ),
    duration: Duration(milliseconds: 1000),
  );
  int currentPage = 0;

  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    //added the pagination function with listener
    getData(firstTime: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
  }

  void getData({bool firstTime = false}) async {
    setState(() {
      _isLoading = true;
    });
    await getConsultations(context, firstTime);
    setState(() {
      _isLoading = false;
    });
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
    );
  }

  Future<bool> getConsultations(
    BuildContext context,
    bool firstTime, {
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      currentPage = 0;
    }
    log(currentPage.toString());
    String expertId =
        Provider.of<UserData>(context, listen: false).userData.id!;
    try {
      var resultData =
          await Provider.of<GetConsultation>(context, listen: false)
              .getConsultation("expertId=$expertId&userId=${widget.clientID}",
                  currentPage.toString());

      if (isRefresh) {
        data = resultData;
        return true;
      }

      if (resultData.length != 20) {
        if (currentPage == 0 && !firstTime) {
          data = resultData;
          _refreshController.loadNoData();
          showSnackBar();
          return true;
        } else {
          log("hey");
          data.addAll(resultData);
        }
      } else {
        data.addAll(resultData);
      }
      currentPage = currentPage + 1;
      setState(() {});
      return true;
    } on HttpException catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: e.message);
      return false;
    } catch (e) {
      log("Error getting consultations $e");
      Fluttertoast.showToast(msg: "Unable to fetch consultations");
      return false;
    } finally {
      // setState(() {
      //   _isPaginationLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        appBarTitle: 'Your Appointments',
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : data.isEmpty
              ? const Center(
                  child: Text("No appointments available"),
                )
              : SmartRefresher(
                  controller: _refreshController,
                  enablePullUp: true,
                  footer: footer,
                  onRefresh: () async {
                    final result =
                        await getConsultations(context, false, isRefresh: true);
                    if (result) {
                      _refreshController.refreshCompleted();
                    } else {
                      _refreshController.refreshFailed();
                    }
                  },
                  onLoading: () async {
                    final result = await getConsultations(context, false);
                    if (result) {
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadFailed();
                    }
                  },
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        if (data[index].status == "initiated") {
                          return expertCardFree(context, data[index]);
                        }
                        return expertCardPaid(context, data[index]);
                      }),
                ),
    );
  }

  Widget expertCardFree(BuildContext context, Consultation consultationData) {
    final date =
        StringDateTimeFormat().stringtDateFormat(consultationData.startDate!);
    final time =
        StringDateTimeFormat().stringToTimeOfDay(consultationData.startTime!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Free Consultation",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            date,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ExpertPhysioConsultationDetailsScreen(
                        consultationData: consultationData,
                      );
                    }));
                  },
                  child: const Text('View details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget expertCardPaid(BuildContext context, Consultation consultationData) {
    final date =
        StringDateTimeFormat().stringtDateFormat(consultationData.startDate!);
    final time =
        StringDateTimeFormat().stringToTimeOfDay(consultationData.startTime!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          consultationData.expertiseId!.isNotEmpty
                              ? consultationData.expertiseId![0]["name"]
                              : "Free Consultation",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.videocam_outlined,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            consultationData.status == "meetingLinkGenerated" ||
                                    consultationData.status == "expertAssigned"
                                ? "Scheduled"
                                : 'Meeting yet to schedule',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            date,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 36,
                    backgroundImage:
                        !consultationData.expertId!.containsKey("imageUrl") ||
                                consultationData.expertId!["imageUrl"] == ""
                            ? const AssetImage(
                                "assets/icons/user.png",
                              ) as ImageProvider
                            : NetworkImage(
                                consultationData.expertId!["imageUrl"]!,
                              ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ExpertPhysioConsultationDetailsScreen(
                        consultationData: consultationData,
                      );
                    }));
                  },
                  child: const Text('View details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CustomFooter footer = CustomFooter(
    builder: (context, mode) {
      Widget? body;
      if (mode == LoadStatus.idle) {
        body = const Text("");
      } else if (mode == LoadStatus.loading) {
        body = const CupertinoActivityIndicator();
      } else if (mode == LoadStatus.failed) {
        body = const Text("Load Failed!Click retry!");
      } else if (mode == LoadStatus.canLoading) {
        body = const Text("Release to load more");
      } else if (mode == LoadStatus.noMore) {
        body = const Text("No more Appointments");
      } else {
        body = const Text("No more Data");
      }
      return SizedBox(
        height: 55.0,
        child: Center(child: body),
      );
    },
  );
}
