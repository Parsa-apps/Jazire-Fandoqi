import 'package:flutter/material.dart';

void main() {
  runApp(const KudakeIranApp());
  }

  class KudakeIranApp extends StatelessWidget {
    const KudakeIranApp({super.key});

      @override
        Widget build(BuildContext context) {
            return MaterialApp(
                  debugShowCheckedModeBanner: false,
                        home: Scaffold(
                                backgroundColor: const Color(0xFF6C63FF),
                                        body: const Center(
                                                  child: Text(
                                                              "KudakeIran v1.0",
                                                                          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                            ),
                                                                                                  ),
                                                                                                      );
                                                                                                        }
                                                                                                        }