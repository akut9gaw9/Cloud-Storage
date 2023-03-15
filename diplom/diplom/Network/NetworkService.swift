//
//  NetworkService.swift
//  testproject
//
//  Created by Stanislav on 02.02.2023.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    var token = ""
    
    func getData(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(error))
            }
            guard let data = data else { return }
            completion(.success(data))
        }.resume()
    }
    
    func renameOrDeleteFile(request: URLRequest, completion: @escaping (Error?) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: error calling rename: \(error)")
                return
            }
            completion(error)
        }.resume()
    }
}

