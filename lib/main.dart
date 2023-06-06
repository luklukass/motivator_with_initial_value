import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';

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
  int totalEarnedMoney = 0;
  int totalSalary = 0;
  var f = NumberFormat('#,###');
  TextEditingController earnedMoneyController = TextEditingController();
  Timer? countdownTimer;
  Duration remainingTime = Duration.zero;

  void updateRemainingTime() {
    if (departureDate != null) {
      setState(() {
        remainingTime = departureDate!.difference(DateTime.now());
        remainingDays = remainingTime.inDays;
      });
    }
  }


  void saveEarnedMoney(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('earnedMoney', value);
  }

  void savetotalSalary(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('totalSalary', value);
  }


  @override
  void initState() {
    super.initState();
    earnedMoneyController.addListener(computeEarnedMoney);
    earnedMoneyController.addListener(computetotalSalary);
    startCountdownTimer();
    computePassedDays();
    computeRemainingDays();
    computeEarnedMoney();
    computetotalSalary();

    initializeDateFormatting(); // Add this line to initialize date formatting

    // Retrieve saved dates and values from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey('arrivalDate')) {
        setState(() {
          arrivalDate = DateTime.parse(prefs.getString('arrivalDate')!);
          computePassedDays();
          computeRemainingDays();
          computeEarnedMoney();
          computetotalSalary();
        });
      }

      if (prefs.containsKey('departureDate')) {
        setState(() {
          departureDate = DateTime.parse(prefs.getString('departureDate')!);
          computePassedDays();
          computeRemainingDays();
          computeEarnedMoney();
          computetotalSalary();
        });
      }

      if (prefs.containsKey('earnedMoney')) {
        setState(() {
          totalEarnedMoney = prefs.getInt('earnedMoney') ?? 0;
        });
      }

      if (prefs.containsKey('earnedMoneyPerDay')) {
        setState(() {
          earnedMoneyController.text = prefs.getInt('earnedMoneyPerDay').toString();
        });
      }

      if (prefs.containsKey('totalSalary')) {
        setState(() {
          totalSalary = prefs.getInt('totalSalary') ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    earnedMoneyController.removeListener(computeEarnedMoney);
    super.dispose();
  }



  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale('cs', 'CZ'), // Czech
      context: context,
      initialDate: arrivalDate ?? DateTime.now(),
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
        computePassedDays();
        computeRemainingDays();
        computeEarnedMoney();
        computetotalSalary();
      });

      // Save arrival date to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('arrivalDate', arrivalDate.toString());
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale('cs', 'CZ'), // Czech
      context: context,
      initialDate: departureDate ?? DateTime.now(),
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
        computeEarnedMoney();
        computetotalSalary();
        startCountdownTimer();
      });

      // Save departure date to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('departureDate', departureDate.toString());
    }
  }

  void computeRemainingDays() {
    if (departureDate != null) {
      remainingTime = departureDate!.difference(DateTime.now());
      remainingDays = remainingTime.inDays;
    } else {
      remainingDays = 0;
    }
  }

  void computePassedDays() {
    if (arrivalDate != null) {
      final difference = arrivalDate!.difference(DateTime.now()).abs();
      passedDays = difference.inSeconds ~/ Duration.secondsPerDay;
    } else {
      passedDays = 0;
    }
  }

  void startCountdownTimer() {
    updateRemainingTime(); // Update the remaining time immediately

    countdownTimer?.cancel(); // Cancel any existing timer

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        updateRemainingTime(); // Update the remaining time every second

        if (remainingTime.inSeconds <= 0) {
          countdownTimer?.cancel(); // Stop the timer when the countdown is finished
        }
      });
    });
  }

  void computetotalSalary() {
    if (arrivalDate != null && departureDate != null && earnedMoneyController.text.isNotEmpty) {
      int earnedMoneyPerDay = int.tryParse(earnedMoneyController.text) ?? 0;
      int totalDays = passedDays + remainingDays + 1;
      totalSalary = earnedMoneyPerDay * totalDays;
      savetotalSalary(totalSalary); // Save total salary value

      // Save the input value to shared preferences
      saveEarnedMoneyPerDay(earnedMoneyPerDay);
    } else {
      totalSalary = 0;
      savetotalSalary(0); // Save 0 when no value is available
    }
  }

  void computeEarnedMoney() {
    if (arrivalDate != null && earnedMoneyController.text.isNotEmpty) {
      int earnedMoneyPerDay = int.tryParse(earnedMoneyController.text) ?? 0;
      totalEarnedMoney = earnedMoneyPerDay * ( passedDays + 1);
      saveEarnedMoney(totalEarnedMoney); // Save earned money value

      // Save the input value to shared preferences
      saveEarnedMoneyPerDay(earnedMoneyPerDay);
    } else {
      totalEarnedMoney = 0;
      saveEarnedMoney(0); // Save 0 when no value is available
    }
  }

  void saveEarnedMoneyPerDay(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('earnedMoneyPerDay', value);
  }

  void handleCheckButton() {
    setState(() {
      computeEarnedMoney();
    });
  }


  void handleCheckButt() {
    setState(() {
      computetotalSalary();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Motivator'),
          /*actions: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Nápověda'),
                          content: const Text('Po vybrání datumů příjezdu a odjezdu a zadání vydělané částky za jeden den, je třeba kliknout na pole "Vyděláno" a "Celková částka" k výpočtu hodnot. To je nutné udělat také v případě změny částky za den.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18, // Set the font size to 20
                              color: Colors.black,

                            ),),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  child: const Text('Rozumím'),
                                ),
                              ],
                      );
                    },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                 child: Icon(Icons.help),
              ),
            ),
          ],*/
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
                          height: 100,
                          color: Colors.blue,
                          child: Center(
                            child: arrivalDate == null
                                ? Text(
                              'Vyber datum příjezdu',
                              style: TextStyle(
                                fontSize: 22, // Set the font size to 20
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                                color: Colors.black, // Set the text color to white
                              ),
                              textAlign: TextAlign.center,
                            )
                                : Text(
                              'Příjezd: \n${DateFormat('dd/MM/yyyy').format(arrivalDate!)}',
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
                            height: 100,
                            color: Colors.red,
                            child: Center(
                              child: departureDate == null
                                  ? Text(
                                'Vyber datum odjezdu',
                                style: TextStyle(
                                  fontSize: 22, // Set the font size to 20
                                  fontWeight: FontWeight.bold, // Set the font weight to bold
                                  color: Colors.black, // Set the text color to white
                                ),
                                textAlign: TextAlign.center,
                              )
                                  : Text(
                                'Odjezd: \n${DateFormat('dd/MM/yyyy').format(departureDate!)}',
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
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: handleCheckButt,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 100,
                          color: Colors.orangeAccent,
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' $remainingDays dnů a ',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${remainingTime.inHours.remainder(24).toString().padLeft(2, '0')}:${remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 100,
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
                        height: 100,
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 120,
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Částka za den',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextField(
                                controller: earnedMoneyController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Zadej částku',
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey,
                                ),
                                onChanged: (value) {
                                  computeEarnedMoney();
                                  computetotalSalary();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  //child: GestureDetector(
                    //onTap: handleCheckButton,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 120,
                          color: Colors.lightGreen,
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Vyděláno: \n',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${f.format(totalEarnedMoney)}'.replaceAll(',', ' '),
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
                //),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  //child: GestureDetector(
                   // onTap: handleCheckButt,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 100,
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
                                    text: 'Celková částka: \n',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${f.format(totalSalary)}'.replaceAll(',', ' '),
                                    style: TextStyle(
                                      fontSize: 50,
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
                //),
              ],
            ),
            SizedBox(height: 15),
             Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 16), // Add the desired gap height here
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 300,
                            color: Colors.grey,
                            child: Center(
                              child: PieChart(
                                dataMap: {
                                  'Zbývající dny': remainingDays.toDouble(),
                                  'Uplynulé dny': passedDays.toDouble(),
                                },
                                colorList: [Colors.red, Colors.green],
                                chartRadius: 290,
                                legendOptions: LegendOptions(
                                  showLegends: false,
                                ),
                                chartValuesOptions: ChartValuesOptions(
                                  showChartValueBackground: false,
                                  showChartValues: true,
                                  showChartValuesInPercentage: true,
                                  chartValueStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                              ),
                            ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 40,
                          color: Colors.grey,
                          child: Center(

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.circle, color: Colors.red),
                                SizedBox(width: 4),
                                Text('Zbývající dny',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.circle, color: Colors.green),
                                SizedBox(width: 4),
                                Text('Uplynulé dny',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
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
              ],
            ),

            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 16), // Add the desired gap height here
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 300,
                            color: Colors.grey,
                            child: Center(
                              child: PieChart(
                                dataMap: {
                                  'Celková částka': (totalSalary.toDouble() - totalEarnedMoney.toDouble()),
                                  'Vyděláno': totalEarnedMoney.toDouble(),
                                },
                                colorList: [Colors.blue, Colors.orange],
                                chartRadius: 290,
                                legendOptions: LegendOptions(
                                  showLegends: false,
                                ),
                                chartValuesOptions: ChartValuesOptions(
                                  showChartValueBackground: false,
                                  showChartValues: true,
                                  showChartValuesInPercentage: true,
                                  chartValueStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 40,
                        color: Colors.grey,
                        child: Center(

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.circle, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Celková částka',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(Icons.circle, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('Vyděláno',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
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
              ],
            ),

          ],
        ),
      ),
    );
  }
}