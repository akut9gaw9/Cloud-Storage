//
//  DataManager.swift
//  testproject
//
//  Created by Stanislav on 08.02.2023.
//

import Foundation
import CoreData
import UIKit

class DataManager {
    
    static let shared = DataManager()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<File> = {
        let fetchRequest: NSFetchRequest<File> = File.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(File.nameFileModel), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    func loadData() {
        let vc = LastDownloadViewController()
        do {
            try fetchedResultsController.performFetch()
            vc.tableView.reloadData()
        } catch {
            print("Error in func loadData: \(error.localizedDescription)")
        }
    }
    
    func deleteData(file: File) {
        context.delete(file)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveData(file: DiskResponse) {
        let newFile = File(context: context)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateData(file: File) {
//        person.name = textFieldForPersonName.text
//        person.surname = textFieldForPersonSurname.text
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
