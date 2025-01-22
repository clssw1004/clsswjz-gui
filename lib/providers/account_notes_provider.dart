import 'package:flutter/material.dart';
import '../models/vo/user_note_vo.dart';
import '../manager/app_config_manager.dart';
import '../drivers/driver_factory.dart';

class AccountNotesProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  List<UserNoteVO> _notes = [];
  List<UserNoteVO> get notes => _notes;

  String? _error;
  String? get error => _error;

  AccountNotesProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listNotes(
        AppConfigManager.instance.userId!,
      );
      if (result.ok) {
        _notes = result.data ?? [];
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createNote(UserNoteVO note) async {
    _error = null;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.createNote(
        AppConfigManager.instance.userId!,
        note: note,
      );
      if (result.ok) {
        await loadNotes();
        return true;
      } else {
        _error = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(UserNoteVO note) async {
    _error = null;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.updateNote(
        AppConfigManager.instance.userId!,
        note: note,
      );
      if (result.ok) {
        await loadNotes();
        return true;
      } else {
        _error = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    _error = null;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.deleteNote(
        AppConfigManager.instance.userId!,
        noteId: noteId,
      );
      if (result.ok) {
        await loadNotes();
        return true;
      } else {
        _error = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
