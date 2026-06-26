import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onDelete;
  final bool showPath;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onDelete,
    this.showPath = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildFileIcon(),
              const SizedBox(width: 14),
              Expanded(child: _buildFileInfo()),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    final isHwpx = document.type == DocumentType.hwpx;
    final color = isHwpx ? AppTheme.hwpxColor : AppTheme.hwpColor;
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_rounded, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            document.typeLabel,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo() {
    final dateStr = DateFormat('yy.MM.dd HH:mm').format(document.lastOpened);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (showPath)
          Text(
            document.path,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
            const SizedBox(width: 3),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              document.formattedSize,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            document.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: document.isFavorite ? AppTheme.favoriteColor : AppTheme.textSecondary,
            size: 22,
          ),
          onPressed: onFavoriteToggle,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppTheme.textSecondary),
            onPressed: () => _showContextMenu(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
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
                leading: const Icon(Icons.folder_open_rounded, color: AppTheme.primary),
                title: const Text('열기'),
                onTap: () { Navigator.pop(ctx); onTap(); },
              ),
              ListTile(
                leading: Icon(
                  document.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppTheme.favoriteColor,
                ),
                title: Text(document.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가'),
                onTap: () { Navigator.pop(ctx); onFavoriteToggle(); },
              ),
              if (onDelete != null) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('목록에서 삭제', style: TextStyle(color: Colors.red)),
                  onTap: () { Navigator.pop(ctx); onDelete!(); },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
