import UIKit
import CoreData

var account_container: [Account] = []

let context1 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
let basePath = "https://api.iextrading.com/1.0"


class MainViewController: UIViewController, UITextFieldDelegate {
    

  
    // MARK: Outlets

    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var accountLabel: UILabel!


    var stocks: [Stock] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    // MARK: View Controller Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
        account_container = []
        let request1: NSFetchRequest<Account> = Account.fetchRequest()

        do {
            account_container = try context1.fetch(request1)
        } catch {
            print(error.localizedDescription)
        }
        
        if account_container.count > 0 {
            print("")
        } else {
            let new_account = Account(context: context1)
            new_account.balance = 10000
            new_account.name = "MY_ACCOUNT"
            account_container.append(new_account)
            do {
                try context1.save()
            } catch { print(error.localizedDescription) }
        }

        accountLabel.text = "Account balance: $" + String(account_container[0].balance)
    }

    private func loadData() {
        let request: NSFetchRequest<Stock> = Stock.fetchRequest()
        do {
            stocks = try context1.fetch(request)
        } catch { print(error.localizedDescription) }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let request: NSFetchRequest<Stock> = Stock.fetchRequest()
        do {
            stocks = try context1.fetch(request)
        } catch { print(error.localizedDescription) }
        accountLabel.text = "Account balance: $" + String(account_container[0].balance)
        self.tableView.reloadData()
    }

    // MARK: Private Methods

    private func initializeManagedObject(json: [String: Any]) -> Stock {
        let new_stock = Stock(context: context1)
        new_stock.name = json["companyName"] as? String
        new_stock.symbol = json["symbol"] as? String
        return new_stock
    }

    private func initializeTestObject(json: [String: Any]) -> TestStock {
        let test_stock = TestStock(symbol: json["symbol"] as! String, name: json["companyName"] as! String, price: json["latestPrice"] as! Double)

        return test_stock
    }

    private func create_stock(withTicket ticket: String, quantity: Int, completion: @ escaping ([Stock]) -> ()) throws {
        if quantity < 1 {
            invalidInputAlert(controller: self)
            return
        }

        let url = basePath + "/stock/" + ticket + "/quote"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let new_stock = self.initializeManagedObject(json: json)
                        new_stock.quantity = 0
                        self.stockTransaction(stock: new_stock, quantity: quantity)
                        for item in self.stocks {
                            if item.name == new_stock.name {
                                showAlert(controller: self)
                                return
                            }
                        }

                        self.stocks.append(new_stock)
                        do {
                            try context1.save()
                        } catch { print(error.localizedDescription) }
                    }
                } catch { print(error.localizedDescription) }
                completion(self.stocks)
            }
        }

        task.resume()
    }
    
    private func checkStockValidity(withTicket ticket: String, completion: @ escaping (TestStock?) -> ()) {
        let url = basePath + "/stock/" + ticket + "/quote"
        let urlLink: URL? = URL(string: url)
        if urlLink == nil {
            invalidStockAlert(controller: self)
            completion(nil)
            return
        }
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let new_stock = self.initializeTestObject(json: json)

                        completion(new_stock)
                    }
                } catch {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        DispatchQueue.main.async {
            task.resume()
        }
    }

    func addNewSymbol()  {

        //Adds new stock when textFieldShouldReturn() or buttonPressed(Sender:) called

        if let newText = textField.text?.lowercased() {

            checkStockValidity(withTicket: newText) { (newstock: TestStock?) in
                if newstock == nil {
                    DispatchQueue.main.async {
                        invalidStockAlert(controller: self)
                    }
                    return
                }

                //Checks for duplicates

                for item in self.stocks {
                    if item.symbol! == newText.uppercased() {
                        DispatchQueue.main.async {
                            showAlert(controller: self)
                            self.textField.text = ""
                            self.textField.resignFirstResponder()
                        }

                        return
                    }
                }

                if newText != "" {
                    let buyStockAlert = UIAlertController(title: "Buy Stock", message: "How many shares would you like to buy?", preferredStyle: .alert)
                    buyStockAlert.addTextField { (textfield) -> Void in
                    }
                    let action = UIAlertAction(title: "Buy", style: .default) { (action) -> Void in
                        let textf = buyStockAlert.textFields![0] as UITextField
                        do {
                            guard let user_int = Int(textf.text!) else {
                                invalidInputAlert(controller: self)
                                return
                            }
                            if (newstock!.price * Double(user_int)) > account_container[0].balance {
                                insufficientFundsAlert(controller: self)
                                return
                            } else {
                            try self.create_stock(withTicket: newText, quantity: user_int) { (results: [Stock]) in
                                return }
                            }
                        } catch { print(error.localizedDescription) }
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

                    buyStockAlert.addAction(action)
                    buyStockAlert.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self.present(buyStockAlert, animated: true)
                    }
                }
            }

            textField.text = ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        addNewSymbol()

        return true
    }

    // MARK: Event Methods
    @IBAction func buttonPressed(sender: Any) {
        addNewSymbol()

        textField.text = ""
        textField.resignFirstResponder()
    }

    // MARK: Storyboard Nav Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondScene = segue.destination as! Stock_view_controller
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedStock = stocks[indexPath.row]
            secondScene.selected_stock = selectedStock
        }
    }
}

// MARK: TableView Methods

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = stocks[indexPath.row].name
        cell.detailTextLabel?.text = stocks[indexPath.row].symbol
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Transaction Methods

extension MainViewController {
    func stockTransactionWebRequest(stock: Stock, quantity: Int, completion: @ escaping (Int, Double) -> ()) {
    let url = basePath + "/stock/" + stock.symbol!.lowercased() + "/quote"
    let request = URLRequest(url: URL(string: url)!)
    let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let stock_price = json["latestPrice"] as! Double
                    completion(quantity, stock_price)
                }
            } catch { print(error.localizedDescription) }
        }
    }

    task.resume()

    }

    func stockTransaction(stock: Stock, quantity: Int) {
        stockTransactionWebRequest(stock: stock, quantity: quantity) { (numberOfShares: Int, stockPrice: Double) -> () in
            if account_container[0].balance < (stockPrice * Double(quantity)) {
                insufficientFundsAlert(controller: self)
                return

            } else {
                account_container[0].balance -= (stockPrice * Double(quantity))
                stock.quantity = Int32(Int(stock.quantity) + quantity)
                do {
                    try context1.save()
                } catch { print(error.localizedDescription) }
                DispatchQueue.main.async {
                    self.accountLabel.text = "Account balance: $" + String(account_container[0].balance)
                }
            }
        }
    }
 }
