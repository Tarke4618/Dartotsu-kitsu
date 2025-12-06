import 'package:isar_community/isar.dart';

part 'TrackerMapping.g.dart';

/// Represents a mapping between a source tracker entry and target tracker entries
/// with offset support for split-entry scenarios.
/// 
/// Example: Chainsaw Man on AniList (1 entry) maps to Chainsaw Man Part 2 on Kitsu
/// with offset -97 (Source Chapter 98 → Target Chapter 1).
@collection
class TrackerMapping {
  Id id = Isar.autoIncrement;

  /// Unique key in format: "sourceTracker:sourceId" (e.g., "anilist:127230")
  @Index(unique: true, replace: true)
  late String key;

  /// Source tracker identifier: 'anilist', 'mal', 'kitsu', 'simkl'
  late String sourceTracker;

  /// Source media ID on the tracker
  late int sourceId;

  /// Media type: 'anime' or 'manga'
  late String mediaType;

  /// List of linked target entries with their offsets
  late List<MappingTarget> targets;

  TrackerMapping();

  /// Create a mapping from source info
  factory TrackerMapping.create({
    required String sourceTracker,
    required int sourceId,
    required String mediaType,
    List<MappingTarget>? targets,
  }) {
    return TrackerMapping()
      ..key = '$sourceTracker:$sourceId'
      ..sourceTracker = sourceTracker
      ..sourceId = sourceId
      ..mediaType = mediaType
      ..targets = targets ?? [];
  }

  /// Add a new target to this mapping
  void addTarget(MappingTarget target) {
    // Remove existing target for same tracker+id combo
    targets.removeWhere((t) =>
        t.targetTracker == target.targetTracker &&
        t.targetId == target.targetId);
    targets.add(target);
  }

  /// Remove a target by tracker and id
  void removeTarget(String tracker, String targetId) {
    targets.removeWhere(
        (t) => t.targetTracker == tracker && t.targetId == targetId);
  }
}

/// Embedded object representing a target tracker entry with offset
@embedded
class MappingTarget {
  /// Target tracker identifier: 'anilist', 'mal', 'kitsu', 'simkl'
  late String targetTracker;

  /// Target media ID (String for Kitsu compatibility)
  late String targetId;

  /// Offset to apply: TargetProgress = SourceProgress + offset
  /// Example: -97 means Source Ep 98 → Target Ep 1
  late int offset;

  /// Optional segment label (e.g., "Part 2", "Season 2")
  String? segment;

  /// Target media title for display
  String? targetTitle;

  MappingTarget();

  /// Create a target with calculated offset
  factory MappingTarget.create({
    required String targetTracker,
    required String targetId,
    required int offset,
    String? segment,
    String? targetTitle,
  }) {
    return MappingTarget()
      ..targetTracker = targetTracker
      ..targetId = targetId
      ..offset = offset
      ..segment = segment
      ..targetTitle = targetTitle;
  }

  /// Calculate offset from episode mapping
  /// Example: sourceEp=98, targetEp=1 → offset = 1 - 98 = -97
  static int calculateOffset(int sourceEp, int targetEp) {
    return targetEp - sourceEp;
  }

  /// Apply offset to source progress
  int applyOffset(int sourceProgress) {
    return sourceProgress + offset;
  }
}
