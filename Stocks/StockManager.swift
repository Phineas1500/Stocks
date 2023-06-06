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
        "7e153615-1f25-4539-a595-db7e0d26cc2c",
        "57e5b4ec-2b71-43c8-a475-56ce7b647d07",
        "578a5aaf-79cb-4a06-85e1-dec882e90faf"
    ]

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
