import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';
import '../utils/app_theme.dart';
import 'editor_screen.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<FileSystemEntity> _entities = [];
  Directory? _currentDir;
  bool _isLoading = false;
  String _searchQuery = '';
  bool _showSearch = false;
  bool _showOnlyHwp = true;
  final TextEditingController _searchCtrl = TextEditingController();
  final List<Directory> _history = [];

  @override
  void initState() {
    super.initState();
    _initRootDir();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initRootDir() async {
    setState(() => _isLoading = true);
    try {
      Directory root;
      if (Platform.isAndroid) {
        // Android: 외부 저장소
        final dirs = await getExternalStorageDirectories();
        if (dirs != null && dirs.isNotEmpty) {
          // 최상위 외부 저장소
          final primary = dirs.first.path.split('Android').first;
          root = Directory(primary);
        } else {
          root = await getApplicationDocumentsDirectory();
        }
      } else {
        root = await getApplicationDocumentsDirectory();
      }
      _currentDir = root;
      await _loadDirectory(root);
    } catch (e) {
      final docs = await getApplicationDocumentsDirectory();
      _currentDir = docs;
      await _loadDirectory(docs);
    }
  }

  Future<void> _loadDirectory(Directory dir) async {
    setState(() => _isLoading = true);
    try {
      final entities = dir.listSync().where((e) {
        final name = e.path.split('/').last;
        if (name.startsWith('.')) return false;
        if (e is File) {
          if (_showOnlyHwp) {
            final ext = name.split('.').last.toLowerCase();
            return ext == 'hwp' || ext == 'hwpx';
          }
          return true;
        }
        return e is Directory;
      }).toList();

      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return a.path.split('/').last.compareTo(b.path.split('/').last);
      });

      setState(() {
        _entities = entities;
        _currentDir = dir;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDir(Directory dir) {
    _history.add(_currentDir!);
    _loadDirectory(dir);
  }

  bool _canGoBack() => _history.isNotEmpty;

  void _goBack() {
    if (_history.isEmpty) return;
    final prev = _history.removeLast();
    _loadDirectory(prev);
  }

  void _openHwpFile(File file) {
    final doc = DocumentModel.fromFile(file);
    Provider.of<DocumentProvider>(context, listen: false).openDocument(doc);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(document: doc)),
    );
  }

  Future<void> _pickFile() async {
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
    Provider.of<DocumentProvider>(context, listen: false).openDocument(doc);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(document: doc)),
    );
  }

  List<FileSystemEntity> get _filteredEntities {
    if (_searchQuery.isEmpty) return _entities;
    return _entities.where((e) {
      final name = e.path.split('/').last.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String get _currentDirName {
    if (_currentDir == null) return '파일';
    final parts = _currentDir!.path.split('/');
    return parts.last.isEmpty ? '/' : parts.last;
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
            : Text(_currentDirName),
        leading: _canGoBack()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _goBack,
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) { _searchQuery = ''; _searchCtrl.clear(); }
            }),
          ),
          IconButton(
            icon: Icon(_showOnlyHwp ? Icons.filter_alt_rounded : Icons.filter_alt_off_rounded),
            tooltip: _showOnlyHwp ? 'HWP만 표시' : '모든 파일 표시',
            onPressed: () {
              setState(() => _showOnlyHwp = !_showOnlyHwp);
              if (_currentDir != null) _loadDirectory(_currentDir!);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 경로 표시
          if (_currentDir != null)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentDir!.path,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _buildFileList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        tooltip: 'HWP 파일 선택',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildFileList() {
    final items = _filteredEntities;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _showOnlyHwp ? 'HWP/HWPX 파일이 없습니다' : '파일이 없습니다',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (_showOnlyHwp) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () { setState(() => _showOnlyHwp = false); if (_currentDir != null) _loadDirectory(_currentDir!); },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('모든 파일 보기'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async { if (_currentDir != null) await _loadDirectory(_currentDir!); },
      color: AppTheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (ctx, i) {
          final entity = items[i];
          if (entity is Directory) {
            return _buildDirTile(entity);
          } else if (entity is File) {
            if (DocumentService.isHwpFile(entity.path)) {
              final doc = DocumentModel.fromFile(entity);
              return DocumentCard(
                document: doc,
                onTap: () => _openHwpFile(entity),
                onFavoriteToggle: () {},
                showPath: false,
              );
            }
            return _buildFileTile(entity);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDirTile(Directory dir) {
    final name = dir.path.split('/').last;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.folder_rounded, color: Color(0xFFFFA000), size: 36),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
        onTap: () => _navigateToDir(dir),
        dense: true,
      ),
    );
  }

  Widget _buildFileTile(File file) {
    final name = file.path.split('/').last;
    final ext = name.contains('.') ? name.split('.').last.toUpperCase() : '';
    return Card(
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.insert_drive_file_rounded, color: Colors.grey, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontSize: 13)),
        subtitle: Text(ext, style: const TextStyle(fontSize: 11)),
        dense: true,
      ),
    );
  }
}

// 파일 서비스 (로컬 참조용)
class DocumentService {
  static bool isHwpFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ext == 'hwp' || ext == 'hwpx';
  }
}
