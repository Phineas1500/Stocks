//
//  PortfolioView.swift
//  Stocks
//
//  Created by Sriram Kiron on 4/9/23.
//

import SwiftUI

struct PortfolioView: View {
    @Binding var stocksOwned: [Int]
    @ObservedObject var stockManager: StockManager
    @Binding var balance: Double

    var body: some View {
        VStack {
            Spacer()
            ForEach(stockManager.stocks.indices) { index in
                let stock = stockManager.stocks[index]
                let stockLabel = stockLabelFor(index: index)
                VStack {
                    Text("Stock \(stockLabel) Owned: \(stocksOwned[index])")
                        .font(.largeTitle)
                        .padding()
                        .minimumScaleFactor(0.5)
                    Text("Total Value of \(stockLabel): $\(Double(stocksOwned[index]) * stock.number, specifier: "%.2f")")
                        .font(.largeTitle)
                        .padding()
                        .minimumScaleFactor(0.5)
                }
            }
            Text("Total Balance: $\(balance, specifier: "%.2f")")
                .font(.largeTitle)
                .padding()
                .minimumScaleFactor(0.5)
            Text("Overall Worth: $\(overallWorth(), specifier: "%.2f")")
                .font(.largeTitle)
                .padding()
                .minimumScaleFactor(0.5)
            Spacer()
        }
        .padding()
        .navigationTitle("Portfolio")
    }

    private func stockLabelFor(index: Int) -> String {
        switch index {
        case 0:
            return "ABC"
        case 1:
            return "XYZ"
        case 2:
            return "MMM"
        default:
            return "Unknown"
        }
    }

    private func overallWorth() -> Double {
        var totalStockValue = 0.0
        for i in stocksOwned.indices {
            if i < stockManager.stocks.count {
                totalStockValue += Double(stocksOwned[i]) * stockManager.stocks[i].number
            }
        }
        return balance + totalStockValue
    }
}

struct PortfolioView_Previews: PreviewProvider {
    @State static var stocksOwned = [0, 0, 0]
    static var stockManager = StockManager()
    @State static var balance = 100000.0

    static var previews: some View {
        PortfolioView(stocksOwned: $stocksOwned, stockManager: stockManager, balance: $balance)
    }
}
