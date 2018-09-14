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
                    completionHandler("", error)
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
                completionHandler(json["url"]!, nil)
                
            } catch {
                print("Json Parsing Error.")
            }
        }
        dataTask.resume()
    }
    
    func getPricesOfStock(for symbol: String,completionHandler: @escaping ([String:Any], Error?) -> (Void)){
        let budsUrl = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/book")
        print(budsUrl)
        let dataTask = URLSession.shared.dataTask(with: budsUrl!) {data, response, error in
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
                let json = jsonObject as? [[String: [String: Any]]]
                    
                    else {
                        print("Invalid json")
                        return
                }
                for obj in json{
                    print(obj)
                }
                print(json)
                completionHandler(json[1]["bids"]!, nil)
                
            } catch {
                print("Json Parsing Error.")
            }
        }
        dataTask.resume()
    }
    
    func requestQuote(for symbol: String, completionHandler: @escaping (Data, Error?) -> (Void)){
        let stockUrl = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/quote")
        
        let dataTask = URLSession.shared.dataTask(with: stockUrl!) {data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    completionHandler(Data(), error)
                    print("NetworkError!")
                    return
            }
            completionHandler(data, nil)

        }
        dataTask.resume()
    }
    
}
