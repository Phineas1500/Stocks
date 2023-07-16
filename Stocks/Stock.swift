//
//  Stock.swift
//  Stocks
//
//  Created by Sriram Kiron on 4/9/23.
//

struct Stock: Identifiable, Decodable {
    let id: String
    var number: Double
    var lastNumber: Double?  // Add this field

    init(id: String, number: Double, lastNumber: Double? = nil) {
        self.id = id
        self.number = number
        self.lastNumber = lastNumber
    }
}
