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
    
    @IBOutlet var companyLogoUIImageView: UIImageView!
    private var companies = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.companyPickerView.dataSource = self as UIPickerViewDataSource
        self.companyPickerView.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        
            ApiService.shared.getCompanyNames() {
                responce, error  in
                if error != nil{
                    self.showAlert(message: "Network Error.")
                }
                else {
                    self.UpdatePickerValues(json: responce)
                    self.companyPickerView.reloadAllComponents()
                    self.requestQuoteUpdate()
                    self.activityIndicator.stopAnimating()
                }

            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func UpdatePickerValues(json: [[String:Any]]){
        companies = [String:String]()
        for company in json{
            let companyName = company["companyName"]! as! String
            let companySymbol = company["symbol"]! as! String
            companies[companyName] = companySymbol
        }
    }
    
    

    private func showAlert(message: String){
        let alert = UIAlertController(title: "Error.", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
                showAlert(message: "Network Error.")
                print("Invalid json")
                return
                }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol: symbol, price: price, priceChange: priceChange, openPrice: openPrice)
                
            }
            
        } catch {
                showAlert(message: "Network Error.")
                print("Json Parsing Error.")
            }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double, openPrice: Double){
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.symbolLabel.text = symbol

        if price > openPrice{
            self.priceLabel.text = "\(price)"
            self.priceLabel.textColor = UIColor.green
        }
        else if price < openPrice  {
            self.priceLabel.text = "\(price)"
            self.priceLabel.textColor = UIColor.red
        }
        else {
            self.priceLabel.text = "\(price)"
            self.priceLabel.textColor = UIColor.black
        }
        
        self.priceChangeLabel.text = "\(priceChange)"
        
            ApiService.shared.getUrlOfLogo(for: symbol){
                url,error in
                if error != nil{
                    self.showAlert(message: "Can not download image.")
                }
                else {
                    self.companyLogoUIImageView.imageFromServerURL(urlString: url)
                    print(url)
                }

            }

//        self.view.backgroundColor = self.companyLogoUIImageView.image?.getPixelColor().withAlphaComponent(4)//for best times

    }
    
    private func requestQuoteUpdate() {

        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.symbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        
        ApiService.shared.requestQuote(for: selectedSymbol){ data, error in
            if error != nil {
                self.showAlert(message: "Network Problems")
            }
            else {
                self.parseJson(data: data)
            }
        }

        
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
        self.companyLogoUIImageView.layer.cornerRadius = 45.0
        self.companyLogoUIImageView.layer.masksToBounds = true
        self.companyLogoUIImageView.layer.borderWidth = 2.0
        self.companyLogoUIImageView.layer.borderColor = UIColor.black.cgColor
        self.requestQuoteUpdate()
    }

}

