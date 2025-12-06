import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Api/Kitsu/KitsuApi.dart';
import '../Api/Kitsu/KitsuData.dart';
import '../DataClass/Media.dart';
import '../Services/BridgeSyncService.dart';
import 'CustomBottomDialog.dart';

/// Dialog for manually linking a source media to an external tracker (Kitsu).
/// 
/// Two-step flow:
/// 1. Search for the target media on Kitsu
/// 2. Configure the episode/chapter offset
class ManualLinkDialog extends StatefulWidget {
  final Media sourceMedia;

  const ManualLinkDialog({
    required this.sourceMedia,
    super.key,
  });

  @override
  State<ManualLinkDialog> createState() => _ManualLinkDialogState();
}

class _ManualLinkDialogState extends State<ManualLinkDialog> {
  int _step = 0; // 0 = search, 1 = offset config
  
  // Search state
  final _searchController = TextEditingController();
  final _searchResults = <KitsuMedia>[].obs;
  final _isSearching = false.obs;
  KitsuMedia? _selectedMedia;

  // Offset state
  final _sourceEpController = TextEditingController(text: '1');
  final _targetEpController = TextEditingController(text: '1');
  final _offsetsMatch = true.obs;

  @override
  void dispose() {
    _searchController.dispose();
    _sourceEpController.dispose();
    _targetEpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return CustomBottomDialog(
      title: _step == 0 ? 'Link to Kitsu' : 'Configure Offset',
      viewList: [
        if (_step == 0) _buildSearchStep(theme),
        if (_step == 1) _buildOffsetStep(theme),
      ],
      positiveText: _step == 0 ? 'Next' : 'Link',
      positiveCallback: _step == 0 ? _goToOffsetStep : _saveLink,
      negativeText: _step == 0 ? null : 'Back',
      negativeCallback: _step == 0 ? null : () => setState(() => _step = 0),
    );
  }

  Widget _buildSearchStep(ColorScheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Login status
          if (!Kitsu.isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: theme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please login to Kitsu first',
                      style: TextStyle(color: theme.onErrorContainer),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Kitsu.login(context),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Kitsu',
              hintText: widget.sourceMedia.name ?? widget.sourceMedia.nameRomaji,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => _isSearching.value
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    )),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          // Search results
          Obx(() => _searchResults.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select target:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_searchResults.take(5).map((media) => _buildSearchResult(media, theme))),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildSearchResult(KitsuMedia media, ColorScheme theme) {
    final isSelected = _selectedMedia?.id == media.id;

    return InkWell(
      onTap: () => setState(() => _selectedMedia = media),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryContainer : theme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Poster
            if (media.posterUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  media.posterUrl!,
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 60,
                    color: theme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie),
              ),
            const SizedBox(width: 12),
            // Title and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.onPrimaryContainer : theme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sourceMedia.anime != null
                        ? '${media.episodeCount ?? '?'} episodes'
                        : '${media.chapterCount ?? '?'} chapters',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? theme.onPrimaryContainer.withOpacity(0.7)
                          : theme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildOffsetStep(ColorScheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected media display
          if (_selectedMedia != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: theme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedMedia!.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Offset question
          Text(
            'Do the episode/chapter numbers match?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Yes/No buttons
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      'Yes, they match',
                      _offsetsMatch.value,
                      () => _offsetsMatch.value = true,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton(
                      'No, different',
                      !_offsetsMatch.value,
                      () => _offsetsMatch.value = false,
                      theme,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          // Offset input (shown when "No")
          Obx(() => !_offsetsMatch.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Map the episode/chapter numbers:',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _sourceEpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Source',
                              hintText: 'e.g. 98',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '=',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _targetEpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Kitsu',
                              hintText: 'e.g. 1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Example: If Episode 98 on AniList = Episode 1 on Kitsu',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryContainer : theme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? theme.onPrimaryContainer : theme.onSurface,
          ),
        ),
      ),
    );
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      // Use source media name as default
      _searchController.text =
          widget.sourceMedia.name ?? widget.sourceMedia.nameRomaji;
      return;
    }

    _isSearching.value = true;
    _searchResults.clear();

    final isAnime = widget.sourceMedia.anime != null;
    final results = await Kitsu.searchMedia(query, isAnime: isAnime);

    _searchResults.addAll(results);
    _isSearching.value = false;
  }

  void _goToOffsetStep() {
    if (_selectedMedia == null) {
      // Show snackbar or highlight that selection is needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target first')),
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _saveLink() async {
    if (_selectedMedia == null) return;

    // Calculate offset
    int offset = 0;
    if (!_offsetsMatch.value) {
      final sourceEp = int.tryParse(_sourceEpController.text) ?? 1;
      final targetEp = int.tryParse(_targetEpController.text) ?? 1;
      offset = BridgeSyncService.instance.calculateOffset(sourceEp, targetEp);
    }

    // Save the link
    await BridgeSyncService.instance.addLinkedTarget(
      sourceTracker: 'anilist', // Assuming AniList as source
      sourceId: widget.sourceMedia.id,
      mediaType: widget.sourceMedia.anime != null ? 'anime' : 'manga',
      targetTracker: 'kitsu',
      targetId: _selectedMedia!.id,
      offset: offset,
      targetTitle: _selectedMedia!.title,
    );

    // Show confirmation BEFORE closing dialog (context is still valid)
    final message = 'Linked to ${_selectedMedia!.title}${offset != 0 ? ' (offset: $offset)' : ''}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // Close dialog AFTER showing snackbar
    Get.back();
  }
}

/// Show the manual link dialog
void showManualLinkDialog(BuildContext context, Media media) {
  showCustomBottomDialog(context, ManualLinkDialog(sourceMedia: media));
}
