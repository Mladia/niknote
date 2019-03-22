import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class SnoozeDialog {

// static void showOptions (
//     BuildContext context, {
//     String title = 'Snooze note',
//     String message = '',
//     int noteId
//   }) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         print("---Showing context");
//         return AlertDialog(
//           title: Text(title),
//           actions: <Widget>[
//             FlatButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Okay'),
//             )
//           ],
//         );
//     });
//   }
//TODO:
static void showOptions (
    BuildContext context, {
    String title = 'Snooze note',
    String message = '',
    int noteId
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formats = {
          InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
          InputType.date: DateFormat('yyyy-MM-dd'),
          InputType.time: DateFormat("HH:mm"),
        };


        bool editable = true;
        DateTime date;
        InputType inputType = InputType.both;
        print("Showing context");
        return AlertDialog(
          title: Text(title),
          // content: Text(message),
          actions: <Widget>[
            Text("snoozing"),
            // DateTimePickerFormField(
            //   inputType: inputType,
            //   format: formats[inputType],
            //   editable: editable,
            //   decoration: InputDecoration(
            //       labelText: 'Date/Time', hasFloatingPlaceholder: false),
              // onChanged: (dt) {
              //   print(dt.toString());
              // }
            // ),

            Text('Date value: $date'),
            SizedBox(height: 16.0),
            CheckboxListTile(
              title: Text('Date picker'),
              value: inputType != InputType.time,
              onChanged: (value) => _updateInputType(inputType, date: value),
            ),
            // CheckboxListTile(
            //   title: Text('Time picker'),
            //   value: inputType != InputType.date,
            //   onChanged: (value) => _updateInputType(inputType, time: value),
            // ),
            // CheckboxListTile(
            //   title: Text('Editable'),
            //   value: editable,
            //   onChanged: (value) {
            //     print(value.toString());
            //   }
            // ),


            // FlatButton(
            //   onPressed: () => Navigator.of(context).pop(),
            //   child: Text('Cancel'),
            // ),
            // FlatButton(
            //   onPressed: () {
            //     //TODO:
            //     // snoozeNote(noteId, snoozeDate, snoozeTime);
            //     Navigator.of(context).pop();
            //   },
              // child: Text('Snooze')
            // ),
          ],
        );
      },
    );
  }



static void _updateInputType(InputType inputType, {bool date, bool time}) {
    date = date ?? inputType != InputType.time;
    time = time ?? inputType != InputType.date;
            // date ? time ? InputType.both : InputType.date : InputType.time);
}

}
