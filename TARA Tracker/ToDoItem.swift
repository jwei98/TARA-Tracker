//
//  ToDoItem.swift
//  TARA Tracker
//
//  Created by Justin Wei on 9/8/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {

    // A text description of this item.
    var text: String
    
    // A Boolean value that determines the completed state of this item.
    var completed: Bool
    
    // Keeps a list of how many minutes logged and on what date
    
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
        self.text = text
        self.completed = false
    }
    
    func getText() -> String {
        return self.text
    }
}
