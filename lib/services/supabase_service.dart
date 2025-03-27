import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_options.dart';

class SupabaseManager {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseCredentials.url,
      anonKey: SupabaseCredentials.anonKey,
      debug: kDebugMode,
    );
  }

  // Getter for Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}