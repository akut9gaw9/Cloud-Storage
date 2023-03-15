//
//  YandexWebKitViewController.swift
//  diplom
//
//  Created by Stanislav on 11.01.2023.
//

import UIKit
import WebKit

final class YandexWebKitViewController: UIViewController {
    
    weak var authDelegate: YandexWebKitDelegate?
    let webView = WKWebView()
    let clientId = "8162173d4f574853a516a533438a2db8"
    
    var request: URLRequest? {
        guard var urlComponents = URLComponents(string: "https://oauth.yandex.ru/authorize") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "\(clientId)")
        ]
        guard let url = urlComponents.url else { return nil }
        return URLRequest(url: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraint()
        guard let request = request else { return }
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    func setupConstraint() {
        view.backgroundColor = .white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        ])
        
    }
    
}

extension YandexWebKitViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           url.scheme == "myphotos" {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            
            let token = components.queryItems?.first(where: { $0.name == "access_token"})?.value
            if let token = token {
                authDelegate?.handleTokenChanged(token: token)
            }
            decisionHandler(.cancel)
            dismiss(animated: true)
            SceneDelegate.window?.rootViewController = UINavigationController(rootViewController: MainTabBarController())
            SceneDelegate.window?.makeKeyAndVisible()
            return
        }
        decisionHandler(.allow)
    }
}

