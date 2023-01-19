//
//  Functions.swift
//  MyLocations
//
//  Created by maxshikin on 19.01.2023.
//

import Foundation

let applicationDocumentsDirectory : URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

func afterDelay(_ seconds: Double, run: @escaping() -> Void ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

