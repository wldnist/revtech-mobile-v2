import 'package:flutter/material.dart';

class AlertDialogCustom {
// showAlertDialog(BuildContext context, String message, String heading,
//      String buttonAcceptTitle, String buttonCancelTitle) {
//    // set up the buttons
//    Widget cancelButton = FlatButton(
//      child: Text(buttonCancelTitle),
//      onPressed: () {},
//    );
//    Widget continueButton = FlatButton(
//      child: Text(buttonAcceptTitle),
//      onPressed: () {
//
//      },
//    );
//
//    // set up the AlertDialog
//    AlertDialog alert = AlertDialog(
//      title: Text(heading),
//      content: Text(message),
//      actions: [
//        cancelButton,
//      ],
//    );
//
//    // show the dialog
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return alert;
//      },
//    );
//  }
  showAlertDialog(BuildContext context, String message, String heading,
      String buttonAcceptTitle) {
    // set up the buttons
    Widget okButton = TextButton(
      child: Text(buttonAcceptTitle),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(heading),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
