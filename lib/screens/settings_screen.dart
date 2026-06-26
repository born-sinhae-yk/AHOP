import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/document_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('앱 정보'),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildSectionHeader('데이터 관리'),
          _buildDataCard(context),
          const SizedBox(height: 16),
          _buildSectionHeader('rhwp 프로젝트'),
          _buildRhwpCard(),
          const SizedBox(height: 16),
          _buildSectionHeader('도움말'),
          _buildHelpCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HWP Suite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                SizedBox(height: 2),
                Text('버전 1.0.0', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                SizedBox(height: 2),
                Text('rhwp 기반 HWP 뷰어/에디터', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history_rounded, color: AppTheme.primary),
            title: const Text('최근 문서 기록 초기화'),
            subtitle: const Text('모든 최근 문서 기록을 삭제합니다'),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('기록 초기화'),
                  content: const Text('모든 최근 문서 기록과 즐겨찾기를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await Provider.of<DocumentProvider>(context, listen: false).clearRecent();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('기록이 초기화되었습니다'), backgroundColor: AppTheme.primary),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRhwpCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.code_rounded, color: AppTheme.primary),
            title: const Text('rhwp GitHub'),
            subtitle: const Text('github.com/edwardkim/rhwp'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.textSecondary),
            onTap: () => _launchUrl('https://github.com/edwardkim/rhwp'),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.web_rounded, color: AppTheme.primary),
            title: const Text('rhwp 온라인 에디터'),
            subtitle: const Text('edwardkim.github.io/rhwp'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.textSecondary),
            onTap: () => _launchUrl('https://edwardkim.github.io/rhwp/'),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
            title: const Text('rhwp란?'),
            subtitle: const Text('Rust + WebAssembly 기반 오픈소스 HWP 엔진'),
            onTap: () => _showRhwpInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: AppTheme.primary),
            title: const Text('HWP Suite 사용법'),
            onTap: () => _showUsageGuide(context),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primary),
            title: const Text('개인정보 처리방침'),
            subtitle: const Text('문서 데이터는 기기에만 저장됩니다'),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          const ListTile(
            leading: Icon(Icons.gavel_rounded, color: AppTheme.primary),
            title: Text('오픈소스 라이선스'),
            subtitle: Text('rhwp: MIT License'),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showRhwpInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('rhwp 프로젝트'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('rhwp는 Rust + WebAssembly 기반의 오픈소스 HWP/HWPX 뷰어/에디터입니다.',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),
              Text('주요 기능:', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('• HWP 5.0 / HWPX 파싱 및 렌더링\n• 텍스트 편집, 서식 적용\n• 표 생성 및 편집\n• PDF / SVG 내보내기\n• hwpctl 호환 API'),
              SizedBox(height: 12),
              Text('MIT 라이선스로 공개된 독립 오픈소스 프로젝트입니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
        ],
      ),
    );
  }

  void _showUsageGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('HWP Suite 사용법'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GuideStep(number: '1', text: '최근 문서 탭에서 "HWP 열기" 버튼을 탭합니다'),
              _GuideStep(number: '2', text: 'HWP 또는 HWPX 파일을 선택합니다'),
              _GuideStep(number: '3', text: 'rhwp 에디터가 열리면 문서를 보거나 편집합니다'),
              _GuideStep(number: '4', text: '편집 후 상단 도구 모음에서 저장/PDF/공유를 선택합니다'),
              _GuideStep(number: '5', text: '★ 버튼으로 자주 쓰는 문서를 즐겨찾기에 추가합니다'),
              SizedBox(height: 12),
              Text('⚠️ 인터넷 연결이 필요합니다\nrhwp 에디터는 edwardkim.github.io/rhwp에서 로드됩니다.',
                  style: TextStyle(fontSize: 12, color: Colors.orange)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;
  const _GuideStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
