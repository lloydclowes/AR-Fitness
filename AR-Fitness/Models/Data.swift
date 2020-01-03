//
//  Utilities.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 27/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import UIKit

let exerciseData: [Exercise] = load("exerciseData.json")

enum Exercises : Int {
    case lateralRaise
    case squat
    case jumpingJacks
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
