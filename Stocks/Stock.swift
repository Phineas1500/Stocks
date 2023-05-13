//
//  Stock.swift
//  Stocks
//
//  Created by Sriram Kiron on 4/9/23.
//

struct Stock: Identifiable, Decodable {
    let id: String
    var number: Double

    init(id: String, number: Double) {
        self.id = id
        self.number = number
    }
}
