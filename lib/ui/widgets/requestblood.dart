import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../home/home.dart';
import '/api.dart';

class RequestBlood extends StatefulWidget {
  const RequestBlood({super.key});

  @override
  State<RequestBlood> createState() => _RequestBloodState();
}

class _RequestBloodState extends State<RequestBlood> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Box loginBox = Hive.box("login");
  ApiService apiService = ApiService();

  String? _selectedBloodGroup;
  bool isChecked1 = false;
  bool isChecked2 = false;
  String? _selectedBloodType;
  bool isDateSelected = false;
  DateTime value = DateTime.now();

  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _controllerNeedDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildDatePicker(context),
            _buildQuantityAndBloodGroupFields(context),
            _buildAddressAndBloodTypeFields(context),
            const SizedBox(height: 20),
            _buildCheckboxes(),
            const SizedBox(height: 30),
            _buildSendRequestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width * 0.82,
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(Icons.date_range_outlined, color: Colors.grey[600], size: 25.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: DateTimeField(
              controller: _controllerNeedDate,
              format: DateFormat("MMM d, yyyy h:mm a"),
              validator: (value) {
                if (value == null) {
                  return 'Please enter a date';
                }
                return null;
              },
              onShowPicker: (context, currentValue) async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: currentValue ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.combine(date, time);
                } else {
                  return currentValue;
                }
              },
              onChanged: (date) {
                setState(() {
                  value = date ?? DateTime.now();
                  isDateSelected = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndBloodGroupFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: TextFormField(
            controller: _controllerQuantity,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.fillDrip, size: 20, color: Colors.grey[600]),
              hintText: "Quantity",
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                return "Quantity required";
              }
              return null;
            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.bloodtype_outlined, color: Colors.grey[600], size: 25.0),
              hintText: "Blood Group",
              fillColor: Colors.white,
              filled: true,
            ),
            items: ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-']
                .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                .toList(),
            value: _selectedBloodGroup,
            onChanged: (value) => setState(() => _selectedBloodGroup = value),
            validator: (value) => value == null ? 'Please select blood group' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressAndBloodTypeFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: TextFormField(
            controller: _controllerAddress,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.place, color: Colors.grey[600]),
              hintText: "Address",
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (value) => value == null || value.isEmpty ? "Address required" : null,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.fireFlameSimple, color: Colors.grey[600], size: 20),
              hintText: "Blood Type",
              fillColor: Colors.white,
              filled: true,
            ),
            items: ['Whole Blood', 'Platelets', 'Plasma']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            value: _selectedBloodType,
            onChanged: (value) => setState(() => _selectedBloodType = value),
            validator: (value) => value == null ? 'Please select blood type' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('I agree that this request will be public for all organizations to see.'),
          value: isChecked1,
          onChanged: (value) => setState(() => isChecked1 = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('I agree that I will be charged a fee if the blood bag is not returned within 24 hours.'),
          value: isChecked2,
          onChanged: (value) => setState(() => isChecked2 = value ?? false),
        ),
      ],
    );
  }

  Widget _buildSendRequestButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            if (!isChecked1 || !isChecked2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please agree to the terms and conditions.")),
              );
              return;
            }

            // Debugging: Print values to identify null variables
            print("Phone Number: ${loginBox.get('phoneNumber')}");
            print("Blood Group: $_selectedBloodGroup");
            print("Quantity: ${_controllerQuantity.text}");
            print("Blood Type: $_selectedBloodType");
            print("Address: ${_controllerAddress.text}");
            print("Need By Date: $value");

            final phoneNumber = loginBox.get('phoneNumber');
            if (phoneNumber == null || _selectedBloodGroup == null || _selectedBloodType == null ||
                _controllerQuantity.text.isEmpty || _controllerAddress.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please fill all the required fields.")),
              );
              return;
            }

            // In _buildSendRequestButton method, modify line 237:
            final success = await apiService.sendRequest(
              phoneNumber.toString(), // Convert the integer to string
              _selectedBloodGroup!,
              int.parse(_controllerQuantity.text),
              _selectedBloodType!,
              _controllerAddress.text,
              value,
            );

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Request sent successfully!")),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Home(userId: '', isLoggedIn: true)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to send request. Please try again.")),
              );
            }
          }
        },
        child: const Text("Send Blood Request"),
    );
  }

  @override
  void dispose() {
    _controllerAddress.dispose();
    _controllerQuantity.dispose();
    _controllerNeedDate.dispose();
    super.dispose();
  }
}