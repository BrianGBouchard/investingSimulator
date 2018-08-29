//
//  Stock_view_controller.swift
//  inveseting_take_2
//
//  Created by Brian Bouchard on 8/21/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit
import CoreData

class Stock_view_controller: UIViewController {
    
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var stockPriceLabel: UILabel!
    @IBOutlet var eps_label: UILabel!
    @IBOutlet var pe_ratio_label: UILabel!
    @IBOutlet var roe_label: UILabel!
    
    //let context2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext do I need core data?
    
    var selected_stock: Stock?
    var stock_symbol_forURL: String = ""
    
    fileprivate let basePath = "https://api.iextrading.com/1.0"
    
    var eps_stats_container: [EPS_stat] = []
    var price_stat_container: [Price_stat] = []
    var pe_ratio_container: [P_E_ratio_stat] = []
    var roe_container: [ROE_stat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eps_stats_container = []
        price_stat_container = []
        pe_ratio_container = []
        roe_container = []
        companyNameLabel.text! = selected_stock!.name!
        stock_symbol_forURL = selected_stock!.symbol!.lowercased()
        print(stock_symbol_forURL)
        
        
        do {
            try create_EPS_object(ticket: stock_symbol_forURL) { (results: [EPS_stat]) in
                DispatchQueue.main.async {
                    if results.count == 0 {
                        self.eps_label.text = ""
                    }
                    else {
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
    
    func create_EPS_object(ticket: String, completion: @ escaping ([EPS_stat]) -> ()) throws {
        let url = basePath + "/stock/" + ticket + "/earnings"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let quarters = json["earnings"] as? [[String: Any]] {
                            if let eps = quarters[0]["actualEPS"] {
                                let new_eps_stat = EPS_stat(eps: eps as! Double)
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
    
    func create_price_object(ticket: String, completion: @ escaping ([Price_stat]) -> ()) throws {
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
    
    func create_PERatio_object(ticket: String, completion: @ escaping ([P_E_ratio_stat]) -> ()) throws {
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
    
    func create_ROE_object(ticket: String, completion: @ escaping ([ROE_stat]) -> ()) throws {
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
    
    
}
