//
//  NetworkConnection.swift
//  testproject
//
//  Created by Stanislav on 10.02.2023.
//

import Foundation
import Network

class NetworkConnection {
    
    static let shared = NetworkConnection()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    var networkConnectionFlag = false
    
    func connectionChecker() {
        
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Статус соединения - подключен")
                self.networkConnectionFlag = true
            } else {
                self.networkConnectionFlag = false
                print("Статус соединения - не подключен")
            }
        }
    }
    
}
