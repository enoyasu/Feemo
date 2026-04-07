//
//  Item.swift
//  Feemo
//
//  Created by 榎本康寿 on 2026/04/07.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
