//
//  ViewController.swift
//  ФоминКА
//
//  Created by Константин Фомин on 13.09.2018.
//  Copyright © 2018 Константин. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var companyNameLabel: UILabel!
    
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceChangeLabel: UILabel!
    @IBOutlet var companyPickerView: UIPickerView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private var companies = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.companyPickerView.dataSource = self as UIPickerViewDataSource
        self.companyPickerView.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        ApiService.shared.getCompanyNames(){
            responce in
            self.UpdatePickerValues(json: responce)
            self.companyPickerView.reloadAllComponents()
            self.requestQuoteUpdate()
            self.activityIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func UpdatePickerValues(json: [[String:Any]]){
        companies = [String:String]()
        for company in json{
            var companyName = company["companyName"]! as! String
            var companySymbol = company["symbol"]! as! String
            companies[companyName] = companySymbol
        }
    }
    
    private func requestQuote(for symbol: String){
        let stockUrl = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/quote")
        
        let dataTask = URLSession.shared.dataTask(with: stockUrl!) {data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
                else {
                    print("NetworkError!")
                    return
            }
            self.parseJson(data: data)
        }
        dataTask.resume()
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
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol: symbol, price: price, priceChange: priceChange, openPrice: openPrice)
            }
            
        } catch {
                print("Json Parsing Error.")
            }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double, openPrice: Double){
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.symbolLabel.text = symbol
        switch price {
        case price > openPrice:
            self.priceLabel.text = "\(price)"
        case price == openPrice:
            self.priceLabel.text = "\(price)"
        case price < openPrice:
            self.priceLabel.text = "\(price)"
        default:
            print("Nothing")
        }
        self.priceChangeLabel.text = "\(priceChange)"
    }
    
    private func requestQuoteUpdate() {

        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.symbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }


}

