//
//  JSONDataExporter.swift
//  
//
//  Created by Pawel Ambrozej on 08/10/2019.
//
import Foundation

class JSONDataExporter {
    
    static func encodeJSON(from data: TimedStateHistory) -> String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print(error)
            return nil
        }
    }
}
