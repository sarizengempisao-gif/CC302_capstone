import 'package:flutter/material.dart';

import '../models/index.dart';
import '../services/api_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/tip_tile.dart';

/// Screen that demonstrates the API integration (requirement 7) and the
/// loading / error / empty states (requirement 11).
///
/// On first visit it automatically fetches tips from a free public quotes API.
/// While offline it falls back to cached or seeded tips and clearly labels them
/// as offline so there is never a crash and always something to read.
class TipsScreen extends StatefulWidget {
  /// The data source. In production this is [TipService.instance]; tests can
  /// inject a fake implementation to exercise every UI state deterministically.
  final TipsRepository repository;

  TipsScreen({super.key, TipsRepository? repository}) : repository = repository ?? TipService.instance;

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

enum _TipsStatus { idle, loading, success, error }

class _TipsScreenState extends State<TipsScreen> {
  _TipsStatus _status = _TipsStatus.idle;
  List<Tip> _tips = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _status = _TipsStatus.loading;
      _errorMessage = '';
    });
    try {
      final tips = await widget.repository.fetchTips();
      setState(() {
        _tips = tips;
        _status = _TipsStatus.success;
      });
    } on TipException catch (e) {
      final fallback = await widget.repository.fallbackTips();
      setState(() {
        _tips = fallback;
        _errorMessage = e.message;
        _status = _TipsStatus.error;
      });
    } catch (e) {
      final fallback = await widget.repository.fallbackTips();
      setState(() {
        _tips = fallback;
        _errorMessage = 'Could not load tips.';
        _status = _TipsStatus.error;
      });
    }
  }

  bool get _showingOffline => _status == _TipsStatus.error;

  @override
  Widget build(BuildContext context) {
    final bool listEmpty = _tips.isEmpty && _status != _TipsStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Tips'),
        actions: [
          if (_showingOffline)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Tooltip(
                  message: 'Showing saved tips — you are offline',
                  child: Icon(Icons.wifi_off_rounded, color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (_status == _TipsStatus.loading) return const LoadingState(label: 'Fetching tips...');
          if (listEmpty) {
            return EmptyState(title: 'No tips yet', subtitle: 'Pull to refresh or come back later.', action: _buildLoadMore());
          }
          // Success OR error-with-fallback-titles: show the list, plus an error
          // banner when the live API was unreachable.
          return Column(
            children: [
              if (_showingOffline) ErrorState(message: _errorMessage, onRetry: _load),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: _tips.length,
                  itemBuilder: (context, index) => TipTile(tip: _tips[index], isOffline: _showingOffline),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _status == _TipsStatus.loading ? null : FloatingActionButton.extended(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
    );
  }

  Widget _buildLoadMore() => FilledButton.icon(onPressed: _load, icon: const Icon(Icons.download), label: const Text('Load tips'));
}
