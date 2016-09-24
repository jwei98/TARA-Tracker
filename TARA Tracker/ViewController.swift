//
//  ViewController.swift
//  TARA Tracker
//
//  Created by Justin Wei on 8/25/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

import UIKit
import MessageUI
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate, MFMailComposeViewControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var toDoItems = [ToDoItem]()
    let screenBound = UIScreen.main.bounds
    let memory = UserDefaults.standard

    var previousMonth : Int = 0
    var previousDate : Int = 0
    var currentMonth : Int = 0
    var currentDate : Int = 0
    
    var minutesLog = [Int]() // in format: [Month, Date, YBM, Breathing, Meditation,... repeat]
    var totalMinutesLog = [0,0,0] // in format: [YBM, Breathing, Meditation]
    var listOfCells = [TableViewCell]()
    var listOfCheckmarks : [Bool] = [false,false,false]
    let listActionNames = ["Log", "Log", "Log", "Go", "Send"]
    
    var materialsPasswordEntered = false
    
    // hide status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        
        // LOADING PAST DATA
        // get last date logged and store in previousMonth & previousDate
        previousMonth = memory.integer(forKey: "previousMonth")
        previousDate = memory.integer(forKey: "previousDate")
        // get stored minutesLog
        if let temp = memory.array(forKey: "minutesLog") as? [Int] {
            minutesLog = temp
        }
        if let temp = memory.array(forKey: "totalMinutesLog") as? [Int] {
            totalMinutesLog = temp
        }
        materialsPasswordEntered = memory.bool(forKey: "materialsPasswordEntered")
        
        // get current date
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
        currentMonth = components.month!
        currentDate = components.day!
        
        // modifications based on currentDate vs. pastDate
        if currentMonth != previousMonth || currentDate != previousDate {
            // remove all checkmarks
            listOfCheckmarks = [false, false, false]
            memory.set(listOfCheckmarks, forKey: "listOfCheckmarks")
        }
        if let temp = memory.array(forKey: "listOfCheckmarks") as? [Bool] {
            listOfCheckmarks = temp
        }
        
        
        // tableView setup
        tableView.dataSource = self
        
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.gray
        tableView.alwaysBounceVertical = false
        let screenHeight = screenBound.size.height
        tableView.rowHeight = screenHeight / 5
        
        toDoItems.append(ToDoItem(text: "Yoga Based Movement"))
        toDoItems.append(ToDoItem(text: "Breathing"))
        toDoItems.append(ToDoItem(text: "Meditation"))
        toDoItems.append(ToDoItem(text: "Materials"))
        toDoItems.append(ToDoItem(text: "Submit Minutes"))

    }
    
    
    
    func toDoItemDeleted(_ toDoItem: ToDoItem) {
        let index = (toDoItems as NSArray).index(of: toDoItem)
        if index == NSNotFound { return }
        
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        toDoItems.remove(at: index)
        
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()    
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                               for: indexPath) as! TableViewCell
        let item = toDoItems[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = item.text
        cell.textLabel?.font = UIFont(name: "Ailerons-Regular", size: tableView.rowHeight/5.1)
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .none
        
        cell.delegate = self
        cell.toDoItem = item
        
        listOfCells.append(cell)
        if indexPath.row < 3 && listOfCheckmarks[indexPath.row] {
            addCheckmark(row: indexPath.row)
        }
        
        // add totalMinutesLabel
        if indexPath.row < 3 {
            cell.addTotalMinutesLabel(txt: String(totalMinutesLog[indexPath.row]))
        }
        
        cell.addActionLabel(txt: self.listActionNames[indexPath.row])
        
        return cell
    }
    
    // support for versions before iOS 8
    func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight;
    }
    
    // coloring the cells
    func colorForIndex(_ index: Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index+2) / CGFloat(itemCount)) * 0.5
        return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex((indexPath as NSIndexPath).row)
    }

    // ---------------------------------- Presenting Alerts to User ---------------------------------- //
    
    // view controller presenting alerts
    func presentAlert(_ taskName : String) {
        // cases for logging minutes
        if taskName == "Yoga Based Movement" || taskName == "Breathing" || taskName == "Meditation" {
            let alertController = UIAlertController(title: taskName, message:
                "How many minutes?", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addTextField { (textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.numberPad
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default,handler: { (_) in
                if let temp = alertController.textFields?[0] {
                    let textField = temp
                    let userInputAsInt = Int(textField.text!)
                    if (userInputAsInt != nil){
                        if (userInputAsInt! >= 1 && userInputAsInt! <= 120) {
                            self.logActivity(tName: taskName, time: userInputAsInt!)
                            // add checkmark
                            switch taskName {
                                case "Yoga Based Movement": self.addCheckmark(row: 0)
                                case "Breathing": self.addCheckmark(row: 1)
                                case "Meditation": self.addCheckmark(row: 2)
                                default: break
                            }
                        }
                        else {
                            self.presentInvalidInputAlert(name: taskName)
                        }
                        
                    }
                    else {
                        self.presentInvalidInputAlert(name: taskName)
                    }
                }
                }
            
            ))
             self.present(alertController, animated: true, completion: nil)
        }
        // case for Materials
        else if taskName == "Materials" {
            
            // check if user has entered password before or just entered pword for first time
            if self.materialsPasswordEntered {
                let alertController = UIAlertController(title: taskName, message:
                    "Visit materials page?", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
                alertController.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.default,handler: self.goToMaterials))
                self.present(alertController, animated: true, completion: nil)
            }
            // user has not accessed materials before
            else {
                let alertController = UIAlertController(title: taskName, message:
                    "Enter Passcode:", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = false
                }
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
                alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default,handler: { (_) in
                    // password validation for materials : ONLY OCCURS FIRST TIME USER USES APP
                    let textField = alertController.textFields![0]
                    if textField.text == "taratrackermaterials_" {
                        self.presentMaterialsAlert()
                    }
                    else {
                        self.presentWrongPasswordAlert(name: taskName)
                    }
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        // case for Submit Minutes
        else {
            let alertController = UIAlertController(title: taskName, message:
                "Enter Passcode:", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = false
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default,handler: { (_) in
                // password validation for submitting materials
                let textField = alertController.textFields![0]
                if textField.text == "taratrackersubmit_" {
                    self.sendData()
                }
                else {
                    self.presentWrongPasswordAlert(name: taskName)
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
       
    }
    
    
    
    // alert handlers
    func logActivity(tName : String, time : Int) {
        // handles a new log (including first ever log)
        if (currentDate != previousDate || currentMonth != previousMonth || minutesLog == []) {
            // add current date to log
            minutesLog.append(self.currentMonth)
            minutesLog.append(self.currentDate)
            // set current date -> previous date
            memory.set(currentMonth, forKey: "previousMonth")
            memory.set(currentDate, forKey: "previousDate")
            previousMonth = currentMonth
            previousDate = currentDate
            
            var index = 0

            // log minutes
            if tName == "Yoga Based Movement" {
                minutesLog.append(time)
                minutesLog.append(0)
                minutesLog.append(0)
                index = 0
            }
            else if tName == "Breathing" {
                minutesLog.append(0)
                minutesLog.append(time)
                minutesLog.append(0)
                index = 1
            }
            else {
                minutesLog.append(0)
                minutesLog.append(0)
                minutesLog.append(time)
                index = 2
            }
            // change totalMinutes and update label
            totalMinutesLog[index] += time
            self.listOfCells[index].addTotalMinutesLabel(txt: String(self.totalMinutesLog[index]))
        
        }
            
        // if it's the same day as the last time the user logged...
        else if (previousMonth == currentMonth && previousDate == currentDate) {
            var subtractIndex = 0
            if tName == "Yoga Based Movement" {
                subtractIndex = 3
            }
            else if tName == "Breathing" {
                subtractIndex = 2
            }
            else {
                subtractIndex = 1
            }
            totalMinutesLog[3-subtractIndex] += time
            minutesLog[minutesLog.endIndex-subtractIndex] = minutesLog[minutesLog.endIndex-subtractIndex] + time
            self.listOfCells[3-subtractIndex].addTotalMinutesLabel(txt: String(self.totalMinutesLog[3-subtractIndex]))
            
        }
        memory.set(totalMinutesLog, forKey: "totalMinutesLog")
        memory.set(minutesLog, forKey: "minutesLog")

        
    }
    
    let goToMaterials = { (action:UIAlertAction!) -> Void in
        UIApplication.shared.openURL(URL(string: "https://www.dropbox.com/sh/ovff9450hnfeypq/AAAHbLIJt11x_rfWyTcu-Ehxa?dl=0")!)
    }
    
    func turnBackgroundColor(_ color: UIColor) {
        tableView.backgroundColor = color
    }
    
    // sending email with data
    func sendData() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["justin.lj.wei@gmail.com"])
        mailComposerVC.setSubject("TARA Minutes: Subject X")
        let minutesString = String(describing: minutesLog)
        mailComposerVC.setMessageBody(minutesString, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // alerts
    func presentMaterialsAlert() {
        self.memory.set(true, forKey: "materialsPasswordEntered")
        self.materialsPasswordEntered = true
        let alertController = UIAlertController(title: "Materials", message:
            "Visit materials page?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.default,handler: self.goToMaterials))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentWrongPasswordAlert(name : String) {
        let alertController = UIAlertController(title: name, message:
            "You entered an incorrect password.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentInvalidInputAlert(name : String) {
        let alertController = UIAlertController(title: name, message:
            "Oops! You may only enter times between 1-120 minutes.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // for performance/efficiency
    override var canBecomeFirstResponder : Bool {
        return true
    }
    override var canResignFirstResponder : Bool {
        return true
    }
    
    func addCheckmark(row : Int) {
        let cell = listOfCells[row]
        
        cell.accessoryType = .checkmark
        cell.tintColor = UIColor.white
        
        // add to list of checked cells
        listOfCheckmarks[row] = true
        memory.set(listOfCheckmarks, forKey: "listOfCheckmarks")
    }

    
}

