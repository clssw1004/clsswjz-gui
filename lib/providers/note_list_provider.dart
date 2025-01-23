import 'dart:async';
import 'package:clsswjz/manager/user_config_manager.dart';
import 'package:flutter/material.dart';
import '../models/vo/user_note_vo.dart';
import '../manager/app_config_manager.dart';
import '../drivers/driver_factory.dart';
import '../events/event_book.dart';
import '../events/event_bus.dart';
import '../events/event_sync.dart';

class NoteListProvider extends ChangeNotifier {
  late final StreamSubscription _subscription;
  late final StreamSubscription _syncSubscription;

  final List<UserNoteVO> _notes = [];
  bool _loading = false;
  String? _currentBookId;

  List<UserNoteVO> get notes => _notes;
  bool get loading => _loading;

  NoteListProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;
    _subscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadNotes();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) async {
      loadNotes();
    });
  }

  Future<void> loadNotes() async {
    if (_loading) return;
    _loading = true;

    try {
      final result = await DriverFactory.driver.listNotesByBook(UserConfigManager.currentUserId!, _currentBookId!);
      _notes.clear();
      if (result.ok && result.data != null) {
        _notes.addAll(result.data!);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }
}
