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
    let screenBound = UIScreen.mainScreen().bounds
    
    // hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.grayColor()
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
    
    
    
    func toDoItemDeleted(toDoItem: ToDoItem) {
        let index = (toDoItems as NSArray).indexOfObject(toDoItem)
        if index == NSNotFound { return }
        
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        toDoItems.removeAtIndex(index)
        
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableView.endUpdates()    
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
                                                               forIndexPath: indexPath) as! TableViewCell
        let item = toDoItems[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(tableView.rowHeight/6.7)
        cell.selectionStyle = .None
        
        cell.delegate = self
        cell.toDoItem = item
        
        return cell
    }
    
    // support for versions before iOS 8
    func tableView(tableView: UITableView, heightForRowAtIndexPath
        indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight;
    }
    
    // coloring the cells
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index+2) / CGFloat(itemCount)) * 0.5
        return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }

    // view controller presenting alerts
    func presentAlert(taskName : String) {
        // cases for logging minutes
        if taskName == "Yoga Based Movement" || taskName == "Breathing" || taskName == "Meditation" {
            let alertController = UIAlertController(title: taskName, message:
                "How many minutes?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.NumberPad
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default,handler: nil))
             self.presentViewController(alertController, animated: true, completion: nil)
        }
        // case for Materials
        else if taskName == "Materials" {
            let alertController = UIAlertController(title: taskName, message:
                "Visit materials page?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default,handler: goToMaterials))
             self.presentViewController(alertController, animated: true, completion: nil)
        }
        // case for Submit Minutes
        else {
            let alertController = UIAlertController(title: taskName, message:
                "Enter Passcode:", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Password"
                textField.secureTextEntry = true
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default,handler: nil))
             self.presentViewController(alertController, animated: true, completion: nil)
        }
       
    }
    
    // alert handlers
    let goToMaterials = { (action:UIAlertAction!) -> Void in
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.dropbox.com/sh/ovff9450hnfeypq/AAAHbLIJt11x_rfWyTcu-Ehxa?dl=0")!)
    }
    
    
    func turnBackgroundColor(color: UIColor) {
        tableView.backgroundColor = color
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func canResignFirstResponder() -> Bool {
        return true
    }
}

