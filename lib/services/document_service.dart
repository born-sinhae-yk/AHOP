import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';

class DocumentService {
  static const String _recentKey = 'recent_documents';
  static const int maxRecent = 20;

  // 최근 문서 불러오기
  Future<List<DocumentModel>> getRecentDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentKey) ?? [];
    final docs = <DocumentModel>[];
    for (final json in jsonList) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final doc = DocumentModel.fromMap(map);
        if (File(doc.path).existsSync()) {
          docs.add(doc);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('문서 파싱 오류: $e');
      }
    }
    docs.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return docs;
  }

  // 즐겨찾기 문서 불러오기
  Future<List<DocumentModel>> getFavoriteDocuments() async {
    final all = await getRecentDocuments();
    return all.where((d) => d.isFavorite).toList();
  }

  // 문서 열기 기록 저장
  Future<void> addToRecent(DocumentModel doc) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentKey) ?? [];

    // 중복 제거
    jsonList.removeWhere((json) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return map['path'] == doc.path;
      } catch (_) {
        return false;
      }
    });

    // 맨 앞에 추가
    jsonList.insert(0, jsonEncode(doc.toMap()));

    // 최대 개수 제한
    if (jsonList.length > maxRecent) {
      jsonList.removeRange(maxRecent, jsonList.length);
    }

    await prefs.setStringList(_recentKey, jsonList);
  }

  // 즐겨찾기 토글
  Future<void> toggleFavorite(String docPath) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentKey) ?? [];
    final updated = <String>[];

    for (final json in jsonList) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        if (map['path'] == docPath) {
          map['isFavorite'] = !(map['isFavorite'] as bool? ?? false);
        }
        updated.add(jsonEncode(map));
      } catch (_) {
        updated.add(json);
      }
    }

    await prefs.setStringList(_recentKey, updated);
  }

  // 최근 문서에서 삭제
  Future<void> removeFromRecent(String docPath) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentKey) ?? [];
    jsonList.removeWhere((json) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return map['path'] == docPath;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_recentKey, jsonList);
  }

  // 모든 최근 문서 삭제
  Future<void> clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  // HWP/HWPX 파일인지 확인
  static bool isHwpFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ext == 'hwp' || ext == 'hwpx';
  }

  // 파일 존재 여부 확인
  static bool fileExists(String path) {
    return File(path).existsSync();
  }

  // 파일을 Base64로 인코딩 (WebView 전달용)
  Future<String?> encodeFileToBase64(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      if (kDebugMode) debugPrint('파일 인코딩 오류: $e');
      return null;
    }
  }
}
