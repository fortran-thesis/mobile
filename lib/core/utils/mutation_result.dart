import 'package:flutter/material.dart';

class MutationTags {
  static const String moldReport = 'mold_report';
  static const String moldCase = 'mold_case';
  static const String userProfile = 'user_profile';
  static const String notification = 'notification';
}

class MutationResult {
  static const String _markerKey = '_mutationResult';
  static const String _changedKey = 'changed';
  static const String _tagsKey = 'tags';

  final bool changed;
  final List<String> tags;

  const MutationResult({required this.changed, this.tags = const []});

  const MutationResult.changed({List<String> tags = const []})
    : this(changed: true, tags: tags);

  const MutationResult.unchanged() : this(changed: false);

  Map<String, dynamic> toMap() => {
    _markerKey: true,
    _changedKey: changed,
    _tagsKey: tags,
  };

  bool hasTag(String tag) => tags.contains(tag);

  static MutationResult fromAny(dynamic value) {
    if (value is MutationResult) return value;
    if (value is bool) {
      return value ? const MutationResult.changed() : const MutationResult.unchanged();
    }

    if (value is Map) {
      final map = value.map(
        (key, val) => MapEntry(key.toString(), val),
      );

      final marker = map[_markerKey] == true;
      final changed = map[_changedKey] == true;
      final tagsRaw = map[_tagsKey];
      final tags = tagsRaw is List
          ? tagsRaw.map((e) => e.toString()).toList()
          : const <String>[];

      if (marker || map.containsKey(_changedKey) || map.containsKey(_tagsKey)) {
        return MutationResult(changed: changed, tags: tags);
      }
    }

    return const MutationResult.unchanged();
  }
}

Future<MutationResult> pushNamedForMutationResult(
  BuildContext context,
  String routeName, {
  Object? arguments,
}) async {
  final result = await Navigator.pushNamed(
    context,
    routeName,
    arguments: arguments,
  );
  return MutationResult.fromAny(result);
}