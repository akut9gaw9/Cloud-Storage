//
//  AuthorizationViewController.swift
//  diplom
//
//  Created by Stanislav on 11.01.2023.
//

import UIKit
import CoreData

class LastDownloadViewController: UIViewController {
        
    let tableView = UITableView()
    var isFirst = true
    var responseData: DiskResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        setupConstraints()
        tableView.dataSource = self
        tableView.delegate = self
        DataManager.shared.fetchedResultsController.delegate = self
        DataManager.shared.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if isFirst {
            NetworkConnection.shared.connectionChecker()
            showLoginViewController()
        }
        isFirst = false
    }
    
    func setupConstraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    func showLoginViewController() {
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded") else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let lastUploadFiles = try? JSONDecoder().decode(DiskResponse.self, from: data) else { return }
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

}

extension LastDownloadViewController: UITableViewDataSource, UITableViewDelegate {
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

extension LastDownloadViewController: UpdateLastDownloadFilesDelegate {
    
    func updateTableView(index: IndexPath, name: String?) {
        
        if let fileName = name {
            responseData?.items![index.row].name = name
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

extension LastDownloadViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .top)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .top)
        case .move:
            tableView.reloadRows(at: [indexPath!], with: .top)
        default:
            fatalError("feature not yet implemented")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .top)
        case .delete:
            tableView.deleteSections(indexSet, with: .top)
        case .update, .move:
            fatalError("Invalid change.")
        default:
            fatalError("feature not yet implemented")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.endUpdates()
    }
}

