import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';
import '../utils/app_theme.dart';
import 'editor_screen.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentProvider>(context, listen: false).loadDocuments();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['hwp', 'hwpx'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    final file = File(path);
    final doc = DocumentModel.fromFile(file);

    if (!mounted) return;
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    await provider.openDocument(doc);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(document: doc)),
    );
  }

  void _openDocument(DocumentModel doc) {
    Provider.of<DocumentProvider>(context, listen: false).openDocument(doc);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(document: doc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '파일명 검색...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('최근 문서'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
          Consumer<DocumentProvider>(
            builder: (ctx, provider, _) {
              if (provider.recentDocuments.isEmpty) return const SizedBox();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (val) async {
                  if (val == 'clear') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('최근 문서 초기화'),
                        content: const Text('모든 최근 문서 기록을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await provider.clearRecent();
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'clear', child: Row(
                    children: [
                      Icon(Icons.clear_all_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('기록 초기화', style: TextStyle(color: Colors.red)),
                    ],
                  )),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final docs = provider.recentDocuments.where((d) =>
            _searchQuery.isEmpty || d.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          if (docs.isEmpty) {
            return _buildEmptyState(provider.recentDocuments.isEmpty);
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
                  onTap: () => _openDocument(doc),
                  onFavoriteToggle: () => provider.toggleFavorite(doc),
                  onDelete: () => provider.removeFromRecent(doc),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilePicker,
        icon: const Icon(Icons.add_rounded),
        label: const Text('HWP 열기'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(bool isAbsolutelyEmpty) {
    if (!isAbsolutelyEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('"$_searchQuery" 검색 결과 없음',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined, size: 50, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text('최근 문서가 없습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            const Text('HWP/HWPX 파일을 열어\n문서 작업을 시작하세요',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openFilePicker,
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('파일 열기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
