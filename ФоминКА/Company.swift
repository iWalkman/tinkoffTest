//
//  Company.swift
//  ФоминКА
//
//  Created by Константин Фомин on 14.09.2018.
//  Copyright © 2018 Константин. All rights reserved.
//

import UIKit

class Company: NSObject {
    
    var companyName: String? = nil
    var symbol: String? = nil
    var price : Double? = nil
    var priceChange: Double? = nil
    var openPrice: Double? = nil
    
    
    
    init(data: Data) {
        super.init()
        parseJson(data: data)
    }
    
    
    
    private func parseJson(data: Data){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let symbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let openPrice = json["open"] as? Double,
                let priceChange = json["change"] as? Double
                else {
                    print("Invalid json")
                    return
            }
            self.companyName = companyName
            self.symbol = symbol
            self.price = price
            self.priceChange = priceChange
            self.openPrice = openPrice
            
        } catch {
            print("Json Parsing Error.")
        }
    }
    
    
    

}
