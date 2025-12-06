import 'package:isar_community/isar.dart';

import '../Preferences/IsarDataClasses/TrackerMapping/TrackerMapping.dart';
import '../Preferences/PrefManager.dart';
import '../logger.dart';

/// Repository for managing tracker mappings in the Isar database.
class TrackerMappingRepository {
  static final TrackerMappingRepository _instance =
      TrackerMappingRepository._();
  static TrackerMappingRepository get instance => _instance;
  TrackerMappingRepository._();

  Isar get _isar => PrefManager.dartotsuPreferences;

  /// Get a mapping by source tracker and source ID
  Future<TrackerMapping?> getMapping(String sourceTracker, int sourceId) async {
    final key = '$sourceTracker:$sourceId';
    return await _isar.trackerMappings.getByKey(key);
  }

  /// Get mapping synchronously
  TrackerMapping? getMappingSync(String sourceTracker, int sourceId) {
    final key = '$sourceTracker:$sourceId';
    return _isar.trackerMappings.getByKeySync(key);
  }

  /// Save or update a mapping
  Future<void> saveMapping(TrackerMapping mapping) async {
    await _isar.writeTxn(() async {
      await _isar.trackerMappings.put(mapping);
    });
    Logger.log('Saved mapping: ${mapping.key}');
  }

  /// Add a target to an existing mapping, or create new mapping if none exists
  Future<void> addTarget({
    required String sourceTracker,
    required int sourceId,
    required String mediaType,
    required MappingTarget target,
  }) async {
    var mapping = await getMapping(sourceTracker, sourceId);

    if (mapping == null) {
      mapping = TrackerMapping.create(
        sourceTracker: sourceTracker,
        sourceId: sourceId,
        mediaType: mediaType,
        targets: [target],
      );
    } else {
      mapping.addTarget(target);
    }

    await saveMapping(mapping);
  }

  /// Remove a target from a mapping
  Future<void> removeTarget({
    required String sourceTracker,
    required int sourceId,
    required String targetTracker,
    required String targetId,
  }) async {
    final mapping = await getMapping(sourceTracker, sourceId);
    if (mapping == null) return;

    mapping.removeTarget(targetTracker, targetId);

    if (mapping.targets.isEmpty) {
      await deleteMapping(sourceTracker, sourceId);
    } else {
      await saveMapping(mapping);
    }
  }

  /// Delete a mapping entirely
  Future<void> deleteMapping(String sourceTracker, int sourceId) async {
    final key = '$sourceTracker:$sourceId';
    await _isar.writeTxn(() async {
      await _isar.trackerMappings.deleteByKey(key);
    });
    Logger.log('Deleted mapping: $key');
  }

  /// Get all mappings (for debugging/admin purposes)
  Future<List<TrackerMapping>> getAllMappings() async {
    return await _isar.trackerMappings.where().findAll();
  }

  /// Check if a mapping exists
  Future<bool> hasMapping(String sourceTracker, int sourceId) async {
    final mapping = await getMapping(sourceTracker, sourceId);
    return mapping != null && mapping.targets.isNotEmpty;
  }
}
