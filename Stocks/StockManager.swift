import Foundation
import Combine

class StockManager: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var stocksOwned: [Int] = []
    @Published var showError: Bool = false
    @Published var showInsufficientBalance: Bool = false
    @Published var showExcessStockSaleError: Bool = false
    private var cancellables: [AnyCancellable] = []
    private var timer: Timer? = nil

    let stockIds = [
        "6f544619-ece3-44fa-b1d9-9a26d0011f7a",
        "4d1b94a1-4e0e-4851-bfb4-b9ed4c26c9bf",
        "be383b41-ca73-463d-9ac2-e9b844299900"
    ]
    
    let stockNames = [
        "6f544619-ece3-44fa-b1d9-9a26d0011f7a": "ABC",
        "4d1b94a1-4e0e-4851-bfb4-b9ed4c26c9bf": "XYZ",
        "be383b41-ca73-463d-9ac2-e9b844299900": "MMM"
    ]

    func stockLabelFor(id: String) -> String {
        return stockNames[id] ?? "Unknown"
    }

    init() {
        self.stocksOwned = Array(repeating: 0, count: stockIds.count) // Initialize stocksOwned with correct length
        self.startFetchingStockData()
    }

    func buyStock(stockIndex: Int, quantity: Int, balance: inout Double) {
        let stockPrice = stocks[stockIndex].number * Double(quantity)
        if quantity < 1 {
            self.showError = true
            return
        } else if balance < stockPrice {
            self.showInsufficientBalance = true
            return
        } else {
            balance -= stockPrice
            stocksOwned[stockIndex] += quantity
            self.showError = false
            self.showInsufficientBalance = false
        }
    }

    func sellStock(stockIndex: Int, quantity: Int, balance: inout Double) {
        let stockPrice = stocks[stockIndex].number * Double(quantity)
        if stocksOwned[stockIndex] < quantity {
            self.showExcessStockSaleError = true
            return
        } else {
            balance += stockPrice
            stocksOwned[stockIndex] -= quantity
            self.showExcessStockSaleError = false
        }
    }

    func startFetchingStockData() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.fetchStocks()
        }
    }

    func fetchStocks() {
        let urls = stockIds.map { URL(string: "http://localhost:8080/random_number/\($0)")! }

        urls.enumerated().forEach { index, url in
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: Stock.self, decoder: JSONDecoder())
                .replaceError(with: Stock(id: "", number: 0))
                .receive(on: DispatchQueue.main)
                .sink { [weak self] updatedStock in
                    guard let self = self else { return }
                    if index >= self.stocks.count {
                        self.stocks.append(updatedStock)
                        self.stocksOwned.append(0)
                    } else {
                        self.stocks[index] = updatedStock
                    }
                }
                .store(in: &cancellables)
        }
    }
}
