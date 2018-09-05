import UIKit
import CoreData

class Stock_view_controller: UIViewController {

    // MARK: Outlets
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var stockPriceLabel: UILabel!
    @IBOutlet var eps_label: UILabel!
    @IBOutlet var pe_ratio_label: UILabel!
    @IBOutlet var roe_label: UILabel!
    @IBOutlet var quantity_label: UILabel!

    // MARK: Initialized Attributes
    var selected_stock: Stock? {
        didSet {
            DispatchQueue.main.async {
                self.quantity_label.text! = "Shares in portfolio: \(self.selected_stock!.quantity)"
            }
        }
    }

    var stock_symbol_forURL: String = ""

    fileprivate let basePath = "https://api.iextrading.com/1.0"
    
    var eps_stats_container: [EPS_stat] = []
    var price_stat_container: [Price_stat] = []
    var pe_ratio_container: [P_E_ratio_stat] = []
    var roe_container: [ROE_stat] = []

    // MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        eps_stats_container = []
        price_stat_container = []
        pe_ratio_container = []
        roe_container = []
        companyNameLabel.text! = selected_stock!.name!
        stock_symbol_forURL = selected_stock!.symbol!.lowercased()
        print(stock_symbol_forURL)
        quantity_label.text! = "Shares in portfolio: \(selected_stock!.quantity)"

        
        getInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getInfo()
    }

    // MARK: Private Methods (Getting Statistics)
    private func create_EPS_object(ticket: String, completion: @ escaping ([EPS_stat]) -> ()) throws {
        let url = basePath + "/stock/" + ticket + "/earnings"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let quarters = json["earnings"] as? [[String: Any]] {
                            if let eps = quarters[0]["actualEPS"] {
                                let new_eps_stat = EPS_stat(eps: eps as? Double)
                                self.eps_stats_container.append(new_eps_stat)
                            }
                        }
                    }
                } catch { print(error.localizedDescription) }
                completion(self.eps_stats_container)
            }
        }

        task.resume()
    }
    
    private func create_price_object(ticket: String, completion: @ escaping ([Price_stat]) -> ()) throws {
        let url = basePath + "/stock/" + ticket + "/quote"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let price = json["latestPrice"] as? Double {
                            let new_price_stat = Price_stat(price: price)
                            self.price_stat_container.append(new_price_stat)
                            }
                        }
                } catch { print(error.localizedDescription) }
                completion(self.price_stat_container)
            }
        }

        task.resume()
    }
    
    private func create_PERatio_object(ticket: String, completion: @ escaping ([P_E_ratio_stat]) -> ()) throws {
        let url = basePath + "/stock/" + ticket + "/quote"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let pe_ratio = json["peRatio"] as? Double {
                            let new_PERatio_stat = P_E_ratio_stat(p_e_ratio: pe_ratio)
                            self.pe_ratio_container.append(new_PERatio_stat)
                        }
                    }
                } catch { print(error.localizedDescription) }
                completion(self.pe_ratio_container)
            }
        }

        task.resume()
    }
    
    private func create_ROE_object(ticket: String, completion: @ escaping ([ROE_stat]) -> ()) throws {
        let url = basePath + "/stock/" + ticket + "/stats"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let roe = json["returnOnEquity"] as? Double {
                            let new_ROE_stat = ROE_stat(roe: roe)
                            self.roe_container.append(new_ROE_stat)
                        }
                    }
                } catch { print(error.localizedDescription) }
                completion(self.roe_container)
            }
        }

        task.resume()
    }

    private func getInfo() {
        do {
            try create_EPS_object(ticket: stock_symbol_forURL) { (results: [EPS_stat]) in
                DispatchQueue.main.async {
                    if results.count == 0 {
                        self.eps_label.text = ""
                    } else if results[0].eps == nil {
                        self.eps_label.text = ""
                    } else {
                        self.eps_label.text = "Previous quarter earnings per share (EPS): " + (String(results[0].eps!))
                    }
                }
            }
        } catch { print(error.localizedDescription) }


        do {
            try create_price_object(ticket: stock_symbol_forURL) { (results: [Price_stat]) in
                DispatchQueue.main.async {
                    self.stockPriceLabel.text = "Latest price: " + String(results[0].price!) + "*"
                }
            }
        } catch { print(error.localizedDescription) }


        do {
            try create_PERatio_object(ticket: stock_symbol_forURL) { (results: [P_E_ratio_stat]) in
                DispatchQueue.main.async {
                    if results.count == 0 {
                        self.pe_ratio_label.text = ""
                    }
                    else {
                        self.pe_ratio_label.text = "P/E Ratio: " + (String(results[0].p_e_ratio!))
                    }
                }
            }
        } catch { print(error.localizedDescription) }


        do {
            try create_ROE_object(ticket: stock_symbol_forURL) { (results: [ROE_stat]) in
                DispatchQueue.main.async {
                    if results.count == 0 {
                        self.roe_label.text = ""
                    }
                    else {
                        self.roe_label.text = "Return on equity (ROE): " + (String(results[0].roe!))
                    }
                }
            }
        } catch { print(error.localizedDescription) }
    }
    
    
    //MARK:Event Methods
    
    
    @IBAction func linkClicked(sender: Any) {
        let link = "https://iextrading.com/developer/"
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func statsLinkClicked(sender: Any) {
        let link = "https://finance.yahoo.com/quote/" + selected_stock!.symbol!.uppercased()
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:])
        }
    }


    @IBAction func transactionButtonPressed(sender: Any) {
        let transactionAlert: UIAlertController = UIAlertController(title: nil, message: "Would you like to buy or sell?", preferredStyle: .alert)
        let buyAction: UIAlertAction = UIAlertAction(title: "Buy", style: .default) { (buyAction) in
            self.buyAlert()
        }

        let sellAction: UIAlertAction = UIAlertAction(title: "Sell", style: .default) { (sellAction) in
            self.sellAlert()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        transactionAlert.addAction(buyAction)
        transactionAlert.addAction(sellAction)
        transactionAlert.addAction(cancelAction)
        self.present(transactionAlert, animated: true)
    }

    func buyAlert() {
        let buy_alert: UIAlertController = UIAlertController(title: "Buy Stock", message: "How many shares would you like to buy?", preferredStyle: .alert)
        buy_alert.addTextField { (textfield) -> Void in
        }

        let buyAction: UIAlertAction = UIAlertAction(title: "Buy", style: .default) { (buyAction) -> Void in
            let textf = buy_alert.textFields![0] as UITextField
            guard let user_int = Int(textf.text!) else {
                invalidInputAlert(controller: self)

                return
            }

            if (self.price_stat_container[0].price! * Double(user_int)) > account_container[0].balance {
                insufficientFundsAlert(controller: self)
                return
            } else if user_int < 1 {
                invalidInputAlert(controller: self)
            } else {
                self.buyStockTransaction(stock: self.selected_stock!, quantity: user_int)
            }
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default)
        buy_alert.addAction(buyAction)
        buy_alert.addAction(cancelAction)
        self.present(buy_alert, animated: true)
    }

    func sellAlert() {
        let sell_alert: UIAlertController = UIAlertController(title: "Sell Stock", message: "How many shares would you like to sell?", preferredStyle: .alert)
        sell_alert.addTextField { (textfield) -> Void in
        }

        let sellAction: UIAlertAction = UIAlertAction(title: "Sell", style: .default) { (buyAction) -> Void in
            let textf = sell_alert.textFields![0] as UITextField
            guard let user_int = Int(textf.text!) else {
                invalidInputAlert(controller: self)

                return
            }

            if Int32(user_int) > (self.selected_stock!.quantity) {
                insufficientSharesAlert(controller: self)
                return
            } else if user_int < 1 {
                invalidInputAlert(controller: self)
            } else {
                self.sellStockTransaction(stock: self.selected_stock!, quantity: user_int)
            }
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default)
        sell_alert.addAction(sellAction)
        sell_alert.addAction(cancelAction)
        self.present(sell_alert, animated: true)
    }

    // MARK: Transaction Methods

    func stockTransactionWebRequest(stock: Stock, quantity: Int, completion: @ escaping (Int, Double) -> ()) {
        let url = basePath + "/stock/" + stock.symbol!.lowercased() + "/quote"
        /*let urlLink: URL? = URL(string: url)
         if urlLink == nil {
         self.invalidStockAlert()
         completion(nil)
         return
         }*/
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

    func buyStockTransaction(stock: Stock, quantity: Int) {
        stockTransactionWebRequest(stock: stock, quantity: quantity) { (numberOfShares: Int, stockPrice: Double) -> () in
            account_container[0].balance -= (stockPrice * Double(quantity))
            stock.quantity = Int32(Int(stock.quantity) + quantity)
            DispatchQueue.main.async {
                self.quantity_label.text! = "Shares in portfolio: \(self.selected_stock!.quantity)"
            }
            do {
                try context1.save()
            } catch { print(error.localizedDescription) }
        }
    }

    func sellStockTransaction(stock: Stock, quantity: Int) {
        if quantity == stock.quantity {
            account_container[0].balance += (price_stat_container[0].price! * Double(quantity))
            do {
                try context1.save()
            } catch {
                print(error.localizedDescription)
            }

            self.navigationController?.unwind(for: UIStoryboardSegue(identifier: "root-to-detail", source: self.navigationController!.viewControllers.first!, destination: self), towardsViewController: self.navigationController!.viewControllers.first!)
            context1.delete(selected_stock!)
            do {
                try context1.save()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            stockTransactionWebRequest(stock: stock, quantity: quantity) { (numberOfShares: Int, stockPrice: Double) -> () in
                account_container[0].balance += (stockPrice * Double(quantity))
                stock.quantity = Int32(Int(stock.quantity) - quantity)
                DispatchQueue.main.async{
                    self.quantity_label.text! = "Shares in portfolio: \(self.selected_stock!.quantity)"
                }
                do {
                    try context1.save()
                } catch { print(error.localizedDescription) }
            }
        }
    }
}
