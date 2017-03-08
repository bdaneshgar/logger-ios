//
//  ViewController.swift
//  Logger
//
//  Created by Brian Daneshgar on 3/3/17.
//  Copyright © 2017 Brian Daneshgar. All rights reserved.
//

import UIKit
import CoreTelephony
import MessageUI


class ViewController: UIViewController, MFMailComposeViewControllerDelegate  {

    @IBOutlet var tableView: UITableView!
   
    
    var logs: [String] = []
    var prevLog: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let timer =  Timer.scheduledTimer(timeInterval: 2,
                                          target: self,
                                          selector: #selector(self.update),
                                          userInfo: nil,
                                          repeats: true)
        timer.fire()
        
    }
    
    func update(){
        let newLog = "\(mnc()), \(mcc()), \(carrier()), \(radioTech()), \(status())"
        
        if(prevLog != newLog){
            prevLog = newLog
            logs.append("\(time()): \(newLog)")
            tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.global(qos: .background).async {
            let indexPath = IndexPath(row: self.logs.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func time()-> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateFormatter.string(from: NSDate() as Date)
    
    }
    
    func mnc()-> String{
        let networkInfo = CTTelephonyNetworkInfo()
        if let countryCode: String = (networkInfo.subscriberCellularProvider?.mobileCountryCode) {
            return countryCode
        } else{
            return "N/A"
        }
    }
    
    func mcc()-> String{
        let networkInfo = CTTelephonyNetworkInfo()
        if let networkCode: String = (networkInfo.subscriberCellularProvider?.mobileNetworkCode){
            return networkCode
        } else {
            return "N/A"
        }
    }
    
    func carrier()-> String{
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrierStr: String = (networkInfo.subscriberCellularProvider?.carrierName){
            return carrierStr
        } else{
            return "N/A"
        }
    }
    
    func radioTech()-> String{
        
        let networkInfo = CTTelephonyNetworkInfo()
        var radTech2 = networkInfo.currentRadioAccessTechnology
        if radTech2 != nil{
            let radTechArr = Array(radTech2!.characters)
            let tech = radTech2![radTech2!.characters.index(radTech2!.startIndex, offsetBy: 23)...radTech2!.characters.index(radTech2!.startIndex, offsetBy: radTechArr.count - 1)]
            
            if(tech == "HSDPA"){
                return "HSPDA 3.5G"
            }
            else if(tech == "CDMA1x"){
                return "CDMA 1x"
            }
            else if(tech == "eHRPD"){
                return "HRPD 3G"
            }
            else if(tech == "EDGE"){
                return "EDGE 2.5G"
            }
            else if(tech == "GPRS"){
                return "GPRS 2G"
            }
            else if(tech == "LTE"){
                return "4G LTE"
            } else {
                return tech
            }
        } else{
            return "N/A"
        }
    }
    
    func status()-> String{
        if(mcc() == "N/A" && mnc() == "N/A"){
            return "Emergency Calls Only"
        } else if(radioTech() != "N/A"){
            return "Registered"
        }
        else{
            return "No Network"
        }
    }
    
    @IBAction func sendMail(_ sender: Any) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func logsToString()-> String{
        var email = ""
        for log in logs{
            email.append("\(log)\n")
        }
        return email
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([])
        mailComposerVC.setSubject("Testing Log Report")
        mailComposerVC.setMessageBody(logsToString(), isHTML: false)
        
        return mailComposerVC
    }
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Getting the right element
        let log = logs[indexPath.row]
        
        // Instantiate a cell
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        // Adding the right informations
        cell.textLabel?.text = log
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 11.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        
        // Returning the cell
        return cell
    }
    
}

