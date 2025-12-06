import '../Functions/Function.dart';
import '../Preferences/IsarDataClasses/TrackerMapping/TrackerMapping.dart';
import '../logger.dart';
import 'TrackerMappingRepository.dart';

/// Service for synchronizing progress across linked trackers.
/// 
/// This service intercepts progress updates and propagates them to
/// linked target trackers with appropriate offset calculations.
class BridgeSyncService {
  static final BridgeSyncService _instance = BridgeSyncService._();
  static BridgeSyncService get instance => _instance;
  BridgeSyncService._();

  final TrackerMappingRepository _repository = TrackerMappingRepository.instance;

  /// Map of tracker names to their update functions
  final Map<String, Future<void> Function(String targetId, int progress, String mediaType)>
      _trackerUpdaters = {};

  /// Register a tracker's update function
  void registerTracker(
    String trackerName,
    Future<void> Function(String targetId, int progress, String mediaType) updater,
  ) {
    _trackerUpdaters[trackerName] = updater;
    Logger.log('BridgeSyncService: Registered tracker $trackerName');
  }

  /// Called after a successful progress update on the source tracker.
  /// Syncs to all linked targets in the background.
  Future<void> syncProgress({
    required String sourceTracker,
    required int sourceId,
    required int newProgress,
    required String mediaType,
  }) async {
    try {
      final mapping = await _repository.getMapping(sourceTracker, sourceId);
      if (mapping == null || mapping.targets.isEmpty) {
        return; // No linked targets
      }

      Logger.log(
        'BridgeSyncService: Syncing progress from $sourceTracker:$sourceId '
        '(progress: $newProgress) to ${mapping.targets.length} target(s)',
      );

      for (final target in mapping.targets) {
        await _syncToTarget(
          target: target,
          sourceProgress: newProgress,
          mediaType: mediaType,
        );
      }
    } catch (e) {
      Logger.log('BridgeSyncService: Error syncing progress: $e');
    }
  }

  Future<void> _syncToTarget({
    required MappingTarget target,
    required int sourceProgress,
    required String mediaType,
  }) async {
    // Calculate target progress using offset
    final targetProgress = target.applyOffset(sourceProgress);

    // Skip if negative progress (hasn't reached this part yet)
    if (targetProgress < 0) {
      Logger.log(
        'BridgeSyncService: Skipping ${target.targetTracker}:${target.targetId} '
        '(calculated progress $targetProgress < 0)',
      );
      return;
    }

    // Skip if updater not registered for this tracker
    final updater = _trackerUpdaters[target.targetTracker];
    if (updater == null) {
      Logger.log(
        'BridgeSyncService: No updater registered for ${target.targetTracker}',
      );
      return;
    }

    try {
      await updater(target.targetId, targetProgress, mediaType);
      
      snackString(
        'Synced to ${target.targetTracker}: Progress $targetProgress',
      );
      
      Logger.log(
        'BridgeSyncService: Updated ${target.targetTracker}:${target.targetId} '
        'to progress $targetProgress',
      );
    } catch (e) {
      Logger.log(
        'BridgeSyncService: Failed to update ${target.targetTracker}: $e',
      );
    }
  }

  /// Calculate offset from a user-provided episode mapping.
  /// 
  /// Example: User says "Source Ep 98 = Target Ep 1"
  /// Result: offset = 1 - 98 = -97
  /// 
  /// When applied: Source Ep 100 + offset(-97) = Target Ep 3
  int calculateOffset(int sourceEp, int targetEp) {
    return MappingTarget.calculateOffset(sourceEp, targetEp);
  }

  /// Check if a source has any linked targets
  Future<bool> hasLinkedTargets(String sourceTracker, int sourceId) async {
    return await _repository.hasMapping(sourceTracker, sourceId);
  }

  /// Get linked targets for display in UI
  Future<List<MappingTarget>> getLinkedTargets(
    String sourceTracker,
    int sourceId,
  ) async {
    final mapping = await _repository.getMapping(sourceTracker, sourceId);
    return mapping?.targets ?? [];
  }

  /// Add a new linked target
  Future<void> addLinkedTarget({
    required String sourceTracker,
    required int sourceId,
    required String mediaType,
    required String targetTracker,
    required String targetId,
    required int offset,
    String? segment,
    String? targetTitle,
  }) async {
    final target = MappingTarget.create(
      targetTracker: targetTracker,
      targetId: targetId,
      offset: offset,
      segment: segment,
      targetTitle: targetTitle,
    );

    await _repository.addTarget(
      sourceTracker: sourceTracker,
      sourceId: sourceId,
      mediaType: mediaType,
      target: target,
    );
  }

  /// Remove a linked target
  Future<void> removeLinkedTarget({
    required String sourceTracker,
    required int sourceId,
    required String targetTracker,
    required String targetId,
  }) async {
    await _repository.removeTarget(
      sourceTracker: sourceTracker,
      sourceId: sourceId,
      targetTracker: targetTracker,
      targetId: targetId,
    );
  }
}
