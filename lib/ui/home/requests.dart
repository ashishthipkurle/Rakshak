import 'package:flutter/material.dart';
import 'package:Rakshak/ui/widgets/all_requests.dart';
import 'package:Rakshak/ui/widgets/myrequest.dart';
import 'package:Rakshak/ui/widgets/requestblood.dart';
import 'package:Rakshak/ui/home/home.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(userId: '', isLoggedIn: true),
              ),
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Requests'),
            Tab(text: 'My Requests'),
            Tab(text: 'Request Blood'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Force refresh of the current tab
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Pull-to-refresh functionality
          setState(() {});
          return Future.value();
        },
        child: TabBarView(
          controller: _tabController,
          children: const [
            // Tab 1: All Requests
            AllRequests(),

            // Tab 2: My Requests
            MyRequests(),

            // Tab 3: Request Blood Form
            RequestBlood(),
          ],
        ),
      ),
    );
  }
}