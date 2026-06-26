/// rhwp WASM 기반 HWP 에디터를 WebView에 로드하기 위한 HTML 생성 서비스
class RhwpService {
  /// rhwp 에디터를 임베드하는 HTML 페이지 생성
  /// fileBase64: HWP 파일의 Base64 인코딩 데이터
  /// fileName: 파일 이름 (확장자 포함)
  static String buildEditorHtml({
    String? fileBase64,
    String? fileName,
    bool readOnly = false,
  }) {
    final fileScript = fileBase64 != null && fileName != null
        ? '''
        async function loadDocument() {
          try {
            const base64Data = "$fileBase64";
            const binaryStr = atob(base64Data);
            const bytes = new Uint8Array(binaryStr.length);
            for (let i = 0; i < binaryStr.length; i++) {
              bytes[i] = binaryStr.charCodeAt(i);
            }
            const blob = new Blob([bytes], { type: 'application/octet-stream' });
            const file = new File([blob], "$fileName");
            await editor.openFile(file);
            notifyFlutter('documentLoaded', { name: "$fileName" });
          } catch (e) {
            notifyFlutter('error', { message: e.toString() });
          }
        }
        '''
        : 'function loadDocument() {}';

    return '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>HWP Suite Editor</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; background: #f5f5f5; }
    #app {
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
    }
    #toolbar {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 6px 12px;
      background: #1565C0;
      color: white;
      font-family: 'Noto Sans KR', sans-serif;
      font-size: 13px;
      min-height: 44px;
      flex-shrink: 0;
      overflow-x: auto;
    }
    .toolbar-btn {
      background: rgba(255,255,255,0.15);
      border: none;
      color: white;
      padding: 5px 10px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 12px;
      white-space: nowrap;
      transition: background 0.2s;
    }
    .toolbar-btn:hover { background: rgba(255,255,255,0.25); }
    .toolbar-sep { width: 1px; height: 20px; background: rgba(255,255,255,0.3); flex-shrink: 0; }
    #file-name {
      font-weight: 600;
      font-size: 13px;
      color: rgba(255,255,255,0.9);
      flex: 1;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    #editor-container {
      flex: 1;
      overflow: hidden;
      position: relative;
    }
    #rhwp-editor {
      width: 100%;
      height: 100%;
      border: none;
    }
    #loading-overlay {
      position: absolute;
      inset: 0;
      background: #f5f5f5;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 16px;
      z-index: 100;
      font-family: 'Noto Sans KR', sans-serif;
    }
    .spinner {
      width: 48px;
      height: 48px;
      border: 4px solid #e3e3e3;
      border-top-color: #1565C0;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .loading-text { color: #555; font-size: 14px; }
    .loading-sub { color: #999; font-size: 12px; }
    #error-overlay {
      position: absolute;
      inset: 0;
      background: #f5f5f5;
      display: none;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 12px;
      z-index: 101;
      font-family: 'Noto Sans KR', sans-serif;
      padding: 24px;
      text-align: center;
    }
    .error-icon { font-size: 48px; }
    .error-title { color: #c62828; font-size: 16px; font-weight: 600; }
    .error-msg { color: #666; font-size: 13px; line-height: 1.5; }
    .retry-btn {
      background: #1565C0;
      color: white;
      border: none;
      padding: 10px 24px;
      border-radius: 8px;
      cursor: pointer;
      font-size: 14px;
      margin-top: 8px;
    }
  </style>
</head>
<body>
<div id="app">
  <div id="toolbar">
    <span id="file-name">${fileName ?? '새 문서'}</span>
    <div class="toolbar-sep"></div>
    <button class="toolbar-btn" onclick="saveDocument()">💾 저장</button>
    <button class="toolbar-btn" onclick="exportPdf()">📄 PDF</button>
    <button class="toolbar-btn" onclick="shareDocument()">📤 공유</button>
    <button class="toolbar-btn" onclick="printDocument()">🖨️ 인쇄</button>
  </div>
  <div id="editor-container">
    <div id="loading-overlay">
      <div class="spinner"></div>
      <div class="loading-text">rhwp 에디터 로딩 중...</div>
      <div class="loading-sub">잠시만 기다려주세요</div>
    </div>
    <div id="error-overlay">
      <div class="error-icon">⚠️</div>
      <div class="error-title">에디터 로드 실패</div>
      <div class="error-msg" id="error-msg">인터넷 연결을 확인하고 다시 시도해주세요.</div>
      <button class="retry-btn" onclick="retryLoad()">다시 시도</button>
    </div>
    <iframe
      id="rhwp-editor"
      src="https://edwardkim.github.io/rhwp/"
      sandbox="allow-scripts allow-same-origin allow-forms allow-downloads allow-popups allow-modals"
      allow="clipboard-read; clipboard-write"
    ></iframe>
  </div>
</div>

<script>
  let editor = null;
  let editorReady = false;
  const iframe = document.getElementById('rhwp-editor');
  const loadingOverlay = document.getElementById('loading-overlay');
  const errorOverlay = document.getElementById('error-overlay');

  function notifyFlutter(event, data) {
    try {
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('rhwpEvent', JSON.stringify({ event, data }));
      } else if (window.HwpSuiteChannel) {
        window.HwpSuiteChannel.postMessage(JSON.stringify({ event, data }));
      }
    } catch(e) {}
  }

  function hideLoading() {
    loadingOverlay.style.display = 'none';
  }

  function showError(msg) {
    document.getElementById('error-msg').textContent = msg || '알 수 없는 오류가 발생했습니다.';
    errorOverlay.style.display = 'flex';
    loadingOverlay.style.display = 'none';
  }

  function retryLoad() {
    errorOverlay.style.display = 'none';
    loadingOverlay.style.display = 'flex';
    iframe.src = iframe.src;
  }

  // iframe 로드 완료
  iframe.addEventListener('load', function() {
    setTimeout(() => {
      hideLoading();
      editorReady = true;
      notifyFlutter('editorReady', {});
      ${fileBase64 != null ? 'loadDocument();' : ''}
    }, 1500);
  });

  iframe.addEventListener('error', function() {
    showError('rhwp 에디터에 연결할 수 없습니다.\\n인터넷 연결을 확인해주세요.');
    notifyFlutter('editorError', { message: 'iframe load failed' });
  });

  // iframe에서 메시지 수신
  window.addEventListener('message', function(event) {
    const data = event.data;
    if (typeof data === 'object') {
      notifyFlutter('iframeMessage', data);
    }
  });

  $fileScript

  function saveDocument() {
    iframe.contentWindow?.postMessage({ action: 'save' }, '*');
    notifyFlutter('save', {});
  }

  function exportPdf() {
    iframe.contentWindow?.postMessage({ action: 'exportPdf' }, '*');
    notifyFlutter('exportPdf', {});
  }

  function shareDocument() {
    notifyFlutter('share', { fileName: "${fileName ?? '문서'}" });
  }

  function printDocument() {
    iframe.contentWindow?.postMessage({ action: 'print' }, '*');
  }

  // 타임아웃 처리 (30초)
  setTimeout(() => {
    if (!editorReady) {
      showError('로딩 시간이 초과되었습니다.\\n인터넷 연결을 확인하고 다시 시도해주세요.');
    }
  }, 30000);
</script>
</body>
</html>
''';
  }

  /// rhwp 뷰어 전용 HTML (읽기 전용)
  static String buildViewerHtml({String? fileName}) {
    return buildEditorHtml(fileName: fileName, readOnly: true);
  }
}
