//
//  AllFilesViewController.swift
//  diplom
//
//  Created by Stanislav on 06.03.2023.
//

import UIKit

class AllFilesViewController: UIViewController {

    
    let tableView = UITableView()
    var responseData: DiskResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
        setupTableViewData()
        // Do any additional setup after loading the view.
    }
    
    func setupConstraints(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    func setupTableViewData(){
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/files")
//        components?.queryItems = [URLQueryItem(name: "path", value: "disk:/folder/bebe")]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let lastUploadFiles = try? JSONDecoder().decode(DiskResponse.self, from: data) else { return }
//                guard let lastUploadFiless = try? JSONDecoder().decode(Welcome.self, from: data) else { return }
                self?.responseData = lastUploadFiles
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
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

extension AllFilesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if NetworkConnection.shared.networkConnectionFlag {
            return responseData?.items?.count ?? 0
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
            
            let currentFile = responseData?.items?[indexPath.row]
            cell.configureCell(name: currentFile?.name, preview: currentFile?.preview, dateCreated: currentFile?.created, size: currentFile?.size)
            return cell
        } else {
            let item = DataManager.shared.fetchedResultsController.object(at: indexPath)
            cell.configureCell(name: item.nameFileModel, preview: item.previewFileModel, dateCreated: item.dateCreatedFileModel, size: Int64(item.sizeFileModel!))
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentFile = responseData?.items?[indexPath.row]
        showFileDetails(fileData: currentFile, index: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension AllFilesViewController: UpdateLastDownloadFilesDelegate {
    
    func updateTableView(index: IndexPath, name: String?) {
        
        if let fileName = name {
            responseData?.items?[index.row].name = name
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        responseData?.items?.remove(at: index.row)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
