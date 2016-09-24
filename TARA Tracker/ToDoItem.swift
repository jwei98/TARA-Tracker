//
//  ToDoItem.swift
//  TARA Tracker
//
//  Created by Justin Wei on 9/8/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

// MARK: This class is mostly a remnant from using Ray Wenderlich's tutorial.

import UIKit

class ToDoItem: NSObject {

    // A text description of this item.
    var text: String
    
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
        self.text = text
    }
    
    func getText() -> String {
        return self.text
    }
    
}
