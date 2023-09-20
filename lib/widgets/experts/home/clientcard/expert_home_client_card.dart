import 'package:flutter/material.dart';
import 'package:healthonify_mobile/constants/theme_data.dart';
import 'package:healthonify_mobile/screens/expert_screens/client/add_client.dart';
import 'package:healthonify_mobile/screens/expert_screens/home/client_details/expert_connected_clients.dart';
import 'package:healthonify_mobile/widgets/experts/home/clientcard/add_client_dialog.dart';
import 'package:healthonify_mobile/widgets/experts/home/clientcard/add_client_name_dialog.dart';
import 'package:healthonify_mobile/widgets/experts/home/clientcard/addclient_confirm_dialog.dart';

class ExpertHomeClientCard extends StatelessWidget {
  const ExpertHomeClientCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Card(
        color: whiteColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context, /*rootnavigator: true*/).push(
                    MaterialPageRoute(
                        builder: (context) => const ExpertConnectedClients()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text("0"),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Connected Clients",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: whiteColor),
                        ),
                      ],
                    ),
                    TextButton(
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.of(context, /*rootnavigator: true*/).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ExpertConnectedClients()),
                        );
                      },
                      child: Row(
                        children: const [
                          Text("View"),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context, /*rootnavigator: true*/)
                    .push(MaterialPageRoute(builder: (context) {
                  return const AddClientScreen();
                }));
                // showDialog(
                //     context: context,
                //     builder: (context) => _addNewClientDialog(context));
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 25,
                      onPressed: () {
                        Navigator.of(context, /*rootnavigator: true*/)
                            .push(MaterialPageRoute(builder: (context) {
                          return const AddClientScreen();
                        }));
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => _addNewClientDialog(context),
                        // );
                      },
                      icon: const Icon(Icons.person_add),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "ADD A NEW CLIENT",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: orange,
                          ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Dialog _addNewClientDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).canvasColor,
      child: AddClientDialog(
        onNextClick: () {
          showDialog(
              context: context,
              builder: (context) => Dialog(
                    backgroundColor: Theme.of(context).canvasColor,
                    child: AddClientNameDialog(
                      onConnectClick: () {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                  backgroundColor:
                                      Theme.of(context).canvasColor,
                                  child: const AddClientConfirmationDialog(),
                                ));
                      },
                    ),
                  ));
        },
      ),
    );
  }
}
