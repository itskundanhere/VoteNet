import 'package:flutter/material.dart';
import 'package:voter_app/screen/login_screen.dart';

class VotingVerificationScreen extends StatefulWidget {
  const VotingVerificationScreen({super.key});

  @override
  _VotingVerificationScreenState createState() => _VotingVerificationScreenState();
}

class _VotingVerificationScreenState extends State<VotingVerificationScreen> {
  bool _isChecked = false;
  double _sliderPosition = 0.0;
  bool _isSlidingComplete = false;

  void _handleSlide(double value) {
    if (_isChecked) {
      setState(() {
        _sliderPosition = value;
      });

      if (value > 0.8 && !_isSlidingComplete) {
        _isSlidingComplete = true;

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voter Registration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              const Text(
                "Instructions for Data Filling",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),

              // Instructions (Scrollable View)
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: const Padding(
                    padding:  EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          InstructionItem(
  "Ensure Accurate Data Entry",
  "Fill all details exactly as they appear on your Aadhar Card.\n"
  "Double-check for any typing mistakes before submitting."
),
InstructionItem(
  "Name Matching",
  "Enter your full name exactly as printed on your Aadhar Card.\n"
  "Include middle name if present, in the same order."
),
InstructionItem(
  "Aadhar Number Verification",
  "Carefully enter your 12-digit Aadhar number without spaces or dashes.\n"
  "Verify each digit before proceeding."
),
InstructionItem(
  "Date of Birth Accuracy",
  "Enter your date of birth exactly as shown on your Aadhar Card.\n"
  "Use the same format (YYYY/MM/DD) as per your document."
),
InstructionItem(
  "Complete Address Details",
  "Provide your full registered address as per Aadhar records.\n"
  "Include landmarks if necessary for accurate location identification."
),
InstructionItem(
  "Correct PIN Code Entry",
  "Enter the 6-digit PIN code of your registered address.\n"
  "Verify this matches the PIN code associated with your Aadhar Card."
),
InstructionItem(
  "Review Before Submission",
  "Carefully review all entered information before final submission.\n"
  "Ensure every field matches your Aadhar Card details exactly."
),
InstructionItem(
  "Document Verification",
  "Keep your Aadhar Card handy for reference while filling the form.\n"
  "Cross-verify each detail with your physical document."
),
InstructionItem(
  "Avoid Common Mistakes",
  "Don't use nicknames or abbreviations for your name.\n"
  "Ensure no extra spaces are added in any fields."
),
InstructionItem(
  "Data Consistency",
  "All information must match your Aadhar records perfectly.\n"
  "Even small discrepancies can lead to verification failures."
)
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Checkbox for Agreement
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  const Text(
                    "I agree to all the instructions",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // SLIDER BUTTON WITH ARROW
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (_isChecked) {
                    _handleSlide((_sliderPosition + details.primaryDelta! / 200).clamp(0.0, 1.0));
                  }
                },
                onHorizontalDragEnd: (_) {
                  setState(() {
                    if (_sliderPosition < 0.8) {
                      _sliderPosition = 0.0; // Reset slider if not fully completed
                    }
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: _isChecked ? Colors.green : Colors.grey,
                      ),
                    ),
                    Positioned(
                      left: _sliderPosition * (MediaQuery.of(context).size.width - 80),
                      child: Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        alignment: Alignment.center,
                        child:const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(
                              "Slide",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                             SizedBox(width: 5),
                            Icon(Icons.arrow_circle_right, color: Colors.black), // 🡆 Arrow Icon
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Instruction Widget
class InstructionItem extends StatelessWidget {
  final String title;
  final String description;

  const InstructionItem(this.title, this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• $title",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
