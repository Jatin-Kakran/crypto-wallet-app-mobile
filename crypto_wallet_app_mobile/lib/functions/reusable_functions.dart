import 'dart:async';

import 'package:flutter/material.dart';

class NavigationHelper {
  /// Push a new page onto the stack
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Push a new page and replace the current one
  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Push a new page and remove all previous pages
  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
          (Route<dynamic> route) => false,
    );
  }

  /// Pop the current page
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}

Future<void> showAlertBoxWithYesAndNoButtons({
  required BuildContext context,
  required String message,
  required VoidCallback onYes,
  VoidCallback? onNo,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // prevent tap outside to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color.fromRGBO(78, 68, 82, 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Warning!!', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onNo != null) onNo();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onYes();
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> showAlertBoxWithTimer({
  required BuildContext context,
  required String message,
  required VoidCallback onYes,
  VoidCallback? onNo,
  int countdownSeconds = 5, // Customize this value when calling
}) async {
  int secondsLeft = countdownSeconds;
  bool isButtonEnabled = false;
  Timer? timer;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Start timer only once
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (secondsLeft <= 1) {
              t.cancel();
              setState(() {
                isButtonEnabled = true;
              });
            } else {
              setState(() {
                secondsLeft--;
              });
            }
          });

          return AlertDialog(
            backgroundColor: const Color.fromRGBO(78, 68, 82, 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Warning!!',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actionsPadding: const EdgeInsets.only(
              bottom: 12,
              left: 12,
              right: 12,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        timer?.cancel();
                        Navigator.of(context).pop();
                        if (onNo != null) onNo();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? Colors.redAccent
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: isButtonEnabled
                          ? () {
                              timer?.cancel();
                              Navigator.of(context).pop();
                              onYes();
                            }
                          : null,
                      child: Text(
                        isButtonEnabled ? "Delete" : "Delete (${secondsLeft}s)",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}



class AlertBoxWithTimer extends StatefulWidget {
  final String message;
  final VoidCallback onYes;
  final VoidCallback? onNo; // Added for explicit "No" option
  final int countdownSeconds;

  const AlertBoxWithTimer({
    Key? key,
    required this.message,
    required this.onYes,
    this.onNo,
    this.countdownSeconds = 5,
  }) : super(key: key);

  @override
  _AlertBoxWithTimerState createState() => _AlertBoxWithTimerState();
}

class _AlertBoxWithTimerState extends State<AlertBoxWithTimer> {
  int _currentCountdown = 0;
  Timer? _timer;
  bool _isYesButtonEnabled = false; // New state variable

  @override
  void initState() {
    super.initState();
    _currentCountdown = widget.countdownSeconds;
    // Start with the Yes button disabled
    _isYesButtonEnabled = false;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { // Check if the widget is still mounted
        timer.cancel();
        return;
      }
      if (_currentCountdown == 0) {
        timer.cancel();
        setState(() {
          _isYesButtonEnabled = true; // Enable the Yes button
        });
      } else {
        setState(() {
          _currentCountdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black, // Example background
      title: const Text("Warning!!", style: TextStyle(color: Colors.red)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          // Display countdown message only while button is disabled
          if (!_isYesButtonEnabled)
            Text(
              "You can confirm in $_currentCountdown seconds...",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          // if (_isYesButtonEnabled)
          //   const Text(
          //     "",
          //     style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
          //   ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _timer?.cancel(); // Cancel timer if user clicks "No"
            widget.onNo?.call(); // Call the optional onNo callback
            Navigator.of(context).pop(false); // Pop with false for "No"
          },
          child: const Text("No", style: TextStyle(color: Colors.white)),
        ),
        // The "Yes" button will be enabled based on _isYesButtonEnabled
        TextButton(
          // onPressed will be null if _isYesButtonEnabled is false, disabling the button
          onPressed: _isYesButtonEnabled
              ? () {
            _timer?.cancel(); // Cancel timer if user clicks "Yes"
            widget.onYes.call(); // Call the onYes callback from parent
            Navigator.of(context).pop(true); // Pop with true for "Yes"
          }
              : null, // Set onPressed to null to disable the button
          child: Text(
            "Yes",
            style: TextStyle(
              color: _isYesButtonEnabled ? Colors.redAccent : Colors.grey, // Change color when disabled
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showPopupAlert({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) async {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(216),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  await Future.delayed(duration);
  overlayEntry.remove();
}
