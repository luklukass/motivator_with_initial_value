import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motivator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Set app bar background color to black
        ),
        scaffoldBackgroundColor: Colors.black26, // Set scaffold background color to light black
      ),
      home: const ScrolledLayout(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: [
        Locale('en'),
        Locale('cs')
      ],
    );
  }
}

class ScrolledLayout extends StatefulWidget {
  const ScrolledLayout({Key? key}) : super(key: key);

  @override
  _ScrolledLayoutState createState() => _ScrolledLayoutState();
}

class _ScrolledLayoutState extends State<ScrolledLayout> {
  DateTime? arrivalDate;
  DateTime? departureDate;
  int remainingDays = 0;
  int passedDays = 0;

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale('cs', 'CZ'), // Czech
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Apply dark theme to the date picker
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        arrivalDate = picked;
        computeRemainingDays();
      });
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale('cs', 'CZ'), // Czech
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Apply dark theme to the date picker
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        departureDate = picked;
        computePassedDays();
        computeRemainingDays();

      });
    }
  }

  void computeRemainingDays() {
    if (departureDate != null) {
      final difference = departureDate!.difference(DateTime.now());
      remainingDays = difference.inDays + 1;
    } else {
      remainingDays = 0;
    }
  }


  void computePassedDays() {
    if (arrivalDate != null) {
      final difference = arrivalDate!.difference(DateTime.now()).abs();
      passedDays = difference.inDays;
    } else {
      passedDays = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Add a gap at the top
            GestureDetector(
              onTap: () {
                _selectArrivalDate(context);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 150,
                          color: Colors.blue,
                          child: Center(
                            child: arrivalDate == null
                                ? Text('Vyber datum příjezdu',
                              style: TextStyle(
                                fontSize: 25, // Set the font size to 20
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                                color: Colors.black, // Set the text color to white
                              ),
                              textAlign: TextAlign.center,
                            )
                                : Text('Příjezd: \n${DateFormat('dd/MM/yyyy').format(arrivalDate!)}',
                              style: TextStyle(
                                fontSize: 20, // Set the font size to 20
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                                color: Colors.black, // Set the text color to white
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectDepartureDate(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Set circular corners
                          child: Container(
                            height: 150,
                            color: Colors.red,
                            child: Center(
                              child: departureDate == null
                                  ? Text('Vyber datum odjezdu',
                                style: TextStyle(
                                  fontSize: 25, // Set the font size to 20
                                  fontWeight: FontWeight.bold, // Set the font weight to bold
                                  color: Colors.black, // Set the text color to white
                                ),
                                textAlign: TextAlign.center,
                              )
                                  : Text('Odjezd: \n${DateFormat('dd/MM/yyyy').format(departureDate!)}',
                                style: TextStyle(
                                  fontSize: 20, // Set the font size to 20
                                  fontWeight: FontWeight.bold, // Set the font weight to bold
                                  color: Colors.black, // Set the text color to white
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Add a gap between rows
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 150,
                        color: Colors.grey,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Zbývající dny: \n',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '$remainingDays',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 150,
                        color: Colors.grey,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Uplynulé dny: \n',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '$passedDays',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add a gap between rows
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 150,
                        color: Colors.purple,
                        child: const Center(
                          child: Text('Column 1, Row 3'),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 150,
                        color: Colors.red,
                        child: const Center(
                          child: Text('Column 2, Row 3'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add a gap between rows
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 150,
                        color: Colors.teal,
                        child: const Center(
                          child: Text('Column 1, Row 4'),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 150,
                        color: Colors.pink,
                        child: const Center(
                          child: Text('Column 2, Row 4'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add a gap at the bottom
          ],
        ),
      ),
    );
  }
}