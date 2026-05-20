//
//  LocalJSONPayload.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

enum LocalJSONPayload {
    static let emptyObject = "{}"

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func encode<T: Encodable>(_ value: T) throws -> String {
        let data = try encoder.encode(value)
        return String(decoding: data, as: UTF8.self)
    }

    static func decode<T: Decodable>(_ type: T.Type, from payloadJSON: String) throws -> T {
        let data = Data(payloadJSON.utf8)
        return try decoder.decode(type, from: data)
    }
}
