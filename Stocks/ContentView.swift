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

    var body: some View {
        NavigationView {
            List {
                Text("Balance: $\(balance, specifier: "%.2f")")
                    .font(.title2)
                    .padding()
                
                ForEach(stockManager.stocks.indices, id: \.self) { index in
                    NavigationLink(destination: StockDetailView(stockIndex: index,
                                                                balance: $balance,
                                                                stockManager: stockManager)) {
                        HStack {
                            Text(stockManager.stocks[index].id)
                            Spacer()
                            Text("$\(stockManager.stocks[index].number, specifier: "%.2f")")
                            Spacer()
                            Text("Owned: \(stockManager.stocksOwned[index])")
                        }
                    }
                }

                NavigationLink(destination: PortfolioView(stocksOwned: $stockManager.stocksOwned,
                                                          stockManager: stockManager,
                                                          balance: $balance)) {
                    Text("View Portfolio")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

            }
            .navigationTitle("Stock Market")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
