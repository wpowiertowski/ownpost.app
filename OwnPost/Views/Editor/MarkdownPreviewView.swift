import SwiftUI
import WebKit

struct MarkdownPreviewView: View {
    let markdown: String

    var body: some View {
        MarkdownWebView(html: htmlDocument)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var htmlDocument: String {
        let html = MarkdownExporter.toHTML(markdown)
        return """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            :root { color-scheme: light dark; }
            html, body {
              margin: 0;
              padding: 0;
              background: transparent;
              color: -apple-system-label;
              font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
              font-size: 14px;
              line-height: 1.52;
            }
            h1, h2, h3, h4, h5, h6 {
              margin: 0.95em 0 0.45em;
              line-height: 1.25;
            }
            p { margin: 0.6em 0; }
            ul, ol { margin: 0.6em 0 0.6em 1.35em; }
            li { margin: 0.22em 0; }
            blockquote {
              margin: 0.8em 0;
              padding-left: 0.8em;
              border-left: 3px solid color-mix(in srgb, -apple-system-label 20%, transparent);
              color: color-mix(in srgb, -apple-system-label 70%, transparent);
            }
            pre, code {
              font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
            }
            pre {
              padding: 0.75em;
              border-radius: 8px;
              background: color-mix(in srgb, -apple-system-label 10%, transparent);
              overflow-x: auto;
            }
            img { max-width: 100%; height: auto; }
            hr { border: none; border-top: 1px solid color-mix(in srgb, -apple-system-label 20%, transparent); }
          </style>
        </head>
        <body>\(html)</body>
        </html>
        """
    }
}

#if os(iOS)
private struct MarkdownWebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.mediaTypesRequiringUserActionForPlayback = .all
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.allowsLinkPreview = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
#else
private struct MarkdownWebView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.mediaTypesRequiringUserActionForPlayback = .all
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
#endif
