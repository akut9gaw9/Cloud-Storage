//
//  Protocols.swift
//  diplom
//
//  Created by Stanislav on 02.03.2023.
//

import Foundation

protocol YandexWebKitDelegate: AnyObject {
    
    func handleTokenChanged(token: String)
    
}

protocol UpdateLastDownloadFilesDelegate: AnyObject {
    
    func updateTableView(index: IndexPath, name: String?)
    
}

protocol UpdateFileNameDelegate: AnyObject {
    func updatefileName(name: String)
}
