//
//  Company.swift
//  ФоминКА
//
//  Created by Константин Фомин on 14.09.2018.
//  Copyright © 2018 Константин. All rights reserved.
//

import UIKit

class Company: NSObject {
    
    var companyName: String
    var symbol: String
    var price : String
    var priceChange: String
    var openPrice: String
    
    init(companyName: String, symbol : String, price: String, priceChange: String, openPrice: String) {
        self.companyName = companyName
        self.symbol = symbol
        self.price = price
        self.priceChange = priceChange
        self.openPrice = openPrice
    }

}
