//
//  ViewController.swift
//  TARA Tracker
//
//  Created by Justin Wei on 8/25/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var toDoItems = [ToDoItem]()
    let screenBound = UIScreen.mainScreen().bounds
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.grayColor()

        

        let screenHeight = screenBound.size.height
        tableView.rowHeight = screenHeight / 5
        
        if toDoItems.count > 0 {
            return
        }
        toDoItems.append(ToDoItem(text: "Yoga Based Movement"))
        toDoItems.append(ToDoItem(text: "Breathing"))
        toDoItems.append(ToDoItem(text: "Meditation"))
        toDoItems.append(ToDoItem(text: "Materials"))
        toDoItems.append(ToDoItem(text: "Submit Minutes"))
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
        
        cell.selectionStyle = .None
        
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
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 0.0, green: val, blue: 0.8, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }

    
    
}

