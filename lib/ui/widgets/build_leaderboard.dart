import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildList(BuildContext context, int index, List leaderboardData) {
  // First safety check - if data item is invalid
  if (leaderboardData[index] == null) {
    return const SizedBox.shrink();
  }

  int ind = index + 1;
  double leftPadding = 38;

  // Safely access total_donations with more robust null check
  final totalDonations = leaderboardData[index]['total_donations'] is int
      ? leaderboardData[index]['total_donations']
      : 0;

  // String length check now happens after ensuring totalDonations is non-null
  String totalDonationsStr = totalDonations.toString();
  if (totalDonationsStr.length == 2) {
    leftPadding = 33;
  } else {
    leftPadding = 39;
  }

  // More robust null handling for strings
  final firstNameRaw = leaderboardData[index]['first_name'];
  String firstName = firstNameRaw != null ? firstNameRaw.toString() : '';

  final lastNameRaw = leaderboardData[index]['last_name'];
  String lastName = lastNameRaw != null ? lastNameRaw.toString() : '';

  // Truncate long names after ensuring they're non-null
  if (lastName.length > 15) {
    lastName = lastName.substring(0, 15);
  }

  if (firstName.length > 15) {
    firstName = firstName.substring(0, 15);
  }

  // Rest of your widget code continues unchanged
  Widget crown;

  if (ind == 1) {
    crown = const Padding(
        padding: EdgeInsets.only(right: 0.0),
        child: Center(
            child: Icon(
              FontAwesomeIcons.medal,
              size: 36,
              color: Colors.yellow,
            )));
  } else if (ind == 2) {
    crown = Padding(
        padding: const EdgeInsets.only(right: 0.0),
        child: Center(
            child: Icon(
              FontAwesomeIcons.medal,
              size: 36,
              color: Colors.grey[300],
            )));
  } else if (ind == 3) {
    crown = Padding(
        padding: const EdgeInsets.only(right: 0.0),
        child: Center(
            child: Icon(
              FontAwesomeIcons.medal,
              size: 36,
              color: Colors.orange[300],
            )));
  } else {
    crown = CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 13,
        child: Text(
          ind.toString(),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ));
  }

  return Padding(
    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
    child: Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff92bdef), Color(0xffa2d2ff)]),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: Row(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        child: crown,
                      ),
                    ),
                    Align(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 5),
                              child: Text(
                                "$firstName\n$lastName",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Rubik",
                                    fontSize: 18),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                textAlign: TextAlign.center,
                "${totalDonations * 450}\nml",
                style: const TextStyle(
                    color: Colors.black,
                    fontFamily: "Rubik",
                    fontSize: 18),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Stack(children: [
              const Padding(
                  padding:
                  EdgeInsets.only(left: 20.0, top: 5, bottom: 5, right: 20),
                  child: Icon(
                    FontAwesomeIcons.certificate,
                    size: 50,
                    color: Color(0xfff6e2bd),
                  )),
              Padding(
                padding: EdgeInsets.only(left: leftPadding, top: 17),
                child: Text(
                  "$totalDonations",
                  style: const TextStyle(
                      color: Colors.black,
                      fontFamily: "Rubik",
                      fontSize: 22),
                ),
              ),
            ]),
          )
        ],
      ),
    ),
  );
}