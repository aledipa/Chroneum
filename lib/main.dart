import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const NeuTimer());
}

class NeuTimer extends StatelessWidget {
  const NeuTimer({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return const NeumorphicApp(
      title: "Chroneum",
      theme: NeumorphicThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Button Text Controller
  TextEditingController actionButtonController = TextEditingController(text: 'START');
  //Timer Text Controllers
  TextEditingController secsController = TextEditingController(text: '00');
  TextEditingController minsController = TextEditingController(text: '00');
  TextEditingController hoursController = TextEditingController(text: '00');
  //Chrono Text Controllers
  TextEditingController millisChronoController = TextEditingController(text: '00');
  TextEditingController secsChronoController = TextEditingController(text: '00');
  TextEditingController minsChronoController = TextEditingController(text: '00');
  TextEditingController hoursChronoController = TextEditingController(text: '00');
  //Timer and Chrono Stream Controllers
  StreamController streamControllerSeconds = StreamController();
  StreamController streamControllerMilliSeconds = StreamController();


  //Timer and Chrono int variables
  int seconds = 00;
  int minutes = 00;
  int hours = 00;
  int millisecondsChrono = 00;
  int millisecondsChronoBackup = 00;
  int secondsChrono = 00;
  int minutesChrono = 00;
  int hoursChrono = 00;
  int timeLeft = 0;
  int timePassed = 0;
  int currentPage = 0;
  int timeMinutesTypeTransitions = 0;
  int timeHoursTypeTransitions = 0;

  //Timer and Chrono bool variables
  bool started = false;
  bool startedChrono = false;
  bool chronoHasOnce = false;

  //Timer seconds stream runner
  Future secondsSetter() async {
    for (int h=hours+1; h>=0; h--) {
      for (int m=minutes+1; m>=0; m--) {
        for (int s=seconds; s>=0; s--) {
          if (!started) {
            break;
          }
          streamControllerSeconds.add(s);
          if (s == 59) {
            await Future.delayed(const Duration(seconds: 0));
          } else {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
    }
  }

  //Chrono seconds stream runner
  Future timeCounter() async {
    if (startedChrono) {
      for (int h=hoursChrono; h<=24; h++) {
        if (!startedChrono) {break;} // breaks
        for (int m=minutesChrono; m<=60; m++) {
          if (!startedChrono) {break;} // breaks
          for (int s=secondsChrono; s<=60; s++) {
            if (!startedChrono) {break;} // breaks
            if (millisecondsChronoBackup > 0) {
              millisecondsChrono = (millisecondsChronoBackup / 10).round();
              millisecondsChronoBackup = 0;
            }
            for (int ms=millisecondsChrono; ms<=10; ms++) {
              if (!startedChrono) {break;} // breaks
              streamControllerMilliSeconds.add(ms*10);
              if (ms == 10) {
                await Future.delayed(const Duration(milliseconds: 0));
              } else {
                await Future.delayed(const Duration(milliseconds: 98));
              }
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //Timer Stream
    Stream stream = streamControllerSeconds.stream;
    stream.listen((value) {
      seconds = value as int;
      if (minutes == 0 && seconds == 0 && hours > 0) {
        timeHoursTypeTransitions++;
        if (timeHoursTypeTransitions > 1) {
          minutes = 59;
          seconds = 59;
          hours--;
          timeHoursTypeTransitions = 0;
          }
      }
      if (seconds == 0 && minutes > 0) {
        timeMinutesTypeTransitions++;
        if (timeMinutesTypeTransitions > 1) {
          seconds = 59;
          minutes--;
          timeMinutesTypeTransitions = 0;
        }
      }
      updateTime();
      setState(() {
        if (timerIsEmpty()) {
          AudioCache().play('../sounds/Ringtone.mp3');
          started = false;
          actionButtonController.text = "START";
        }
      });
    });
  }

  void startChronoStream() {
    //Chrono Stream
    Stream streamChrono = streamControllerMilliSeconds.stream;
    streamChrono.listen((value) { 
      millisecondsChrono = value as int;
      if(hoursChrono > 23) {
        startedChrono = false;
      }
      if (minutesChrono == 60) {
        minutesChrono = 0;
        hoursChrono++;
      }
      if (secondsChrono >= 60) {
        secondsChrono = 0;
        minutesChrono++;
      }
      if (millisecondsChrono == 100) {
        millisecondsChrono = 0;
        secondsChrono++;
      }

      updateChronoTime();
      setState(() {});
    });

  }

  double getPercentage() {
    return (seconds + (minutes*60) + (hours*60*60)) / timeLeft;
  }

  bool timerIsEmpty() {
    return (seconds == 0.0 && minutes == 0.0 && hours == 0.0);
  }

  bool chronoIsEmpty() {
    return (millisecondsChrono == 0.0 && secondsChrono == 0.0 && minutesChrono == 0.0 && hoursChrono == 0.0);
  }

  Color? getActionButtonColor() {
    if (started) {
      return Colors.red[400];
    } else {
      if (timerIsEmpty()) {
        return Colors.black38;
      }
      return Colors.green[400];
    }
  }

  Color? getResetButtonColor() {
    if (timerIsEmpty()) {
      return Colors.black54;
    } else {
      return Colors.red[600];
    }
  }

  Color? getChronoResetButtonColor() {
    if (chronoIsEmpty()) {
      return Colors.black54;
    } else {
      return Colors.red[600];
    }
  }

  IconData getActionButtonIcon() {
    if (started) {
      return Icons.stop_rounded;
    } else {
      return Icons.play_arrow_rounded;
    }
  }

  IconData getResetButtonIcon() {
    if (started) {
      return Icons.close_rounded;
    } else {
      return Icons.restore_rounded;
    }
  }

  double getResetButtonDepth() {
    if (timerIsEmpty()) {
      return 0.0;
    } else {
      return 3.0;
    }
  }

  double getChronoResetButtonDepth() {
    if (chronoIsEmpty()) {
      return 0.0;
    } else {
      return 5.0;
    }
  }

  double getActionButtonDepth() {
    if (timerIsEmpty()) {
      return 0.0;
    } else {
      return 5.0;
    }
  }

  void updateTime() {
    var formats = [seconds, minutes, hours];
    var textFormats= ["00", "00", "00"];

    for (int i=0; i<formats.length; i++) {
        if (formats[i].toString().length < 2) {
          textFormats[i] = "0${formats[i].toString()}";
        } else {
          textFormats[i] = formats[i].toString();
        }
    }

    secsController.text = textFormats[0];
    minsController.text = textFormats[1];
    hoursController.text = textFormats[2];
  }

  void updateChronoTime() {
    var formats = [millisecondsChrono, secondsChrono, minutesChrono, hoursChrono];
    var textFormats= ["00", "00", "00", "00"];

    for (int i=0; i<formats.length; i++) {
        if (formats[i].toString().length < 2) {
          textFormats[i] = "0${formats[i].toString()}";
        } else {
          textFormats[i] = formats[i].toString();
        }
    }

    millisChronoController.text = textFormats[0];
    secsChronoController.text = textFormats[1];
    minsChronoController.text = textFormats[2];
    hoursChronoController.text = textFormats[3];
  }

  void resetTime() {
    seconds = 0;
    minutes = 0;
    hours = 0;
    timeLeft = 0;
    started = false;
  }

  void resetChronoTime() {
    millisecondsChrono = 0;
    secondsChrono = 0;
    minutesChrono = 0;
    hoursChrono = 0;
    startedChrono = false;
  }

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: 0);

    return PageView(
      controller: pageController,
      children: [
        Scaffold(
          appBar: NeumorphicAppBar(
            title: NeumorphicText(
              "Chroneum",
              style: const NeumorphicStyle(
                color: Colors.black87,
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 25
              ),
            ),
          ),

          body: Center(
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 70)),

                if (!started) Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 50,)),

                    NeumorphicButton(
                      onPressed: () {setState(() {
                        if (hours < 23) {
                          hours++;
                        } else {
                          hours = 0;
                        }
                        updateTime();
                      });},
                      pressed: false,
                      provideHapticFeedback: true,
                      style: const NeumorphicStyle(
                        depth: 3,
                        boxShape: NeumorphicBoxShape.circle(),
                        shape: NeumorphicShape.convex,
                      ),
                      child: NeumorphicIcon(
                        Icons.add_rounded,
                        size: 30,
                        style: const NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    NeumorphicButton(
                      onPressed: () {setState(() {
                        if (minutes < 59) {
                          minutes++;
                        } else {
                          minutes = 0;
                        }
                        updateTime();
                      });},
                      style: const NeumorphicStyle(
                        depth: 3,
                        boxShape: NeumorphicBoxShape.circle(),
                        shape: NeumorphicShape.convex,
                      ),
                      child: NeumorphicIcon(
                        Icons.add_rounded,
                        size: 30,
                        style: const NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          color: Colors.black45,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    NeumorphicButton(
                      onPressed: () {setState(() {
                        if (seconds < 59) {
                          seconds++;
                        } else {
                          seconds = 0;
                        }
                        updateTime();
                      });},
                      style: const NeumorphicStyle(
                        depth: 3,
                        boxShape: NeumorphicBoxShape.circle(),
                        shape: NeumorphicShape.convex,
                      ),
                      child: SizedBox(
                        child: NeumorphicIcon(
                          Icons.add_rounded,
                          size: 30,
                          style: const NeumorphicStyle(
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20,),

                SizedBox(
                  width: 300,
                  height: 100,
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      depth: -5,
                    ),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 20)),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            hoursController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[600],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),

                        NeumorphicText(
                          ": ",
                          style: const NeumorphicStyle(
                            color: Colors.black54,
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 40,
                            height: 0.9,
                          ),
                        ),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            minsController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[500],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),

                        NeumorphicText(
                          ": ",
                          style: const NeumorphicStyle(
                            color: Colors.black54,
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 40,
                            height: 0.9,
                          ),
                        ),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            secsController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[400],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),
                    
                        NeumorphicButton(
                          onPressed: () {
                            setState(() {
                              resetTime();
                              updateTime();
                              if (!started) {actionButtonController.text = "START";}
                            });
                          },
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(left: 13),
                          style: NeumorphicStyle(
                            depth: getResetButtonDepth(),
                          ),
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: NeumorphicIcon(
                              getResetButtonIcon(),
                              size: 25,
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.convex,
                                color: getResetButtonColor(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!started) Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 50)),

                    NeumorphicButton(
                      onPressed: () {setState(() {
                        if (hours > 0) {
                          hours--;
                        } else {
                          hours = 23;
                        }
                        updateTime();
                      });},
                      style: const NeumorphicStyle(
                        depth: 3,
                        boxShape: NeumorphicBoxShape.circle(),
                        shape: NeumorphicShape.convex,
                      ),
                      child: NeumorphicIcon(
                        Icons.remove_rounded,
                        size: 30,
                        style: const NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    NeumorphicButton(
                      onPressed: () {setState(() {
                        if (minutes > 0) {
                          minutes--;
                        } else {
                          minutes = 59;
                        }
                        updateTime();
                      });},
                      style: const NeumorphicStyle(
                        depth: 3,
                        boxShape: NeumorphicBoxShape.circle(),
                        shape: NeumorphicShape.convex,
                      ),
                      child: NeumorphicIcon(
                        Icons.remove_rounded,
                        size: 30,
                        style: const NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          color: Colors.black45,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    NeumorphicButton(
                      onPressed: () {setState(() {
                        if (seconds > 0) {
                          seconds--;
                        } else {
                          seconds = 59;
                        }
                        updateTime();
                      });},
                      style: const NeumorphicStyle(
                        depth: 3,
                        boxShape: NeumorphicBoxShape.circle(),
                        shape: NeumorphicShape.convex,
                      ),
                      child: NeumorphicIcon(
                        Icons.remove_rounded,
                        size: 30,
                        style: const NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),

                if (!started) 
                  const SizedBox(height: 100)
                else 
                  const SizedBox(height: 25),

                if (started) 
                  Column(
                    children: [
                      SizedBox(
                        width: 250,
                        child: NeumorphicProgress(
                          percent: getPercentage(),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.linear,
                          height: 10,
                          style: const ProgressStyle(
                            depth: 10,
                          ),
                        ),
                      ),

                      const SizedBox(height: 165),
                    ],
                  ),


                Row(
                  children: [
                    const SizedBox(width: 115,),

                    NeumorphicButton(
                      onPressed: () {
                        setState(() {
                          if (!timerIsEmpty()) {
                            started = !started;
                            if (started) {
                              actionButtonController.text = "STOP";
                              secondsSetter();
                            } else {
                              actionButtonController.text = "START";
                            }
                          }
                          
                        });

                        timeLeft = seconds + (minutes*60) + (hours*60*60);
                      },
                      style: NeumorphicStyle(
                        depth: getActionButtonDepth(),
                        color: getActionButtonColor(),
                      ),
                      child: Row(
                        children: [
                          NeumorphicIcon(
                            getActionButtonIcon(),
                            size: 35,
                          ),
                          const Padding(padding: EdgeInsets.only(left: 3)),
                          SizedBox(
                            width: 70,
                            child: NeumorphicText(
                              actionButtonController.text,
                              textStyle: NeumorphicTextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(padding: EdgeInsets.only(top: 85)),

                Row(
                  children: [   
                    const Padding(padding: EdgeInsets.only(left: 87.5)),             
                    SizedBox(
                      width: 200,
                      height: 95,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: 3,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(35)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 25),

                            Column(
                              children: [
                                const SizedBox(height: 14),

                                NeumorphicButton(
                                  onPressed: () {pageController.animateToPage(0, duration: const Duration(milliseconds: 150), curve: Curves.linear);},
                                  style: const NeumorphicStyle(
                                    depth: 0.5,
                                    boxShape: NeumorphicBoxShape.circle(),
                                    shape: NeumorphicShape.concave,
                                  ),
                                  child: NeumorphicIcon(
                                    Icons.av_timer_rounded,
                                    size: 30,
                                    style: NeumorphicStyle(
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                NeumorphicText(
                                  "Timer",
                                  style: NeumorphicStyle(
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 15),

                            Column(
                              children: [
                                const SizedBox(height: 14),

                                NeumorphicButton(
                                  onPressed: () {pageController.animateToPage(1, duration: const Duration(milliseconds: 150), curve: Curves.linear);},
                                  style: const NeumorphicStyle(
                                    depth: 0.5,
                                    boxShape: NeumorphicBoxShape.circle(),
                                    shape: NeumorphicShape.convex,
                                  ),
                                  child: NeumorphicIcon(
                                    Icons.timer_rounded,
                                    size: 30,
                                    style: const NeumorphicStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                NeumorphicText(
                                  "Chrono",
                                  style: const NeumorphicStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

  /*
    ====================================
              Second Scaffold
            The Chronmeter's page
    ====================================
  */

        Scaffold(
          appBar: NeumorphicAppBar(
            title: NeumorphicText(
              "Chroneum",
              style: const NeumorphicStyle(
                color: Colors.black87,
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 25
              ),
            ),
          ),

          body: Center(
            child: Column(
              children: [
                const SizedBox(height: 90),

                SizedBox(
                  width: 325,
                  height: 100,
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      depth: -5,
                    ),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 20)),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            hoursChronoController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[600],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),

                        NeumorphicText(
                          ": ",
                          style: const NeumorphicStyle(
                            color: Colors.black54,
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 40,
                            height: 0.9,
                          ),
                        ),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            minsChronoController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[500],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),

                        NeumorphicText(
                          ": ",
                          style: const NeumorphicStyle(
                            color: Colors.black54,
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 40,
                            height: 0.9,
                          ),
                        ),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            secsChronoController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[400],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),

                        NeumorphicText(
                          ": ",
                          style: const NeumorphicStyle(
                            color: Colors.black54,
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 40,
                            height: 0.9,
                          ),
                        ),

                        SizedBox(
                          width: 55,
                          child: NeumorphicText(
                            millisChronoController.text,
                            style: NeumorphicStyle(
                              color: Colors.blue[300],
                            ),
                            textStyle: NeumorphicTextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),

                if (!startedChrono) SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: NeumorphicButton(
                          onPressed: () {
                            setState(() {
                              resetChronoTime();
                              updateChronoTime();
                            });
                          },
                          style: NeumorphicStyle(
                            depth: getChronoResetButtonDepth(),
                          ),
                          child: Center(
                            child: NeumorphicIcon(
                              Icons.close_rounded,
                              size: 35,
                              style: NeumorphicStyle(
                                color: getChronoResetButtonColor(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 25),

                      SizedBox(
                        width: 60,
                        child: NeumorphicButton(
                          onPressed: () {
                            if (!chronoHasOnce) {
                              startChronoStream();
                            }
                            setState(() {
                              startedChrono = true;
                              chronoHasOnce = true;
                              timeCounter();
                            });
                          },
                          style: NeumorphicStyle(
                            depth: 5,
                            shape: NeumorphicShape.convex,
                            color: Colors.green[400],
                          ),
                          child: Center(
                            child: NeumorphicIcon(
                              Icons.play_arrow_rounded,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                if (startedChrono) SizedBox(
                  width: 145,
                  child: NeumorphicButton(
                    onPressed: () {
                      setState(() {
                        startedChrono = false;
                        millisecondsChronoBackup = millisecondsChrono;
                        timeCounter();
                      });
                    },
                    style: NeumorphicStyle(
                      depth: 5,
                      color: Colors.red[400],
                      shape: NeumorphicShape.convex,
                    ),
                    child: Row(
                      children: [
                        NeumorphicIcon(
                          Icons.stop_rounded,
                          size: 35,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 3)),
                        SizedBox(
                          width: 70,
                          child: NeumorphicText(
                            "STOP",
                            textStyle: NeumorphicTextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 205),

                Row(
                  children: [   
                    const Padding(padding: EdgeInsets.only(left: 97)),             
                    SizedBox(
                      width: 200,
                      height: 95,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: 3,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(35)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 25),

                            Column(
                              children: [
                                const SizedBox(height: 14),

                                NeumorphicButton(
                                  onPressed: () {pageController.animateToPage(0, duration: const Duration(milliseconds: 150), curve: Curves.linear);},
                                  style: const NeumorphicStyle(
                                    depth: 0.5,
                                    boxShape: NeumorphicBoxShape.circle(),
                                    shape: NeumorphicShape.convex,
                                  ),
                                  child: NeumorphicIcon(
                                    Icons.av_timer_rounded,
                                    size: 30,
                                    style: const NeumorphicStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                NeumorphicText(
                                  "Timer",
                                  style: const NeumorphicStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 15),

                            Column(
                              children: [
                                const SizedBox(height: 14),

                                NeumorphicButton(
                                  onPressed: () {pageController.animateToPage(1, duration: const Duration(milliseconds: 150), curve: Curves.linear);},
                                  style: const NeumorphicStyle(
                                    depth: 0.5,
                                    boxShape: NeumorphicBoxShape.circle(),
                                    shape: NeumorphicShape.concave,
                                  ),
                                  child: NeumorphicIcon(
                                    Icons.timer_rounded,
                                    size: 30,
                                    style: NeumorphicStyle(
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                NeumorphicText(
                                  "Chrono",
                                  style: NeumorphicStyle(
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}