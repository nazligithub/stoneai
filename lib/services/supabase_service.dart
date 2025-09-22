import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = 'https://ycsuzygpkwpriomnwqec.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljc3V6eWdwa3dwcmlvbW53cWVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyNTI3NDQsImV4cCI6MjA1NjgyODc0NH0.3eWjqrHS3yW00eblYUpDZ-yne5u8jm4MOrhy5yoY6S4';

  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: _url,
        anonKey: _anonKey,
        debug: false,
      );
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  }

  // Get Rock Identifier status from apps table
  Future<bool> getRockIdentifierStatus() async {
    try {
      final response = await client
          .from('apps')
          .select('status')
          .eq('name', 'Rock identifier')
          .single();

      return response['status'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error fetching rock identifier status: $e');
      return false; // Default to false if error
    }
  }

  // Listen to realtime changes for Rock Identifier status
  Stream<bool> watchRockIdentifierStatus() {
    return client
        .from('apps')
        .stream(primaryKey: ['name'])
        .eq('name', 'Rock identifier')
        .map((data) {
          if (data.isNotEmpty) {
            return data.first['status'] as bool? ?? false;
          }
          return false;
        });
  }

  // Get all apps data (for debugging)
  Future<List<Map<String, dynamic>>> getAllApps() async {
    try {
      final response = await client
          .from('apps')
          .select('*')
          .order('order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching all apps: $e');
      return [];
    }
  }
}