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
    
    private func displayStockInfo(company: Company){
        
        self.companyNameLabel.text = company.companyName
        self.symbolLabel.text = company.symbol

        if company.price! > company.openPrice!{
            self.priceLabel.text = "\(company.price!)"
            self.priceLabel.textColor = UIColor.green
        }
        else if company.price! < company.openPrice!  {
            self.priceLabel.text = "\(company.price!)"
            self.priceLabel.textColor = UIColor.red
        }
        else {
            self.priceLabel.text = "\(company.price!)"
            self.priceLabel.textColor = UIColor.black
        }
        
        self.priceChangeLabel.text = "\(company.priceChange!)"
        
        ApiService.shared.getUrlOfLogo(for: company.symbol!){
                url,error in
                if error != nil{
                    self.showAlert(message: "Can not download image.")
                }
                else {
                    self.companyLogoUIImageView.imageFromServerURL(urlString: url)
                    print(url)
                }

            }
        self.companyLogoUIImageView.layer.cornerRadius = 45.0
        self.companyLogoUIImageView.layer.masksToBounds = true
        self.companyLogoUIImageView.layer.borderWidth = 2.0
        self.companyLogoUIImageView.layer.borderColor = UIColor.black.cgColor
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
                DispatchQueue.main.async {
                    self.displayStockInfo(company: data)
                    self.activityIndicator.stopAnimating()
                }
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
        self.requestQuoteUpdate()
    }

}

