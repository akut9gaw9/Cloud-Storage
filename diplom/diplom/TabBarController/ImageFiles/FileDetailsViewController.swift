//
//  ViewController.swift
//  diplom
//
//  Created by Stanislav on 13.01.2023.
//

import UIKit
import PDFKit
import WebKit

class FileDetailsViewController: UIViewController {
    
    weak var removeDelegate: UpdateLastDownloadFilesDelegate?
    var currentFile: DiskFile?
    let activityIndicator = UIActivityIndicatorView()
    var pathToTheFile: String?
    var fileIndex: IndexPath?

    var headTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()

    var currentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        setupConstraint()
    }
    
    @objc func deleteImage() {
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
    
    @objc func editImage() {
        let viewController = RenamingViewController()
        viewController.renameDelegate = self
        guard let format = currentFile?.mime_type else { return }
        guard let fileName = currentFile?.name else { return }
        
        switch format {
        case "image/png":
            viewController.setupFormatPath(path: pathToTheFile!, format: ".png", name: fileName, index: fileIndex!)
            navigationController?.pushViewController(viewController, animated: true)
        case "image/jpg":
            viewController.setupFormatPath(path: pathToTheFile!, format: ".jpg", name: fileName, index: fileIndex!)
            navigationController?.pushViewController(viewController, animated: true)
        case "image/jpeg":
            viewController.setupFormatPath(path: pathToTheFile!, format: ".jpeg", name: fileName, index: fileIndex!)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            print("Unknown file format: \(format)")
        }
    }
    
    @objc func shareImage() {
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
    
    func setupSettings(file: DiskFile?, index: IndexPath) {
        headTitle.text = file?.name
        currentFile = file
        fileIndex = index
        loadImage(urlString: (file?.preview)!)
        pathToTheFile = file?.path
        
    }
    
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.currentImageView.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupConstraint() {
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editImage)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        ], animated: true)
        
        currentImageView.translatesAutoresizingMaskIntoConstraints = false
        headTitle.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currentImageView)
        view.addSubview(headTitle)
        view.addSubview(activityIndicator)

        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            currentImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            currentImageView.widthAnchor.constraint(equalToConstant: 100),
            currentImageView.heightAnchor.constraint(equalToConstant: 100),
            
            headTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
    
}

extension FileDetailsViewController: UpdateFileNameDelegate {
    func updatefileName(name: String) {
        removeDelegate?.updateTableView(index: fileIndex!, name: name)
        DispatchQueue.main.async {
            self.headTitle.text = name
            self.navigationController?.popViewController(animated: true)
        }
    }
}
