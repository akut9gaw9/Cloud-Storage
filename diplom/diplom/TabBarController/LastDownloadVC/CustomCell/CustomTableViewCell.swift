//
//  TableViewCell.swift
//  diplom
//
//  Created by Stanislav on 12.01.2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    static let identifier = "CustomTableViewCell"
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var mainFileNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    var mainPreviewFileImage: UIImageView = {
        let mainImageView = UIImageView()
        mainImageView.contentMode = .scaleAspectFit
        return mainImageView
    }()
    
    var fileSizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    var fileCreationDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(name: String?, preview: String?, dateCreated: String?, size: Int64?) {
        guard let name = name else { return }
        self.mainFileNameLabel.text = name
        
        guard let dateCreated = dateCreated else { return }
        self.fileCreationDateLabel.text = dateConversion(dataCreated: dateCreated)
        
        guard let size = size else { return }
        self.fileSizeLabel.text = "\(size / 1000) кб"
        
        guard let preview = preview else { return }
        loadImage(urlString: preview)
        
    }
    
    private func dateConversion(dataCreated: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let dataDate = formatter.date(from: dataCreated) else { return "" }
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let finalString = formatter.string(from: dataDate)
        return finalString
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
                    self?.mainPreviewFileImage.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func setupUI() {
        
        contentView.addSubview(mainFileNameLabel)
        contentView.addSubview(mainPreviewFileImage)
        contentView.addSubview(fileSizeLabel)
        contentView.addSubview(fileCreationDateLabel)
        contentView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        mainFileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        mainPreviewFileImage.translatesAutoresizingMaskIntoConstraints = false
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        fileCreationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            mainPreviewFileImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainPreviewFileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainPreviewFileImage.widthAnchor.constraint(equalToConstant: 50),
            mainPreviewFileImage.heightAnchor.constraint(equalToConstant: 50),
            
            mainFileNameLabel.leadingAnchor.constraint(equalTo: mainPreviewFileImage.trailingAnchor, constant: 5),
            mainFileNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            fileSizeLabel.leadingAnchor.constraint(equalTo: mainPreviewFileImage.trailingAnchor, constant: 5),
            fileSizeLabel.topAnchor.constraint(equalTo: mainFileNameLabel.bottomAnchor, constant: 5),
            
            fileCreationDateLabel.leadingAnchor.constraint(equalTo: fileSizeLabel.trailingAnchor, constant: 10),
            fileCreationDateLabel.topAnchor.constraint(equalTo: mainFileNameLabel.bottomAnchor, constant: 5),
            
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
        
    }
    
}
