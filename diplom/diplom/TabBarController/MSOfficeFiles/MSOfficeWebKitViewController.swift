//
//  MSOfficeWebKitViewController.swift
//  diplom
//
//  Created by Stanislav on 22.02.2023.
//

import Foundation
import UIKit
import WebKit


class MSOfficeWebKitViewController: UIViewController {
    

    weak var removeDelegate: UpdateLastDownloadFilesDelegate?
    var currentFile: DiskFile?
    var pathToTheFile: String?
    var fileIndex: IndexPath?
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
    }
    
    func getLink(path: String) {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/download")
        components?.queryItems = [URLQueryItem(name: "path", value: path)]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let answer = try? JSONDecoder().decode(DownloadResponse.self, from: data) else { return }
                self?.setupWebView(urlString: answer.href)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupSettings(file: DiskFile?, index: IndexPath) {
        currentFile = file
        pathToTheFile = file?.path
        fileIndex = index
        getLink(path: (currentFile?.path)!)
    }
    
    func setupWebView(urlString: String) {
        if let resourceURL = URL(string: urlString) {
            var request = URLRequest(url: resourceURL)
            request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
            DispatchQueue.main.async {
                self.webView.load(request)
            }
        }
    }
    
    func setupConstraints() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editFile)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFile)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteFile))
        ], animated: true)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func deleteFile() {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        components?.queryItems = [URLQueryItem(name: "path", value: pathToTheFile)]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.renameOrDeleteFile(request: request) { error in
            if let error = error {
                print("\(error)")
                return
            }
            self.removeDelegate?.updateTableView(index: self.fileIndex!, name: nil)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func editFile() {
        let viewController = RenamingViewController()
        viewController.renameDelegate = self
        guard let fileName = currentFile?.name else { return }
        viewController.setupFormatPath(path: pathToTheFile!, format: ".docx", name: fileName, index: fileIndex!)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func shareFile() {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/publish")
        components?.queryItems = [URLQueryItem(name: "path", value: pathToTheFile)]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let answer = try? JSONDecoder().decode(DownloadResponse.self, from: data) else { return }
                let activityViewController = UIActivityViewController(activityItems: [answer.href], applicationActivities: nil)
                DispatchQueue.main.async {
                    self?.present(activityViewController, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }

    }
}

extension MSOfficeWebKitViewController: UpdateFileNameDelegate {
    
    func updatefileName(name: String) {
        removeDelegate?.updateTableView(index: fileIndex!, name: name)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
