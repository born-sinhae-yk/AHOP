import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../services/rhwp_service.dart';
import '../services/document_service.dart';
import '../utils/app_theme.dart';

class EditorScreen extends StatefulWidget {
  final DocumentModel document;

  const EditorScreen({super.key, required this.document});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMsg = '';
  final DocumentService _docService = DocumentService();

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // 파일 Base64 인코딩
    String? fileBase64;
    if (!kIsWeb && File(widget.document.path).existsSync()) {
      fileBase64 = await _docService.encodeFileToBase64(widget.document.path);
    }

    final html = RhwpService.buildEditorHtml(
      fileBase64: fileBase64,
      fileName: widget.document.name,
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (error) {
          setState(() {
            _hasError = true;
            _errorMsg = error.description;
          });
        },
      ))
      ..addJavaScriptChannel(
        'HwpSuiteChannel',
        onMessageReceived: (msg) => _handleMessage(msg.message),
      )
      ..loadHtmlString(html, baseUrl: 'https://edwardkim.github.io');

    setState(() {});
  }

  void _handleMessage(String message) {
    if (kDebugMode) debugPrint('rhwp 메시지: $message');
    try {
      if (message.contains('"event":"share"')) {
        _shareDocument();
      } else if (message.contains('"event":"editorReady"')) {
        // editor ready
      } else if (message.contains('"event":"exportPdf"')) {
        _showPdfExportDialog();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('메시지 처리 오류: $e');
    }
  }

  Future<void> _shareDocument() async {
    if (!kIsWeb && File(widget.document.path).existsSync()) {
      await Share.shareXFiles(
        [XFile(widget.document.path)],
        text: 'HWP Suite로 공유: ${widget.document.name}',
      );
    }
  }

  void _showPdfExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('PDF 내보내기'),
        content: const Text('rhwp 에디터의 PDF 내보내기 기능을 사용하세요.\n에디터 상단 도구 모음의 "PDF" 버튼을 탭하면 됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                title: const Text('PDF로 내보내기'),
                subtitle: const Text('rhwp 내장 기능 사용'),
                onTap: () {
                  Navigator.pop(ctx);
                  _controller.runJavaScript('exportPdf()');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: AppTheme.primary),
                title: const Text('파일 공유'),
                onTap: () {
                  Navigator.pop(ctx);
                  _shareDocument();
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
                title: const Text('에디터 새로고침'),
                onTap: () {
                  Navigator.pop(ctx);
                  _initWebView();
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser_rounded, color: AppTheme.primary),
                title: const Text('rhwp 웹 버전으로 열기'),
                subtitle: const Text('브라우저에서 열기'),
                onTap: () {
                  Navigator.pop(ctx);
                  _controller.loadRequest(Uri.parse('https://edwardkim.github.io/rhwp/'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.document.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.document.typeLabel,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Provider.of<DocumentProvider>(context, listen: false).loadDocuments();
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<DocumentProvider>(
            builder: (ctx, provider, _) {
              final isFav = provider.currentDocument?.isFavorite ?? widget.document.isFavorite;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFav ? AppTheme.favoriteColor : Colors.white,
                ),
                onPressed: () {
                  provider.toggleFavorite(widget.document);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text('에디터 로딩 중...', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('에디터 로드 실패', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(_errorMsg, style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () { setState(() { _hasError = false; }); _initWebView(); },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('다시 시도'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
