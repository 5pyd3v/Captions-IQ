import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/history_item.dart';

/// Thin wrapper around the Supabase client: silent anonymous auth on
/// startup + CRUD for the scan history table. Every read/write is scoped
/// to the current device's anonymous user via Row Level Security
/// (see supabase/schema.sql) — this service never needs to filter by
/// user_id manually for reads because RLS already does it.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
    await ensureSignedIn();
  }

  static Future<void> ensureSignedIn() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }

  static String? get userId => _client.auth.currentUser?.id;

  static Future<HistoryItem> saveSession({
    required String title,
    required int imageCount,
    required String rawText,
    required String summaryEn,
    required String summaryRomanUr,
  }) async {
    final uid = userId;
    if (uid == null) {
      throw StateError('Not signed in to Supabase yet.');
    }
    final row = await _client
        .from(SupabaseConfig.scanSessionsTable)
        .insert({
          'user_id': uid,
          'title': title,
          'image_count': imageCount,
          'raw_text': rawText,
          'summary_en': summaryEn,
          'summary_roman_ur': summaryRomanUr,
        })
        .select()
        .single();
    return HistoryItem.fromMap(row);
  }

  static Future<List<HistoryItem>> fetchHistory() async {
    final rows = await _client
        .from(SupabaseConfig.scanSessionsTable)
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => HistoryItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> deleteSession(String id) async {
    await _client.from(SupabaseConfig.scanSessionsTable).delete().eq('id', id);
  }
}
