//
//  ViewController.swift
//  inveseting_take_2
//
//  Created by Brian Bouchard on 8/20/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var stocks: [Stock] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var tableView: UITableView!
    
    let basePath = "https://api.iextrading.com/1.0"
    
    func create_stock(withTicket ticket: String, completion: @ escaping ([Stock]) -> ()) throws {
        let url = basePath + "/stock/" + ticket + "/quote"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let new_stock = try Stock(json: json)
                        self.stocks.append(new_stock)
                    }
                } catch { print(error.localizedDescription) }
                completion(self.stocks)
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(sender: Any) {
        if let newText = textField.text {
            if newText != "" {
                do {
                    try create_stock(withTicket: newText) { (result: [Stock]) in
                        return }
                } catch { print ("error") }
            }
        }
        textField.text = ""
        textField.resignFirstResponder()
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
        return cell
    }
}
