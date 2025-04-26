
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_app.dart';


const supabaseUrl = 'https://xnvqeqirpztsprdiydfs.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhudnFlcWlycHp0c3ByZGl5ZGZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0NTQ0MzMsImV4cCI6MjA1NjAzMDQzM30.BNhdtVndoiRPnp6yyUJemjqKe-3GlR6o-h24EBHD4zg';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  await _initHive();
  runApp(const MainApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox("login");

}
