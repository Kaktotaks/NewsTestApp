//
//  WebViewViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 19.11.2022.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    // Constants and Variables
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()

    private let url: URL
    private let articleTitle: String?

    private var progressView: UIProgressView!

    init(url: URL, title: String?) {
        self.url = url
        self.articleTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // UI life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureProgressView()
        configureWebView()
    }

    private func configureWebView() {
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.load(URLRequest(url: url))
    }

    // Methods
    private func configureProgressView() {
        // Add tool bar with progress view
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .link
        progressView.trackTintColor = .systemBackground
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        toolbarItems = [progressButton]
        navigationController?.isToolbarHidden = false
    }

    override func viewDidLayoutSubviews() {
        webView.frame = view.bounds
    }

    private func configureUI() {
        navigationItem.title = articleTitle
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        configureButtons()
    }

    private func configureButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(didTapRefresh)
        )
    }

    @objc private func didTapDone() {
        dismiss(animated: true)
    }

    @objc private func didTapRefresh() {
        webView.load(URLRequest(url: url))
    }
}

// Setup progress view
extension WebViewViewController: WKNavigationDelegate {
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?) {
                if keyPath == "estimatedProgress" {
                    self.progressView.progress = Float(self.webView.estimatedProgress)
                }
        }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationController?.isToolbarHidden = true
    }
}
