import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Rakshak/api.dart';
import 'package:Rakshak/services/auth_service.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  ApiService apiService = ApiService();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey();

  // Animation controller
  late AnimationController _animationController;
  bool _isLoading = false;

  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodeAddress = FocusNode();
  final FocusNode _focusNodeFirstName = FocusNode();
  final FocusNode _focusNodeMiddleName = FocusNode();
  final FocusNode _focusNodeLastName = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();

  String? _selectedBloodGroup;
  String errorMessage = "";
  String? _selectedGender;
  String? birthDateInString;
  DateTime? birthDate;
  bool isDateSelected = false;

  final TextEditingController _controllerPhoneNumber = TextEditingController();
  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerMiddleName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword = TextEditingController();

  final Box _boxLogin = Hive.box("login");
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800)
    );

    // Setup focus node listeners for interactive effects
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
    _focusNodeAddress.addListener(() {
      setState(() {});
    });
    // Add more listeners for other focus nodes
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Background design
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Main form content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Please fill in your details",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Phone number field
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) => _buildInputField(
                        controller: _controllerPhoneNumber,
                        labelText: "Phone Number",
                        hintText: "Enter your phone number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a valid phone number.";
                          } else if (value.length != 10) {
                            return "Phone number should be 10 digits.";
                          }
                          return null;
                        },
                        onEditingComplete: () => _focusNodeFirstName.requestFocus(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name fields
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInputField(
                            controller: _controllerFirstName,
                            focusNode: _focusNodeFirstName,
                            labelText: "First Name",
                            hintText: "First Name",
                            icon: Icons.person_outline,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Required";
                              }
                              return null;
                            },
                            onEditingComplete: () => _focusNodeMiddleName.requestFocus(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _buildInputField(
                            controller: _controllerLastName,
                            focusNode: _focusNodeLastName,
                            labelText: "Last Name",
                            hintText: "Last Name",
                            icon: Icons.person_outline,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Required";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Email field
                    _buildInputField(
                      controller: _controllerEmail,
                      focusNode: _focusNodeEmail,
                      labelText: "Email",
                      hintText: "Enter your email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email.";
                        } else if (!(value.contains('@') && value.contains('.'))) {
                          return "Invalid email format.";
                        }
                        return null;
                      },
                      onEditingComplete: () => _focusNodeAddress.requestFocus(),
                    ),

                    const SizedBox(height: 16),

                    // Address field
                    _buildInputField(
                      controller: _controllerAddress,
                      focusNode: _focusNodeAddress,
                      labelText: "Address",
                      hintText: "Enter your address",
                      icon: Icons.home_outlined,
                      keyboardType: TextInputType.streetAddress,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter address.";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date and Blood Group row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            value: _selectedBloodGroup,
                            hint: "Blood Group",
                            icon: Icons.bloodtype_outlined,
                            items: ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-', 'N/A'],
                            onChanged: (value) {
                              setState(() {
                                _selectedBloodGroup = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Gender selection
                    _buildDropdownField(
                      value: _selectedGender,
                      hint: "Select Gender",
                      icon: FontAwesomeIcons.venusMars,
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select gender';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    _buildInputField(
                      controller: _controllerPassword,
                      focusNode: _focusNodePassword,
                      labelText: "Password",
                      hintText: "Create password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter password.";
                        } else if (value.length < 8) {
                          return "Min 8 characters required.";
                        }
                        return null;
                      },
                      onEditingComplete: () => _focusNodeConfirmPassword.requestFocus(),
                    ),

                    const SizedBox(height: 16),

                    // Confirm password field
                    _buildInputField(
                      controller: _controllerConFirmPassword,
                      focusNode: _focusNodeConfirmPassword,
                      labelText: "Confirm Password",
                      hintText: "Confirm password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm password.";
                        } else if (value != _controllerPassword.text) {
                          return "Passwords don't match.";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // Signup button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleSignup,
                        child: _isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                            : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern input field widget
  Widget _buildInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    VoidCallback? onEditingComplete,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Icon(icon, color: focusNode?.hasFocus ?? false
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: onTogglePassword,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: validator,
        onEditingComplete: onEditingComplete,
      ),
    );
  }

  // Dropdown field widget
  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        value: value,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
        elevation: 2,
        style: TextStyle(color: Colors.black87, fontSize: 16),
        dropdownColor: Colors.white,
        validator: validator,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Date selector widget
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final datePick = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (datePick != null && datePick != birthDate) {
          setState(() {
            birthDate = datePick;
            isDateSelected = true;
            birthDateInString = "${birthDate?.day}/${birthDate?.month}/${birthDate?.year}";
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isDateSelected ? birthDateInString! : "Birth Date",
                style: TextStyle(
                  fontSize: 16,
                  color: isDateSelected ? Colors.black87 : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Signup handler
  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        Map<String, dynamic> userData = {
          'phone_number': _controllerPhoneNumber.text,
          'first_name': _controllerFirstName.text,
          'middle_name': _controllerMiddleName.text,
          'last_name': _controllerLastName.text,
          'email': _controllerEmail.text,
          'address': _controllerAddress.text,
          'birth_date': birthDate.toString(),
          'blood_group': _selectedBloodGroup,
          'gender': _selectedGender,
        };

        bool success = await _authService.signUp(
          _controllerEmail.text,
          _controllerPassword.text,
          userData,
        );

        if (success) {
          // Animate success
          _animationController.forward().then((_) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login())
            );
          });
        } else {
          _showErrorMessage('Signup failed. Please try again.');
        }
      } catch (e) {
        print('Signup error: $e');
        _showErrorMessage('An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _focusNodeAddress.dispose();
    _focusNodeFirstName.dispose();
    _focusNodeMiddleName.dispose();
    _focusNodeLastName.dispose();
    _controllerPhoneNumber.dispose();
    _controllerAddress.dispose();
    _controllerFirstName.dispose();
    _controllerMiddleName.dispose();
    _controllerLastName.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConFirmPassword.dispose();
    super.dispose();
  }
}