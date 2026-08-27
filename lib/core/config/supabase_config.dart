/// Supabase project credentials.
///
/// Fill these in after creating your Supabase project (see
/// `supabase/schema.sql` for the required tables/policies, and the README
/// for step-by-step setup). These are safe to ship in the client: the
/// anon key only works within the Row Level Security policies defined in
/// the schema, so a user can only ever read/write their own history.
///
/// You can also override these at build time instead of editing this file:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=xxxx
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT-REF.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_bCiQBTtzzq8uOJO-MBVZ1A_JFNwarnj',
  );

  static bool get isConfigured =>
      url.contains('supabase.co') &&
      !url.contains('YOUR-PROJECT-REF') &&
      anonKey.isNotEmpty &&
      anonKey != 'YOUR-SUPABASE-ANON-KEY';

  /// Table storing every completed scan/summary for the signed-in
  /// (anonymous) user.
  static const String scanSessionsTable = 'scan_sessions';
}
