//
//  RenamingViewController.swift
//  diplom
//
//  Created by Stanislav on 02.03.2023.
//

import UIKit

class RenamingViewController: UIViewController {
    
    weak var renameDelegate: UpdateFileNameDelegate?
    let renameTextField = RegisterTextField(placeholder: "Введите новое имя файла")
    var formatFile: String?
    var filePath: String?
    var fileName: String?
    var fileIndex: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
    }
    
    @objc func save() {
        
        guard let newFileName = renameTextField.text else { return }
        guard let finishFormat = formatFile else { return }
        
        let replacedPath = filePath?.replacingOccurrences(of: fileName!, with: "\(newFileName)\(finishFormat)")
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/move")
        components?.queryItems = [
            URLQueryItem(name: "from", value: filePath),
            URLQueryItem(name: "path", value: replacedPath)
        ]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.renameOrDeleteFile(request: request) { [weak self] result in
            if let result = result {
                print("Error in rename function: \(result)")
            }
            self!.renameDelegate?.updatefileName(name: "\(newFileName)\(finishFormat)")
            DispatchQueue.main.async {
                self!.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupFormatPath(path: String, format: String, name: String, index: IndexPath) {
        formatFile = format
        filePath = path
        fileName = name
        fileIndex = index
    }
    
    func setupConstraints() {
        
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(save))
        
        renameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(renameTextField)
        
        NSLayoutConstraint.activate([
            renameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            renameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            renameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
            
        ])
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

