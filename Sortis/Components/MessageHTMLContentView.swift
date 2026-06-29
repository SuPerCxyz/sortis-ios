import SwiftUI
import WebKit

private let messageHTMLViewportMeta = "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes\" />"

private let messageHTMLBaseStyle = """
html {
  min-height: 100%;
}
body {
  min-height: 100%;
  margin: 0;
  padding: 12px;
  background: #ffffff;
  color: #1f2937;
  font: 14px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
img {
  max-width: 100%;
  height: auto;
}
table {
  max-width: 100%;
}
a {
  word-break: break-word;
}
.email-html-content {
  width: 100%;
}
"""

private func buildMessageHTMLDocument(content: String, contentType: String?) -> String {
    let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedContent.isEmpty {
        return """
        <!doctype html>
        <html lang="zh-CN">
        <head>
          <meta charset="utf-8" />
          \(messageHTMLViewportMeta)
          <style>\(messageHTMLBaseStyle)</style>
        </head>
        <body><div class="email-html-content">暂无内容</div></body>
        </html>
        """
    }

    if isCompleteHTMLDocument(trimmedContent) {
        return injectZoomViewportIntoHTMLDocument(trimmedContent)
    }

    return """
    <!doctype html>
    <html lang="zh-CN">
    <head>
      <meta charset="utf-8" />
      \(messageHTMLViewportMeta)
      <style>\(messageHTMLBaseStyle)</style>
    </head>
    <body><div class="email-html-content">\(trimmedContent)</div></body>
    </html>
    """
}

private func isCompleteHTMLDocument(_ content: String) -> Bool {
    let lowercased = content.lowercased()
    return lowercased.contains("<html") || lowercased.contains("<!doctype html")
}

private func injectZoomViewportIntoHTMLDocument(_ documentHTML: String) -> String {
    let styleBlock = "<style data-sortis-email-reader>\(messageHTMLBaseStyle)</style>"
    var result = documentHTML

    if result.range(of: "<meta\\s+name=[\"']viewport[\"']", options: .regularExpression) == nil,
       let headRange = result.range(of: "<head((?:\\s[^>]*)?)>", options: .regularExpression) {
        result.replaceSubrange(headRange, with: "\(result[headRange])\(messageHTMLViewportMeta)")
    }

    if let headCloseRange = result.range(of: "</head>", options: .caseInsensitive) {
        result.replaceSubrange(headCloseRange, with: "\(styleBlock)</head>")
        return result
    }

    if let htmlOpenRange = result.range(of: "<html((?:\\s[^>]*)?)>", options: .regularExpression) {
        result.replaceSubrange(htmlOpenRange, with: "\(result[htmlOpenRange])<head><meta charset=\"utf-8\" />\(messageHTMLViewportMeta)\(styleBlock)</head>")
        return result
    }

    return """
    <!doctype html>
    <html lang="zh-CN">
    <head>
      <meta charset="utf-8" />
      \(messageHTMLViewportMeta)
      \(styleBlock)
    </head>
    <body>\(result)</body>
    </html>
    """
}

private func isHTMLContent(_ contentType: String?, content: String?) -> Bool {
    let normalizedType = (contentType ?? "").lowercased()
    if normalizedType.contains("html") {
        return true
    }
    guard let content else { return false }
    return content.range(of: "</?[a-z][\\s\\S]*>", options: .regularExpression) != nil
}

struct MessageHTMLContentView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}

extension Message {
    var supportsHTMLZoomDetail: Bool {
        isHTMLContent(contentType, content: content)
    }

    var zoomableHTMLDetailDocument: String? {
        guard let content, supportsHTMLZoomDetail else { return nil }
        return buildMessageHTMLDocument(content: content, contentType: contentType)
    }
}
