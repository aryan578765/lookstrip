import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collaboration patch contains transactional sync RPC and RLS roles', () {
    final sql = File('supabase_collaboration_patch.sql').readAsStringSync();

    expect(sql, contains('sync_trip_with_itinerary'));
    expect(sql, contains("ARRAY['owner', 'editor']"));
    expect(sql, contains("ARRAY['owner', 'editor', 'viewer']"));
    expect(sql, contains('trip_collaborators'));
    expect(sql, contains('SECURITY INVOKER'));
  });
}
