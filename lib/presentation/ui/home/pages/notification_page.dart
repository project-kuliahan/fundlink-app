import 'package:flutter/material.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/data/datasources/notification_remote_datasource.dart';
import 'package:fundlink_app/data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _remote = NotificationRemoteDatasource();
  final _scrollController = ScrollController();

  List<NotificationModel> _notifications = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _currentPage < _lastPage) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _notifications = [];
      _currentPage = 1;
    });
    try {
      final result = await _remote.getNotificationsPaged(page: 1);
      if (mounted) {
        setState(() {
          _notifications =
              result['notifications'] as List<NotificationModel>;
          _currentPage = result['current_page'] as int;
          _lastPage = result['last_page'] as int;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final result = await _remote.getNotificationsPaged(page: nextPage);
      if (mounted) {
        setState(() {
          _notifications.addAll(
            result['notifications'] as List<NotificationModel>,
          );
          _currentPage = result['current_page'] as int;
          _lastPage = result['last_page'] as int;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingMore = false);
  }

  Future<void> _markAsRead(NotificationModel notif, int index) async {
    try {
      await _remote.markAsRead(notif.id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Daftar notifikasi terbaru',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey.withValues(alpha: 0.8),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada notifikasi',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount:
                            _notifications.length + (_loadingMore ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == _notifications.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final notif = _notifications[index];
                          return GestureDetector(
                            onTap: () => _markAsRead(notif, index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    alignment: Alignment.centerLeft,
                                    child: const TransactionTypeIcon(
                                      isIncome: true,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        Text(
                                          notif.message,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
