//
//  StockManager.swift
//  Stocks
//
//  Created by Sriram Kiron on 4/9/23.
//

import Foundation

class StockManager: ObservableObject {
    @Published var stocks: [Stock] = []

    private var timers: [Timer] = []

    init() {
        initializeStocks()
        startFetchingStockData()
    }

    private func initializeStocks() {
        let stockIds = [
            "226da149-c028-4c6e-a79f-2921602b4225",
            "893e9da4-68f1-4a7a-8dc5-5e934622ba93"
        ]
        
        for stockId in stockIds {
            stocks.append(Stock(id: stockId, number: 0))
        }
    }

    private func startFetchingStockData() {
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            for stock in self.stocks {
                self.fetchNumber(for: stock.id)
            }
        }
        timers.append(timer)
    }

    private func fetchNumber(for stockId: String) {
        guard let url = URL(string: "http://127.0.0.1:8080/random_number/\(stockId)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching stock data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let stock = try decoder.decode(Stock.self, from: data)
                    DispatchQueue.main.async {
                        if let index = self.stocks.firstIndex(where: { $0.id == stock.id }) {
                            self.stocks[index].number = stock.number
                        }
                    }
                } catch {
                    print("Error decoding stock data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
