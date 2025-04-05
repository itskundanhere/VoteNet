import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:voter_app/screen/qr_code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  bool _isLoading = false;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime firstDate = DateTime(currentDate.year - 100);
    final DateTime lastDate = DateTime(currentDate.year - 18);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveUserData() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // First check if Aadhaar number already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection("voters")
          .where("aadhar_number", isEqualTo: _aadharController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.red[100],
                      radius: 30,
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Duplicate Entry",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "This Aadhaar number is already registered!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      // If Aadhaar doesn't exist, proceed with saving
      final docRef = await FirebaseFirestore.instance.collection("voters").add({
        'name': _nameController.text.trim(),
        'dob': _dobController.text,
        'address': _addressController.text.trim(),
        'pin_code': _pinController.text.trim(),
        'aadhar_number': _aadharController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'verified': false,
      });

      // Show success message
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    radius: 30,
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Registration Successful!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Thank you for your submission. Your QR code will be generated now.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoterQrScreen(documentId: docRef.id),
                        ),
                      );
                    },
                    child: const Text(
                      "GENERATE QR CODE",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    radius: 30,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Error Occurred",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "An error occurred while saving data: ${error.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "TRY AGAIN",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Please enter details as per your Aadhaar Card:",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),

                        // Aadhaar Number Field
                        TextFormField(
                          controller: _aadharController,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          decoration: const InputDecoration(
                            labelText: "Aadhaar Number*",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Aadhaar number';
                            }
                            if (value.length != 12) {
                              return 'Aadhaar must be 12 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Only numbers allowed';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Full Name*",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? "Please enter your name" : null,
                        ),
                        const SizedBox(height: 15),

                        // Date of Birth Field
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Date of Birth*",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) =>
                              value?.isEmpty ?? true ? "Please select your DOB" : null,
                        ),
                        const SizedBox(height: 15),

                        // Address Field
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Address*",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? "Please enter your address" : null,
                        ),
                        const SizedBox(height: 15),

                        // PIN Code Field
                        TextFormField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: "PIN Code*",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                            counterText: "",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter PIN code';
                            }
                            if (value.length != 6) {
                              return 'PIN must be 6 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveUserData,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 27, 160, 227),
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "REGISTER & GENERATE QR CODE",
                                    style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 1, 0, 0)),
                                  ),
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
    );
  }
}