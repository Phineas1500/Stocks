//
//  ContentView.swift
//  Stocks
//
//  Created by Sriram Kiron on 4/9/23.
//

import SwiftUI

struct NumberTextField: UIViewRepresentable {
    @Binding var value: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .numberPad
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = "\(value)"
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NumberTextField

        init(_ parent: NumberTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let newValue = Int((textField.text ?? "") + string) {
                parent.value = newValue
                return true
            }
            return false
        }
    }
}

import SwiftUI

struct ContentView: View {
    @ObservedObject var stockManager = StockManager()
    @State private var balance: Double = 100_000
    @State private var stocksToBuy: [Int] = [1, 1]
    @State private var showInsufficientBalance: Bool = false
    @State private var showError: Bool = false
    @State private var stocksOwned: [Int] = [0, 0]

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Text("Balance: $\(balance, specifier: "%.2f")")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                ForEach(stockManager.stocks.indices) { index in
                    let stock = stockManager.stocks[index]
                    let stockLabel = index == 0 ? "ABC" : "XYZ"
                    VStack {
                        Text("\(stockLabel): $\(stock.number, specifier: "%.2f")")
                            .font(.largeTitle)
                            .padding()
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
                        HStack {
                            Stepper("", value: $stocksToBuy[index], in: 1...Int.max)
                                .labelsHidden()
                                .fixedSize(horizontal: true, vertical: false)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stocks to buy:")
                                    .font(.title3)
                                NumberTextField(value: $stocksToBuy[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .padding(.bottom)
                        HStack {
                            Button(action: {
                                purchaseStock(stockIndex: index)
                            }) {
                                Text("Buy Stock")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(stock.number == 0)

                            Button(action: {
                                sellStock(stockIndex: index)
                            }) {
                                Text("Sell Stock")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(stocksOwned[index] < 1)
                        }
                    }
                }
                Spacer()
                NavigationLink(destination: PortfolioView(stocksOwned: $stocksOwned, stockManager: stockManager, balance: $balance)) {
                    Text("View Portfolio")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                Spacer()
            }
            .padding()
            .navigationTitle("Stock Market")
        }
    }

    private func purchaseStock(stockIndex: Int) {
        if stocksToBuy[stockIndex] < 1 {
            showError = true
        } else {
            let totalCost = stockManager.stocks[stockIndex].number * Double(stocksToBuy[stockIndex])
            if balance >= totalCost {
                balance -= totalCost
                stocksOwned[stockIndex] += stocksToBuy[stockIndex]
                showInsufficientBalance = false
                showError = false
            } else {
                showInsufficientBalance = true
                showError = false
            }
        }
    }

    private func sellStock(stockIndex: Int) {
        // Check if user owns enough stocks to sell
        if stocksToBuy[stockIndex] <= stocksOwned[stockIndex] {
            let totalValue = stockManager.stocks[stockIndex].number * Double(stocksToBuy[stockIndex])
            balance += totalValue
            stocksOwned[stockIndex] -= stocksToBuy[stockIndex]
        } else {
            print("You can't sell more stocks than you own.")
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

