import SwiftUI

struct StockDetailView: View {
    let stockIndex: Int
    @Binding var balance: Double
    @ObservedObject var stockManager: StockManager
    
    @State private var stocksToBuy: Int = 1
    @State private var showError: Bool = false
    @State private var showInsufficientBalance: Bool = false
    @State private var showExcessStockSaleError: Bool = false


    var body: some View {
        VStack {
            Text("\(stockManager.stockLabelFor(id: stockManager.stocks[stockIndex].id)): $\(stockManager.stocks[stockIndex].number, specifier: "%.2f")")
                .font(.largeTitle)
                .padding()
                .foregroundColor(stockManager.stocks[stockIndex].number > stockManager.stocks[stockIndex].lastNumber ?? 0 ? .green : .red)
            if showInsufficientBalance {
                Text("Insufficient balance")
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            if showError {
                Text("Minimum stocks to buy is 1")
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            if showExcessStockSaleError {
                Text("You can't sell more stocks than you own.")
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            Stepper("", value: $stocksToBuy, in: 1...Int.max)
                .labelsHidden()
                .fixedSize(horizontal: true, vertical: false)
            VStack(alignment: .leading, spacing: 8) {
                Text("Stocks to buy:")
                    .font(.title3)
                NumberTextField(value: $stocksToBuy)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.bottom)
            HStack {
                Button(action: {
                    purchaseStock()
                }) {
                    Text("Buy Stock")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(stockManager.stocks[stockIndex].number <= 0)

                Button(action: {
                    sellStock()
                }) {
                    Text("Sell Stock")
                        .font(.title2)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(stockManager.stocksOwned[stockIndex] <= 0)
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Stock Details")
    }
    
    init(stockIndex: Int, balance: Binding<Double>, stockManager: StockManager) {
        self.stockIndex = stockIndex
        self._balance = balance
        self.stockManager = stockManager

        self._showError = .init(initialValue: stockManager.showError)
        self._showInsufficientBalance = .init(initialValue: stockManager.showInsufficientBalance)
        self._showExcessStockSaleError = .init(initialValue: stockManager.showExcessStockSaleError)
    }
    
    func purchaseStock() {
        stockManager.buyStock(stockIndex: stockIndex, quantity: stocksToBuy, balance: &balance)
    }
        
    func sellStock() {
        stockManager.sellStock(stockIndex: stockIndex, quantity: stocksToBuy, balance: &balance)
    }
}
