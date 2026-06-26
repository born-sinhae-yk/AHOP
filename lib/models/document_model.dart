import 'dart:io';

enum DocumentType { hwp, hwpx, unknown }

class DocumentModel {
  final String id;
  final String name;
  final String path;
  final DocumentType type;
  final DateTime lastOpened;
  final DateTime? createdAt;
  final int fileSize;
  bool isFavorite;
  String? thumbnailPath;

  DocumentModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.lastOpened,
    this.createdAt,
    required this.fileSize,
    this.isFavorite = false,
    this.thumbnailPath,
  });

  factory DocumentModel.fromFile(File file) {
    final name = file.path.split('/').last;
    final ext = name.split('.').last.toLowerCase();
    DocumentType type;
    if (ext == 'hwp') {
      type = DocumentType.hwp;
    } else if (ext == 'hwpx') {
      type = DocumentType.hwpx;
    } else {
      type = DocumentType.unknown;
    }

    return DocumentModel(
      id: file.path.hashCode.toString(),
      name: name,
      path: file.path,
      type: type,
      lastOpened: DateTime.now(),
      createdAt: file.existsSync() ? file.statSync().changed : null,
      fileSize: file.existsSync() ? file.lengthSync() : 0,
    );
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      type: DocumentType.values[map['type'] as int],
      lastOpened: DateTime.fromMillisecondsSinceEpoch(map['lastOpened'] as int),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      fileSize: map['fileSize'] as int,
      isFavorite: map['isFavorite'] as bool? ?? false,
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.index,
      'lastOpened': lastOpened.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'fileSize': fileSize,
      'isFavorite': isFavorite,
      'thumbnailPath': thumbnailPath,
    };
  }

  String get typeLabel => type == DocumentType.hwp ? 'HWP' : 'HWPX';

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  DocumentModel copyWith({
    bool? isFavorite,
    DateTime? lastOpened,
    String? thumbnailPath,
  }) {
    return DocumentModel(
      id: id,
      name: name,
      path: path,
      type: type,
      lastOpened: lastOpened ?? this.lastOpened,
      createdAt: createdAt,
      fileSize: fileSize,
      isFavorite: isFavorite ?? this.isFavorite,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
