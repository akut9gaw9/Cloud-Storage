//
//  PublishedViewController.swift
//  diplom
//
//  Created by Stanislav on 13.03.2023.
//

import UIKit

class PublishedViewController: UIViewController {
    
    let tableView = UITableView()
    var publishedFileList: DiskResponse?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
        setupDataTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)

        // Do any additional setup after loading the view.
    }
    
    func setupDataTableView() {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/public")
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let answer = try? JSONDecoder().decode(DiskResponse.self, from: data) else { return }
                self?.publishedFileList = answer
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func showFileDetails(fileData: DiskFile?, index: IndexPath) {
        let result = fileData?.mime_type
        switch result {
        case "image/png", "image/jpeg", "image/jpg":
            let viewController = FileDetailsViewController()
            viewController.removeDelegate = self
            viewController.setupSettings(file: fileData, index: index)
            navigationController?.pushViewController(viewController, animated: true)
        case "application/pdf":
            let viewController = PDFViewController()
            viewController.removeDelegate = self
            viewController.setupSettings(file: fileData, index: index)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            let viewController = MSOfficeWebKitViewController()
            viewController.removeDelegate = self
            viewController.setupSettings(file: fileData, index: index)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PublishedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if NetworkConnection.shared.networkConnectionFlag {
            return publishedFileList?.items?.count ?? 0
        } else {
            guard let frc = DataManager.shared.fetchedResultsController.sections else {
                fatalError("No sections in fetchedResultsController")
            }
            let sectionInfo = frc[section]
            return sectionInfo.numberOfObjects
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else {
            fatalError("Error in CustomTableViewCell")
        }
        if NetworkConnection.shared.networkConnectionFlag {
            let currentFile = publishedFileList?.items?[indexPath.row]
            cell.configureCell(name: currentFile?.name, preview: currentFile?.preview, dateCreated: currentFile?.created, size: currentFile?.size)
            return cell
        } else {
            let item = DataManager.shared.fetchedResultsController.object(at: indexPath)
            cell.configureCell(name: item.nameFileModel, preview: item.previewFileModel, dateCreated: item.dateCreatedFileModel, size: Int64(item.sizeFileModel!))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentFile = publishedFileList?.items?[indexPath.row]
        showFileDetails(fileData: currentFile, index: indexPath)
    }
}

extension PublishedViewController: UpdateLastDownloadFilesDelegate {
    
    func updateTableView(index: IndexPath, name: String?) {
        
        if let fileName = name {
            publishedFileList?.items![index.row].name = name
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        publishedFileList?.items?.remove(at: index.row)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
