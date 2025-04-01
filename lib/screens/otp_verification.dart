
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../screens/otp_verified.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Prevents overflow by allowing scrolling
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'DeliGo',
                    style: GoogleFonts.pacifico(
                      fontSize: 45,
                      color: const Color(0xFFFF460A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Enter Your Verification Code',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We are automatically detecting an SMS\nsent to your mobile number ******1230',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Pinput(
                    length: 4,
                    controller: _otpController,
                    onCompleted: (pin) {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => NextScreen()), // Replace with your next screen widget
                      // );
                    },
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFBEA8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF460A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF460A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: RichText(
                      text: TextSpan(
                        text: "Didn't Receive OTP? ",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "Resend OTP",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF460A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Number Pad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                      itemCount: 12,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          return const SizedBox.shrink();
                        } else if (index == 11) {
                          return IconButton(
                            icon: const Icon(
                              Icons.backspace,
                              size: 28,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (_otpController.text.isNotEmpty) {
                                setState(() {
                                  _otpController.text = _otpController.text
                                      .substring(
                                    0,
                                    _otpController.text.length - 1,
                                  );
                                });
                              }
                            },
                          );
                        } else {
                          int num = index == 10 ? 0 : index + 1;
                          return GestureDetector(
                            onTap: () {
                              if (_otpController.text.length < 4) {
                                setState(() {
                                  _otpController.text += num.toString();
                                });
                                if (_otpController.text.length == 4) {
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VerifiedScreen()), // Replace with your next screen
                                    );
                                  });
                                }

                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                num.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Extra spacing for bottom balance
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
