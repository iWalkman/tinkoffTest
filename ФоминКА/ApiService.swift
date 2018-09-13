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
    
    func getCompanyNames(completionHandler: @escaping ([[String:Any]]) -> (Void)){
        let apiAdress = "https://api.iextrading.com/1.0/stock"
        let companyesInfo = "/market/list/infocus"
        
        let companyNanmesUrl = URL(string: apiAdress + companyesInfo)
        
        let dataTask = URLSession.shared.dataTask(with: companyNanmesUrl!) {data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("NetworkError!")
                    return
            }
            
//            var companyesDict = [String:Any]()
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard
                    let json = jsonObject as? [[String: Any]]
                    else {
                        print("Invalid json")
                        return
                }
                completionHandler(json)
                
            } catch {
                print("Json Parsing Error.")
            }
        }
        dataTask.resume()
    }
    
}
