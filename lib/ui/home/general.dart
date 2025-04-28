import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class General extends StatefulWidget {
  const General({super.key});

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  final List<Map<String, dynamic>> _faqs = [
    {
      "question": "Can I donate blood?",
      "answer": "To be eligible to donate blood, you must meet the following requirements:\n\n• Be between 18-65 years old\n• Weigh at least 50kg\n• Be in good health\n• Have hemoglobin levels of at least 12.5g/dL for women and 13.5g/dL for men\n• Not have donated blood in the last 3 months"
    },
    {
      "question": "Can I donate if I have a tattoo or piercing?",
      "answer": "Yes, 4 months after the tattoo or piercing completely heals."
    },
    {
      "question": "How long does it take to donate blood?",
      "answer": "The whole process takes about 30 minutes."
    },
    {
      "question": "How often can I donate blood?",
      "answer": "You can donate blood every 3 months."
    },
    {
      "question": "What should I bring to the donation?",
      "answer": "You must bring a valid ID card (Citizenship, Passport, Driving License, etc.)"
    },
  ];

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to launch Google search
  Future<void> _launchGoogleSearch(String query) async {
    final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent("blood donation $query")}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch search')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "General Information",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),

        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          FadeIn(
            duration: const Duration(milliseconds: 500),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeaderSection(),
                  _buildSearchBar(),
                  _buildFaqSection(),
                  _buildInfoCards(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Learn about blood donation",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Find answers to common questions and learn how you can help save lives.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search FAQs...',
          prefixIcon: const Icon(Icons.search, color: Colors.red),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    var filteredFaqs = _searchQuery.isEmpty
        ? _faqs
        : _faqs.where((faq) =>
    faq["question"].toLowerCase().contains(_searchQuery) ||
        faq["answer"].toLowerCase().contains(_searchQuery)).toList();

    if (filteredFaqs.isEmpty && _searchQuery.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "Search Results",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 2, color: Colors.red),
            const SizedBox(height: 16),

            // Google search suggestion card
            Card(
              elevation: 2,
              shadowColor: Colors.blue.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Google Search",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No results found for \"$_searchQuery\"",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We couldn't find any matching FAQs in our database. Would you like to search Google for information about blood donation related to your query?",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _launchGoogleSearch(_searchQuery),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(
                            "Search on Google",
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Try different keywords or use Google search for more information.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Frequently Asked Questions",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2, color: Colors.red),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredFaqs.length,
            itemBuilder: (context, index) {
              return _faqCard(
                filteredFaqs[index]["question"],
                filteredFaqs[index]["answer"],
                index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _faqCard(String question, String answer, int index) {
    return SlideInUp(
      delay: Duration(milliseconds: 100 * index),
      duration: const Duration(milliseconds: 400),
      from: 50,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.red.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.bloodtype, color: Colors.red[700]),
              ),
            ),
            title: Text(
              question,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            children: [
              Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Blood Donation Facts",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2, color: Colors.red),
          const SizedBox(height: 16),
          _infoCard(
            "One donation can save up to three lives",
            Icons.volunteer_activism,
            Colors.green,
          ),
          _infoCard(
            "Blood cannot be manufactured; it can only come from donors",
            Icons.science,
            Colors.purple,
          ),
          _infoCard(
            "Most donated red blood cells must be used within 42 days",
            Icons.timer,
            Colors.orange,
          ),
          _infoCard(
            "Type O- blood can be transfused to patients of all blood types",
            Icons.local_hospital,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String text, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}