import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String config;

  setUpAll(() {
    config = File('.coderabbit.yaml').readAsStringSync();
  });

  group('.coderabbit.yaml – file existence and structure', () {
    test('file exists and is non-empty', () {
      final file = File('.coderabbit.yaml');
      expect(file.existsSync(), isTrue);
      expect(config.trim(), isNotEmpty);
    });

    test('contains top-level reviews key', () {
      expect(config, contains('reviews:'));
    });

    test('contains top-level chat key', () {
      expect(config, contains('chat:'));
    });
  });

  group('.coderabbit.yaml – auto_review settings', () {
    test('auto_review block is present', () {
      expect(config, contains('auto_review:'));
    });

    test('auto_review is enabled', () {
      expect(config, contains('enabled: true'));
    });

    test('auto_review is not explicitly disabled', () {
      expect(config, isNot(contains('enabled: false')));
    });
  });

  group('.coderabbit.yaml – path_filters', () {
    test('path_filters block is present', () {
      expect(config, contains('path_filters:'));
    });

    test('lib/** is included in path filters', () {
      expect(config, contains('"lib/**"'));
    });

    test('test/** is included in path filters', () {
      expect(config, contains('"test/**"'));
    });

    test('supabase/** is included in path filters', () {
      expect(config, contains('"supabase/**"'));
    });

    test('all three expected path filters are present', () {
      final filters = ['"lib/**"', '"test/**"', '"supabase/**"'];
      for (final filter in filters) {
        expect(config, contains(filter),
            reason: 'Expected path filter $filter to be present');
      }
    });

    test('does not filter out unexpected top-level paths accidentally', () {
      // Boundary: ensure no blanket wildcard "**" replaces specific paths
      // The config should use specific directory filters, not a single "**"
      final lines = config.split('\n');
      final filterLines =
          lines.where((l) => l.trim() == '- "**"').toList();
      expect(filterLines, isEmpty,
          reason: 'A bare "**" filter would override all specific filters');
    });
  });

  group('.coderabbit.yaml – review profile', () {
    test('profile key is present', () {
      expect(config, contains('profile:'));
    });

    test('profile is set to assertive', () {
      expect(config, contains('profile: "assertive"'));
    });

    test('profile is not set to a lenient value', () {
      expect(config, isNot(contains('profile: "chill"')));
    });
  });

  group('.coderabbit.yaml – chat settings', () {
    test('auto_reply key is present under chat', () {
      expect(config, contains('auto_reply:'));
    });

    test('auto_reply is enabled', () {
      expect(config, contains('auto_reply: true'));
    });

    test('auto_reply is not disabled', () {
      expect(config, isNot(contains('auto_reply: false')));
    });
  });

  group('.coderabbit.yaml – overall configuration integrity', () {
    test('config has expected number of top-level keys (reviews and chat)', () {
      // Both "reviews:" and "chat:" must appear exactly once
      final reviewsCount = 'reviews:'.allMatches(config).length;
      final chatCount = 'chat:'.allMatches(config).length;
      expect(reviewsCount, equals(1));
      expect(chatCount, equals(1));
    });

    test('config does not contain placeholder or example values', () {
      expect(config, isNot(contains('TODO')));
      expect(config, isNot(contains('FIXME')));
      expect(config, isNot(contains('your_value_here')));
    });

    test('config is valid YAML (no tab characters, which are invalid in YAML)',
        () {
      expect(config, isNot(contains('\t')),
          reason: 'YAML does not allow tab characters for indentation');
    });

    test('all expected keys and values are present together', () {
      expect(config, contains('auto_review:'));
      expect(config, contains('enabled: true'));
      expect(config, contains('path_filters:'));
      expect(config, contains('"lib/**"'));
      expect(config, contains('"test/**"'));
      expect(config, contains('"supabase/**"'));
      expect(config, contains('profile: "assertive"'));
      expect(config, contains('auto_reply: true'));
    });
  });
}
