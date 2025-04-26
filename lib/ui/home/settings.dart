import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:Rakshak/api.dart';
import 'package:Rakshak/ui/login.dart';
import '../widgets/appbar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with SingleTickerProviderStateMixin {
  final Box boxLogin = Hive.box("login");
  bool readOnly = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController controllerFName = TextEditingController();
  final TextEditingController controllerMName = TextEditingController();
  final TextEditingController controllerLName = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerbloodGroup = TextEditingController();
  final TextEditingController controllerBirthDate = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> bloodGroups = ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-', 'N/A'];

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _loadUserData() {
    controllerFName.text = boxLogin.get("fname") ?? "";
    controllerMName.text = boxLogin.get("mname") ?? "";
    controllerLName.text = boxLogin.get("lname") ?? "";
    controllerbloodGroup.text = boxLogin.get("bloodGroup") ?? "N/A";
    controllerEmail.text = boxLogin.get("email") ?? "";
    controllerAddress.text = boxLogin.get("address") ?? "";

    String birthDate = boxLogin.get("birthDate") ?? "";
    if (birthDate.isNotEmpty && birthDate.length >= 10) {
      controllerBirthDate.text = birthDate.substring(0, 10);
    } else {
      controllerBirthDate.text = birthDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    String phoneNumber = boxLogin.get("phoneNumber")?.toString() ?? "";
    String fullName = "${boxLogin.get("fname") ?? ""} ${boxLogin.get("lname") ?? ""}";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Profile Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              readOnly ? Icons.edit : Icons.save,
              color: Colors.white,
            ),
            onPressed: _handleEditProfile,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(fullName),

              AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Personal Information"),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: controllerFName,
                              label: "First Name",
                              icon: Icons.person_outline,
                              validator: (value) => value!.isEmpty ? "First name is required" : null,
                            ),

                            _buildTextField(
                              controller: controllerMName,
                              label: "Middle Name",
                              icon: Icons.person,
                            ),

                            _buildTextField(
                              controller: controllerLName,
                              label: "Last Name",
                              icon: Icons.person_outline,
                              validator: (value) => value!.isEmpty ? "Last name is required" : null,
                            ),

                            _buildDateField(
                              controller: controllerBirthDate,
                              label: "Date of Birth",
                              icon: Icons.calendar_today,
                            ),

                            _buildBloodGroupDropdown(),

                            const SizedBox(height: 24),
                            _buildSectionTitle("Contact Information"),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: controllerEmail,
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) return null;
                                final bool emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                                return emailValid ? null : "Enter a valid email";
                              },
                            ),

                            _buildTextField(
                              controller: controllerAddress,
                              label: "Home Address",
                              icon: Icons.home_outlined,
                              keyboardType: TextInputType.streetAddress,
                            ),

                            _buildTextField(
                              value: phoneNumber,
                              label: "Mobile Number",
                              icon: Icons.phone_outlined,
                              readOnlyOverride: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              ),

              const SizedBox(height: 8),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String fullName) {
    final String bloodGroup = boxLogin.get("bloodGroup") ?? "N/A";

    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(fullName),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (!readOnly)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fullName.trim().isEmpty ? "Update Your Profile" : fullName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bloodtype,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  bloodGroup,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Center(
              child: Text(
                readOnly
                    ? "Tap the edit button to update your profile"
                    : "Fill in your details and save when done",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? value,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnlyOverride = false,
  }) {
    final bool fieldReadOnly = readOnlyOverride || readOnly;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? value : null,
        readOnly: fieldReadOnly,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: fieldReadOnly ? Colors.grey : Theme.of(context).primaryColor,
            size: 22,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: fieldReadOnly,
          fillColor: fieldReadOnly ? Colors.grey[50] : null,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: readOnly ? Colors.grey : Theme.of(context).primaryColor,
            size: 22,
          ),
          suffixIcon: readOnly
              ? null
              : IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
            color: Theme.of(context).primaryColor,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[50] : null,
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Blood Group",
          labelStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.bloodtype,
            color: readOnly ? Colors.grey : Theme.of(context).primaryColor,
            size: 22,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[50] : null,
        ),
        value: boxLogin.get("bloodGroup") ?? "N/A",
        onChanged: readOnly ? null : (newValue) {
          setState(() {
            boxLogin.put("bloodGroup", newValue!);
          });
        },
        items: bloodGroups.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: readOnly ? Colors.grey : Theme.of(context).primaryColor,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? initialDate;
    try {
      initialDate = DateTime.parse(controllerBirthDate.text);
    } catch (e) {
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controllerBirthDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Logout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );

      final result = await ApiService().logout(boxLogin.get("phoneNumber") ?? "");

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result) {
        boxLogin.put("loginStatus", false);
        navigateToLogin(context);
      } else {
        _showErrorMessage("Logout failed. Please try again.");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showErrorMessage("Error: $e");
    }
  }

  Future<void> _handleEditProfile() async {
    if (!readOnly) {
      // Validate form
      if (_formKey.currentState!.validate()) {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );

          final success = await ApiService().editProfile(
            controllerFName.text,
            controllerMName.text,
            controllerLName.text,
            controllerEmail.text,
            controllerAddress.text,
            boxLogin.get("phoneNumber") ?? "",
            controllerBirthDate.text,
            boxLogin.get("bloodGroup") ?? "N/A",
          );

          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog

          if (success) {
            // Update local storage with new values
            boxLogin.put("fname", controllerFName.text);
            boxLogin.put("mname", controllerMName.text);
            boxLogin.put("lname", controllerLName.text);
            boxLogin.put("email", controllerEmail.text);
            boxLogin.put("address", controllerAddress.text);
            boxLogin.put("birthDate", controllerBirthDate.text);

            _showSuccessMessage("Profile updated successfully!");
          } else {
            _showErrorMessage("Failed to update profile. Please try again.");
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog
          _showErrorMessage("Error updating profile: $e");
        }
      }
    }

    // Toggle edit mode
    setState(() {
      readOnly = !readOnly;
      if (readOnly) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Login(),
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "?";

    List<String> names = fullName.trim().split(" ");
    String initials = "";

    for (var name in names) {
      if (name.isNotEmpty) {
        initials += name[0];
        if (initials.length >= 2) break;
      }
    }

    return initials.toUpperCase();
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerbloodGroup.dispose();
    controllerBirthDate.dispose();
    controllerFName.dispose();
    controllerMName.dispose();
    controllerLName.dispose();
    _animationController.dispose();
    super.dispose();
  }
}