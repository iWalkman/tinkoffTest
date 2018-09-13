//
//  ApiService.swift
//  ФоминКА
//
//  Created by Константин Фомин on 13.09.2018.
//  Copyright © 2018 Константин. All rights reserved.
//

import UIKit

class ApiService: NSObject {
    
    static let shared = ApiService()
    
    func getCompanyNames(completionHandler: @escaping ([[String:Any]], Error?) -> (Void))  {
        let apiAdress = "https://api.iextrading.com/1.0/stock"
        let companyesInfo = "/market/list/infocus"
        
        let companyNanmesUrl = URL(string: apiAdress + companyesInfo)
        
        let dataTask = URLSession.shared.dataTask(with: companyNanmesUrl!) {data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    completionHandler([["":""]], error)
                    print("NetworkError!")
                    return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [[String: Any]]
                    else {
                        print("Invalid json")
                        return
                }
                completionHandler(json, nil)
                
            } catch {
                print("Json Parsing Error.")
            }
        }
        dataTask.resume()
    }
    
    func getUrlOfLogo(for symbol: String,completionHandler: @escaping (String, Error?) -> (Void)){
        let imageUrl = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/logo")
        
        
        let dataTask = URLSession.shared.dataTask(with: imageUrl!) {data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("NetworkError!")
                    return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [String: String]
                    else {
                        print("Invalid json")
                        return
                }
                completionHandler(json["url"]!)
                
            } catch {
                print("Json Parsing Error.")
            }
        }
        dataTask.resume()
    }
    
    func getPricesOfStock(for symbol: String,completionHandler: @escaping (String) -> (Void)){
        let imageUrl = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/book")
        let dataTask = URLSession.shared.dataTask(with: imageUrl!) {data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("NetworkError!")
                    return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [String: String]
                    else {
                        print("Invalid json")
                        return
                }
                completionHandler(json["url"]!)
                
            } catch {
                print("Json Parsing Error.")
            }
        }
    }
    
}
