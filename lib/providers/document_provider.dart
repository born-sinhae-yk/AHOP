import 'package:flutter/foundation.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _service = DocumentService();

  List<DocumentModel> _recentDocuments = [];
  List<DocumentModel> _favoriteDocuments = [];
  bool _isLoading = false;
  String? _error;
  DocumentModel? _currentDocument;

  List<DocumentModel> get recentDocuments => _recentDocuments;
  List<DocumentModel> get favoriteDocuments => _favoriteDocuments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DocumentModel? get currentDocument => _currentDocument;

  Future<void> loadDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recentDocuments = await _service.getRecentDocuments();
      _favoriteDocuments = await _service.getFavoriteDocuments();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('문서 로드 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openDocument(DocumentModel doc) async {
    _currentDocument = doc;
    await _service.addToRecent(doc.copyWith(lastOpened: DateTime.now()));
    await loadDocuments();
    notifyListeners();
  }

  Future<void> toggleFavorite(DocumentModel doc) async {
    await _service.toggleFavorite(doc.path);
    await loadDocuments();
  }

  Future<void> removeFromRecent(DocumentModel doc) async {
    await _service.removeFromRecent(doc.path);
    await loadDocuments();
  }

  Future<void> clearRecent() async {
    await _service.clearRecent();
    await loadDocuments();
  }

  void setCurrentDocument(DocumentModel? doc) {
    _currentDocument = doc;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
