//
//  Functions.swift
//  MyLocations
//
//  Created by maxshikin on 19.01.2023.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping() -> Void ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
