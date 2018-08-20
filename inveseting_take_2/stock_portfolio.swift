//
//  stock_portfolio.swift
//  inveseting_take_2
//
//  Created by Brian Bouchard on 8/20/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import Foundation

struct Stock {
    var name: String
    var symbol: String
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json: [String: Any]) throws {
        guard let name = json["companyName"] as? String else {
            throw SerializationError.missing("missing data") }
        guard let symbol = json["symbol"] as? String else {
            throw SerializationError.missing("missing data")
        }
        
        self.name = name
        self.symbol = symbol
    }
}

    

