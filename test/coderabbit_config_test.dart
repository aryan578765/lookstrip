import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String config;

  setUpAll(() {
    config = File('.coderabbit.yaml').readAsStringSync();
  });

  group('.coderabbit.yaml', () {
    test('file is non-empty', () {
      expect(config.trim(), isNotEmpty);
    });

    group('reviews', () {
      test('contains reviews section', () {
        expect(config, contains('reviews:'));
      });

      test('auto_review is enabled', () {
        expect(config, contains('auto_review:'));
        expect(config, contains('enabled: true'));
      });

      test('auto_review is not disabled', () {
        expect(config, isNot(contains('enabled: false')));
      });

      test('contains path_filters section', () {
        expect(config, contains('path_filters:'));
      });

      test('path_filters includes lib/**', () {
        expect(config, contains('"lib/**"'));
      });

      test('path_filters includes test/**', () {
        expect(config, contains('"test/**"'));
      });

      test('path_filters includes supabase/**', () {
        expect(config, contains('"supabase/**"'));
      });

      test('path_filters contains exactly three entries', () {
        final filterMatches =
            RegExp(r'- ".*?\*\*"').allMatches(config).toList();
        expect(filterMatches, hasLength(3));
      });

      test('profile is assertive', () {
        expect(config, contains('profile: "assertive"'));
      });

      test('profile is not a lenient preset', () {
        expect(config, isNot(contains('profile: "chill"')));
        expect(config, isNot(contains('profile: "default"')));
      });
    });

    group('chat', () {
      test('contains chat section', () {
        expect(config, contains('chat:'));
      });

      test('auto_reply is enabled', () {
        expect(config, contains('auto_reply: true'));
      });

      test('auto_reply is not disabled', () {
        expect(config, isNot(contains('auto_reply: false')));
      });
    });

    group('overall structure', () {
      test('top-level keys are reviews and chat', () {
        // Both required top-level sections must be present.
        expect(config, contains('reviews:'));
        expect(config, contains('chat:'));
      });

      test('does not reference unexpected top-level keys', () {
        // Guard against accidental stray keys that could be misconfiguration.
        expect(config, isNot(contains('pulls:')));
        expect(config, isNot(contains('issues:')));
      });
    });
  });
}
