//
//  ProfileViewController.swift
//  diplom
//
//  Created by Stanislav on 06.03.2023.
//

import UIKit
import Charts

class ProfileViewController: UIViewController, ChartViewDelegate {
    
    var pieChart = PieChartView()
    let activityIndicator = UIActivityIndicatorView()
    let tableView = UITableView()
    let list = ["Опубликованные файлы", "Выйти с профиля"]
    let identifier = "myCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        pieChart.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        pieChart.noDataText = ""

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/") else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(NetworkService.shared.token)", forHTTPHeaderField: "Authorization")
        NetworkService.shared.getData(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let diskSize = try? JSONDecoder().decode(DiskSizeResponse.self, from: data) else { return }
                self?.setupPieChart(data: diskSize)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    func numberConvertForLabel(totalSpace: Int, usedSpace: Int, trashSpace: Int) -> Int {
        let result = (totalSpace / 1024 / 1024) - ((trashSpace / 1024 / 1024) + (usedSpace / 1024 / 1024))
        return result
    }
    
    func setupPieChart(data: DiskSizeResponse) {
        var totalSpace = (data.total_space! / 1024 / 1024)
        var usedSpace = ((data.trash_size! / 1024 / 1024) + (data.used_space! / 1024 / 1024))
        var entry = [ChartDataEntry]()
        entry.append(ChartDataEntry(x: Double(totalSpace-usedSpace), y: Double(totalSpace-usedSpace) ))
        entry.append(ChartDataEntry(x: Double(usedSpace), y: Double(usedSpace) ))
        let set = PieChartDataSet(entries: entry, label: "Объем хранилища: \(totalSpace / 1024) ГБ")
        set.colors = ChartColorTemplates.pastel()
        let data = PieChartData(dataSet: set)
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.pieChart.data = data
        }
    }
    
    func setupConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.addSubview(pieChart)
        view.addSubview(tableView)
        
        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pieChart.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pieChart.widthAnchor.constraint(equalTo: view.widthAnchor),
            pieChart.heightAnchor.constraint(equalToConstant: view.frame.height / 2),
            tableView.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func openItem(item: String) {
        switch item {
        case "Опубликованные файлы":
            let vc = PublishedViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            let alert = UIAlertController(title: "Выход с профиля", message: "Вы точно хотите выйти с профиля? Все данные будут удалены", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Нет", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Да", style: UIAlertAction.Style.destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
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

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        openItem(item: item)
    }
}
