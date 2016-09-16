//
//  ViewController.swift
//  TARA Tracker
//
//  Created by Justin Wei on 8/25/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var toDoItems = [ToDoItem]()
    let screenBound = UIScreen.main.bounds
    
    // hide status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.gray
        tableView.alwaysBounceVertical = false
        

        let screenHeight = screenBound.size.height
        tableView.rowHeight = screenHeight / 5
        print(tableView.rowHeight)
        
        if toDoItems.count > 0 {
            return
        }
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
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: tableView.rowHeight/6.7)
        cell.selectionStyle = .none
        
        cell.delegate = self
        cell.toDoItem = item
        
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
            alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default,handler: nil))
             self.present(alertController, animated: true, completion: nil)
        }
        // case for Materials
        else if taskName == "Materials" {
            let alertController = UIAlertController(title: taskName, message:
                "Visit materials page?", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.default,handler: goToMaterials))
             self.present(alertController, animated: true, completion: nil)
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
                    // password validation
                    let textField = alertController.textFields![0]
                    if textField.text == "taratracker" {
                        print("That is the correct password!")
                    }
                    else {
                        print("Incorrect. You entered: \(textField.text)")
                        // *** SEND DATA *** //
                    }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
       
    }
    
    // alert handlers
    let goToMaterials = { (action:UIAlertAction!) -> Void in
        UIApplication.shared.openURL(URL(string: "https://www.dropbox.com/sh/ovff9450hnfeypq/AAAHbLIJt11x_rfWyTcu-Ehxa?dl=0")!)
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

