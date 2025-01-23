import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/user_note_vo.dart';
import '../../providers/note_list_provider.dart';
import '../../manager/l10n_manager.dart';
import 'note_tile.dart';

class NoteList extends StatelessWidget {
  const NoteList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<NoteListProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return Center(
            child: Text(L10nManager.l10n.loading),
          );
        }

        if (provider.notes.isEmpty) {
          return ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无笔记',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: provider.notes.length,
          itemBuilder: (context, index) {
            final note = provider.notes[index];
            return NoteTile(
              note: note,
              index: index,
            );
          },
        );
      },
    );
  }
}
