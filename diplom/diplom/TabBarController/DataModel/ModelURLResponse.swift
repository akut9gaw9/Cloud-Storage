//
//  ModelURLResponse.swift
//  diplom
//
//  Created by Stanislav on 11.01.2023.
//

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let publicKey: String?
    let embedded: Embedded
    let name: String?
    let created: Date?
    let customProperties: CustomProperties
    let publicURL: String?
    let modified: Date?
    let path, type: String?

    enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case embedded = "_embedded"
        case name, created
        case customProperties = "custom_properties"
        case publicURL = "public_url"
        case modified, path, type
    }
}

// MARK: - CustomProperties
struct CustomProperties: Codable {
    let foo, bar: String?
}

// MARK: - Embedded
struct Embedded: Codable {
    let sort, path: String?
    let items: [Item?]
    let limit, offset: Int?
}

// MARK: - Item
struct Item: Codable {
    let path, type, name: String?
    let modified, created: Date?
    let preview: String?
    let md5, mimeType: String?
    let size: Int?

    enum CodingKeys: String, CodingKey {
        case path, type, name, modified, created, preview, md5
        case mimeType = "mime_type"
        case size
    }
}


struct DiskResponse: Codable {
    var items: [DiskFile]?
}

struct DiskFile: Codable {
    var name: String?
    var preview: String?
    var size: Int64?
    var created: String?
    var mime_type: String?
    var path: String?
}

struct DownloadResponse: Codable {
    var href: String
    var method: String
    var templated: Bool
}

struct DiskSizeResponse: Codable {
    var trash_size: Int?
    var total_space: Int?
    var used_space: Int?
}

