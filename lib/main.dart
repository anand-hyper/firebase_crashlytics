import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart'; // Make sure you have this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Crashlytics error handling for Flutter errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set user identifier for better crash tracking
  await FirebaseCrashlytics.instance.setUserIdentifier('AB159386');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Crashlytics Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Crashlytics Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _initializeCrashlytics();
  }

  void _initializeCrashlytics() async {
    // Set custom keys for better crash context
    await FirebaseCrashlytics.instance.setCustomKey('screen', 'home_page');
    await FirebaseCrashlytics.instance.setCustomKey('client', 'AB159386');
    await FirebaseCrashlytics.instance.setCustomKey('app_version', '2.0.1');

    // Log app initialization
    await FirebaseCrashlytics.instance.log('App initialized successfully');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Log counter increments for tracking user behavior
    FirebaseCrashlytics.instance.log('Counter incremented to $_counter');

    // Set counter as custom key
    FirebaseCrashlytics.instance.setCustomKey('counter_value', _counter);
  }

  // Method to record a non-fatal error
  void _recordNonFatalError() async {
    try {
      // Simulate an error condition
      throw Exception('This is a demo non-fatal error - Counter value: $_counter');
    } catch (e, stack) {
      // Record the error without crashing the app
      await FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'User triggered demo non-fatal error',
        fatal: false,
      );

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non-fatal error recorded! Check Firebase dashboard.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Method to record a fatal error (will crash the app)
  void _recordFatalError() async {
    try {
      throw Exception('This is a demo fatal error - Counter: $_counter');throw Exception('This is a demo fatal error - Counter: $_counter');
    } catch (e, stack) {
      // Record as fatal error (this will crash the app)
      await FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'User triggered demo fatal error',
        fatal: true,
      );
    }
  }

  // Method to force a crash (for testing purposes)
  void _forceCrash() {
    // Log before crash
    FirebaseCrashlytics.instance.log('User initiated force crash with counter: $_counter');

    // This will immediately crash the app
    FirebaseCrashlytics.instance.crash();
  }

  // Method to simulate a null pointer exception
  void _simulateNullError() {
    try {
      String? nullString;
      int length = nullString!.length; // This will throw
      print('Length: $length'); // This won't execute
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Simulated null pointer exception',
        fatal: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Null pointer error recorded!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to simulate async error
  void _simulateAsyncError() async {
    await FirebaseCrashlytics.instance.log('Starting async operation');

    // Simulate async operation that fails
    Future.delayed(const Duration(seconds: 1), () {
      throw Exception('Async operation failed - Counter: $_counter');
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Async error will be recorded in 1 second!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Original counter section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'You have pushed the button this many times:',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _incrementCounter,
                        icon: const Icon(Icons.add),
                        label: const Text('Increment Counter'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Crashlytics demo section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Firebase Crashlytics Demo',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Non-fatal error button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _recordNonFatalError,
                          icon: const Icon(Icons.warning),
                          label: const Text('Record Non-Fatal Error'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Null pointer error button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _simulateNullError,
                          icon: const Icon(Icons.error_outline),
                          label: const Text('Simulate Null Error'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[300],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Async error button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _simulateAsyncError,
                          icon: const Icon(Icons.access_time),
                          label: const Text('Simulate Async Error'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Fatal error button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _recordFatalError,
                          icon: const Icon(Icons.dangerous),
                          label: const Text('Record Fatal Error'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Force crash button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _forceCrash,
                          icon: const Icon(Icons.crisis_alert),
                          label: const Text('Force Crash (Test Only)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[900],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: const Text(
                          'These buttons demonstrate different types of errors and crashes. Check your Firebase Crashlytics dashboard to see the recorded events.',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}