//
//  TableViewCell.swift
//  TARA Tracker
//
//  Created by Justin Wei on 9/8/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

import UIKit
import QuartzCore

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
    // indicates that the given item has been deleted
    func toDoItemDeleted(todoItem: ToDoItem)
    func presentAlert(taskName : String)
    func turnBackgroundColor(col : UIColor)
}

class TableViewCell: UITableViewCell {
    
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    // The object that acts as delegate for this cell.
    var delegate: TableViewCellDelegate?
    // The item that this cell renders.
    var toDoItem: ToDoItem?
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // add a pan recognizer
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    //MARK: - horizontal pan gesture methods
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .Began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x/1.5, originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 3.0
            if deleteOnDragRelease {
                let greenColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.75)
                delegate!.turnBackgroundColor(greenColor)
            }
            else {
                delegate!.turnBackgroundColor(UIColor.grayColor())
            }
        }
        // 3
        if recognizer.state == .Ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                // if the item is not being deleted, snap back to the original location
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
                    delegate!.turnBackgroundColor(UIColor.grayColor())
                    delegate!.presentAlert((self.toDoItem?.getText())!)
                }
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }

    
}