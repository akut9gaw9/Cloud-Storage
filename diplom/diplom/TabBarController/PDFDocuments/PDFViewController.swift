//
//  PDFViewController.swift
//  diplom
//
//  Created by Stanislav on 17.02.2023.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    weak var removeDelegate: UpdateLastDownloadFilesDelegate?
    var currentFile: DiskFile?
    let activityIndicator = UIActivityIndicatorView()
    var pathToTheFile: String?
    var fileIndex: IndexPath?
    
    var pdfView = PDFView()
//    var pdfURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraint()
    }
    
    func setupConstraint() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPDFFile)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePDFFile)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePDFFile))
        ], animated: true)
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pdfView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pdfView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func setupSettings(file: DiskFile?, index: IndexPath) {
        currentFile = file
        pathToTheFile = file?.path
        fileIndex = index
        setupPDFSettings(path: (currentFile?.path)!)
    }
    
    func setupPDFSettings(path: String) {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/download")
        components?.queryItems = [URLQueryItem(name: "path", value: path)]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let answer = try? JSONDecoder().decode(DownloadResponse.self, from: data) else { return }
                let queue = DispatchQueue.global()
                queue.async {
                    guard let pdfURL = URL(string: answer.href) else { return }
                    self?.setupPDFView(url: pdfURL)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupPDFView(url: URL) {
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let document = PDFDocument(data: data) else { return }
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.pdfView.document = document
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @objc func deletePDFFile() {
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
    
    @objc func editPDFFile() {
        let viewController = RenamingViewController()
        viewController.renameDelegate = self
        guard let fileName = currentFile?.name else { return }
        viewController.setupFormatPath(path: pathToTheFile!, format: ".pdf", name: fileName, index: fileIndex!)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func sharePDFFile() {
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

extension PDFViewController: UpdateFileNameDelegate {
    
    func updatefileName(name: String) {
        removeDelegate?.updateTableView(index: fileIndex!, name: name)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
