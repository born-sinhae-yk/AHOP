import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';
import '../utils/app_theme.dart';
import 'editor_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: Consumer<DocumentProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final docs = provider.favoriteDocuments;

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDocuments(),
            color: AppTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final doc = docs[i];
                return DocumentCard(
                  document: doc,
                  onTap: () => _openDocument(context, provider, doc),
                  onFavoriteToggle: () => provider.toggleFavorite(doc),
                  onDelete: () => provider.removeFromRecent(doc),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openDocument(BuildContext context, DocumentProvider provider, DocumentModel doc) {
    provider.openDocument(doc);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(document: doc)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppTheme.favoriteColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_outline_rounded, size: 52, color: AppTheme.favoriteColor),
            ),
            const SizedBox(height: 24),
            const Text('즐겨찾기가 없습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            const Text('최근 문서에서 ★ 버튼을 눌러\n자주 쓰는 문서를 즐겨찾기에 추가하세요',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
