//
//  ViewController.swift
//  inveseting_take_2
//
//  Created by Brian Bouchard on 8/20/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    
    var account_container: [Account] = []
    
    let context1 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var accountLabel: UILabel!
    
    let basePath = "https://api.iextrading.com/1.0"
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
        
        account_container = []
        let request1: NSFetchRequest<Account> = Account.fetchRequest()
        do {
            account_container = try context1.fetch(request1)
        } catch { print(error.localizedDescription) }
        if account_container.count > 0 {
            print("")
        }
        else {
            var new_account = Account(context: context1)
            new_account.balance = 10000
            new_account.name = "MY_ACCOUNT"
            account_container.append(new_account)
            do {
                try context1.save()
            } catch { print(error.localizedDescription) }
            
        }
        accountLabel.text = "Account balance: $" + String(account_container[0].balance)
    }
    
    func loadData() {
        let request: NSFetchRequest<Stock> = Stock.fetchRequest()
        do {
            stocks = try context1.fetch(request)
        } catch { print(error.localizedDescription) }
    }
    
    
    func initializeManagedObject(json: [String: Any]) -> Stock {
        let new_stock = Stock(context: context1)
        new_stock.name = json["companyName"] as! String
        new_stock.symbol = json["symbol"] as! String
        return new_stock
    }
    
    func create_stock(withTicket ticket: String, quantity: Int, completion: @ escaping ([Stock]) -> ()) throws {
        if quantity < 1 {
            self.invalidInputAlert()
            return
        }
        let url = basePath + "/stock/" + ticket + "/quote"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let new_stock = self.initializeManagedObject(json: json)
                        /*for item in self.stocks {
                            if item.name == new_stock.name {
                                self.showAlert()
                                return
                            }
                        } */
                        self.stocks.append(new_stock)
                        do {
                            try self.context1.save()
                        } catch { print(error.localizedDescription) }
                    }
                } catch { print(error.localizedDescription) }
                completion(self.stocks)
            }
        }
        task.resume()
    }
    
/*    func checkStockValidity(withTicket ticket: String) -> Int {
        var result: Int
        let url = basePath + "/stock/" + ticket + "/quote"
        let url_link: URL? = URL(string: url)
        if url_link == nil {
            result = 0
        }
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                result = 1
            } else { result = 0 }
        }
        DispatchQueue.main.async{
            task.resume()
            return result
        }
    }
    
    func checkStockValidity(withTicket ticket: String, completion: @ escaping (Stock) -> ()) {
        let url = basePath + "/stock/" + ticket + "/quote"
        var urlLink: URL? = URL(string: url)
        if urlLink == nil {
            self.invalidStockAlert()
            return
        }
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let new_stock = self.initializeManagedObject(json: json)
                        completion(new_stock)
                    }
                } catch { self.invalidStockAlert() }
            } else { self.invalidStockAlert() }
        }
        DispatchQueue.main.async {
            task.resume()
        }
 } */
    
    


    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let newText = textField.text?.lowercased() {
            
            for item in self.stocks {
                if item.symbol! == newText.uppercased() {
                    self.showAlert()
                    textField.text = ""
                    textField.resignFirstResponder()
                    return false
                }
            }
            
            if newText != "" {
                var buyStockAlert = UIAlertController(title: "Buy Stock", message: "How many shares would you like to buy?", preferredStyle: .alert)
                buyStockAlert.addTextField { (textfield) -> Void in
                }
                var action = UIAlertAction(title: "Buy", style: .default) { (action) -> Void in
                    let textf = buyStockAlert.textFields![0] as UITextField
                    do {
                        guard let user_int = Int(textf.text!) else {
                            self.invalidInputAlert()
                            return
                        }
                        try self.create_stock(withTicket: newText, quantity: user_int) { (results: [Stock]) in
                            return }
                    } catch { print(error.localizedDescription) }
                }
                var cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert) -> Void in
                }
                
                buyStockAlert.addAction(action)
                buyStockAlert.addAction(cancelAction)
                self.present(buyStockAlert, animated: true)
            }
        }
        textField.text = ""
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func buttonPressed(sender: Any) {
        if let newText = textField.text?.lowercased() {
            
            for item in self.stocks {
                if item.symbol! == newText.uppercased() {
                    self.showAlert()
                    return
                }
                
            }
            
            if newText != "" {
                var buyStockAlert = UIAlertController(title: "Buy Stock", message: "How many shares would you like to buy?", preferredStyle: .alert)
                buyStockAlert.addTextField { (textfield) -> Void in
                }
                var action = UIAlertAction(title: "Buy", style: .default) { (action) -> Void in
                    let textf = buyStockAlert.textFields![0] as UITextField
                    do {
                        guard let user_int = Int(textf.text!) else {
                            self.invalidInputAlert()
                            return
                        }
                        try self.create_stock(withTicket: newText, quantity: user_int) { (results: [Stock]) in
                            return }
                    } catch { print(error.localizedDescription) }
                }
                var cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert) -> Void in
                }
                
                buyStockAlert.addAction(action)
                buyStockAlert.addAction(cancelAction)
                self.present(buyStockAlert, animated: true)
                /*do {
                    try create_stock(withTicket: newText) { (result: [Stock]) in
                        return }
                } catch { print ("error") } */
            }
        }
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var secondScene = segue.destination as! Stock_view_controller
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedStock = stocks[indexPath.row]
            secondScene.selected_stock = selectedStock
        }
    }
}




extension ViewController: UITableViewDataSource {
    
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController {
    
    //Defines alerts for user errors
    
    func showAlert() {
        let alert: UIAlertController = UIAlertController(title: "Stock already in Portfolio", message: "Click on stock to buy or sell", preferredStyle: .alert)
        let action1: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action1)
        self.present(alert, animated: true)
        
    }
    
    func showInsufficientFundsAlert() {
        let accountAlert: UIAlertController = UIAlertController(title: "Error", message: "Insufficient funds in account", preferredStyle: .alert)
        let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
        accountAlert.addAction(action1)
        self.present(accountAlert, animated: true)
    }
    
    func invalidInputAlert() {
        let inputAlert: UIAlertController = UIAlertController(title: "Error", message: "Number must be a positive integer", preferredStyle: .alert)
        let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
        inputAlert.addAction(action1)
        self.present(inputAlert, animated: true)
    }
    
    func invalidStockAlert() {
        let stockAlert: UIAlertController = UIAlertController(title: "Error", message: "Please enter a valid stock symbol", preferredStyle: .alert)
        let action1: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel)
        stockAlert.addAction(action1)
        self.present(stockAlert, animated: true)
    }
    
}
