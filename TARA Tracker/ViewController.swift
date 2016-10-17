//
//  ViewController.swift
//  TARA Tracker
//
//  Created by Justin Wei on 8/25/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

// MARK: Description & Sources
// Description: This app was built by Justin Wei in order to help collect information from subjects in the University of California, San Francisco "Brain Change" study. Subjects can use this app to track the amount of time they spend doing YBM, Breathing, and Meditating at home. Furthermore, they can use the UI to access course/study materials (password protected). Finally, at the end of the program, they will be given the password to submit their minute-logs via email to Olga Tymofiyeva, co-head of the study. Please contact justin.lj.wei@gmail.com for more information.

// Sources: TableView and swipe methods were highly based off Ray Wenderlich's "How To Make a Gesture-Driven To-Do List App" tutorial. Fonts used were: "Aliens and Cows" by Francesco Canovaro (downloaded from DaFont.com) and "Steelfish Font" by Typodermic Fonts (also downloaded from DaFont.com).


import UIKit
import MessageUI
import UserNotifications


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate, MFMailComposeViewControllerDelegate {

    // MARK: ---------------------------------- Properties and Initial Setup ---------------------------------- //
    
    @IBOutlet weak var tableView: UITableView!
    var toDoItems = [ToDoItem]()
    let screenBound = UIScreen.main.bounds
    let memory = UserDefaults.standard

    // these properties are used to add dates into the minute log & reset features (like checkmarks) daily
    var previousMonth : Int = 0
    var previousDate : Int = 0
    var currentMonth : Int = 0
    var currentDate : Int = 0
    
    var minutesLog = [Int]() // in format: [Month, Date, YBM, Breathing, Meditation,... repeat]
    var totalMinutesLog = [0,0,0] // in format: [YBM, Breathing, Meditation]
    var listOfCells = [TableViewCell]() // used to access individual cells
    var listOfCheckmarks : [Bool] = [false,false,false] // marks which activities have been completed daily
    let listActionNames = ["LOG", "LOG", "LOG", "VISIT", "SEND"] // labels that show on right side of cells (when user swipes)
    
    var materialsPasswordEntered = false // user only has to login once to access materials
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LOADING PAST DATA
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
        
        // modifications to app based on currentDate vs. pastDate
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
        // add tasks to tableView
        toDoItems.append(ToDoItem(text: "Yoga Based Movement"))
        toDoItems.append(ToDoItem(text: "Breathing"))
        toDoItems.append(ToDoItem(text: "Meditation"))
        toDoItems.append(ToDoItem(text: "Materials"))
        toDoItems.append(ToDoItem(text: "Submit Minutes"))

    }
    
    // MARK: ---------------------------------- TableView Setup and Methods ---------------------------------- //

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    // setup of individual cells
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                               for: indexPath) as! TableViewCell
        let item = toDoItems[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = item.text.uppercased()
        cell.textLabel?.font = UIFont(name: "aliensandcows", size: tableView.rowHeight/3.75)
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

    func addCheckmark(row : Int) {
        let cell = listOfCells[row]
        
        cell.accessoryType = .checkmark
        cell.tintColor = UIColor.white
        
        // add to list of checked cells
        listOfCheckmarks[row] = true
        memory.set(listOfCheckmarks, forKey: "listOfCheckmarks")
    }
    
    // MARK: ---------------------------------- Presenting Alerts to User ---------------------------------- //
    
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
                    self.presentSubjectNumberAlert()
                }
                else {
                    self.presentWrongPasswordAlert(name: taskName)
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
       
    }
    
    // alert helper functions
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
            "Oops! You entered an incorrect password.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentInvalidInputAlert(name : String) {
        let alertController = UIAlertController(title: name, message:
            "Sorry! You may only enter integer times between 1-120 minutes.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentInvalidSubNumber() {
        let alertController = UIAlertController(title: "Invalid Subject ID Number", message:
            "Sorry! You entered an invalid subject ID number!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentSubjectNumberAlert() {
        let alertController = UIAlertController(title: "Subject ID Number", message:
            "Please enter your subject ID number:", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.numberPad
        }
        alertController.addAction(UIAlertAction(title: "Enter", style: UIAlertActionStyle.default,handler: { (_) in
            if let temp = alertController.textFields?[0] {
                let textField = temp
                let userInput = String(textField.text!)
                if (userInput != "" && Int(userInput!) != nil && Int(userInput!) != 0){
                    self.sendData(subjectNumber: userInput!)
                }
                else {
                    self.presentInvalidSubNumber()
                }
            }
            }
        ))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: ---------------------------------- Alert Handlers & Logging Activities ---------------------------------- //
    
    
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
    
    
    
    // MARK: ---------------------------------- Submitting Data through Email ---------------------------------- //

    // sending email with data
    func sendData(subjectNumber : String) {
        let mailComposeViewController = configuredMailComposeViewController(subjectNumber: subjectNumber)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(subjectNumber : String) -> MFMailComposeViewController {
        
        // name CSV file and add as attachment to email
        let firstPartName = "taratracker_bc" + String(subjectNumber) + "_"
        let secondPartName = String(currentMonth) + "_" + String(currentDate) + ".csv"
        let fullFileName = firstPartName + secondPartName
        
        // create mail composer view
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients(["Olga.Tymofiyeva@ucsf.edu"])
        mailComposerVC.setSubject(fullFileName)
        var minutesString = String(describing: minutesLog)
        // remove brackets
        minutesString.remove(at: minutesString.index(before: minutesString.endIndex))
        print("end index removed")
        minutesString.remove(at: minutesString.startIndex)

        mailComposerVC.setMessageBody(minutesString, isHTML: false)
        
        // Create CSV file
        let mailString = NSMutableString()
        mailString.append(minutesString)
        let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        if let content = data {
            print("NSData: \(content)")
        }
        
        mailComposerVC.addAttachmentData(data!, mimeType: "text/csv", fileName: fullFileName)
        
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
    
    
    // MARK: ---------------------------------- Helper Functions ---------------------------------- //
    
    
    // hide status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    func turnBackgroundColor(_ color: UIColor) {
        tableView.backgroundColor = color
    }
    // for performance/efficiency
    override var canBecomeFirstResponder : Bool {
        return true
    }
    override var canResignFirstResponder : Bool {
        return true
    }

    
}

