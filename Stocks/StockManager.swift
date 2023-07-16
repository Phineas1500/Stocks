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
        "55c7601f-8c89-403c-8561-ee1d54689010",
        "b68de4c0-3bc8-431a-b697-5e8a90749979",
        "968a2c1c-611f-406d-9f6e-bda2bd94fcc3"
    ]
    
    let stockNames = [
        "55c7601f-8c89-403c-8561-ee1d54689010": "ABC",
        "b68de4c0-3bc8-431a-b697-5e8a90749979": "XYZ",
        "968a2c1c-611f-406d-9f6e-bda2bd94fcc3": "MMM"
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
                    } else {
                        self.stocks[index].lastNumber = self.stocks[index].number
                        self.stocks[index].number = updatedStock.number
                    }
                }
                .store(in: &cancellables)
        }
    }
}
