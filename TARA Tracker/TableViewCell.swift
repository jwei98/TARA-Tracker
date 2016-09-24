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
    func presentAlert(_ taskName : String)
    func turnBackgroundColor(_ col : UIColor)
}



class TableViewCell: UITableViewCell {
    
    // MARK: ---------------------------------- Properties, Constructor, Initial Setup ---------------------------------- //

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
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(TableViewCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: ---------------------------------- Horizontal Panning (Swiping) ---------------------------------- //

    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x/1.5, y: originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 3.0
            if deleteOnDragRelease {
                let greenColor = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 0.8)
                delegate!.turnBackgroundColor(greenColor)
            }
            else {
                delegate!.turnBackgroundColor(UIColor.lightGray)
            }
        }
        // 3
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                // if the item is not being deleted, snap back to the original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
                    delegate!.turnBackgroundColor(UIColor.lightGray)
                    delegate!.presentAlert((self.toDoItem?.getText())!)
                }
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    

    
    // MARK: ---------------------------------- Mutators (Specifically labels) ---------------------------------- //

    func addTotalMinutesLabel(txt: String) {
        
        if let checkLabel = self.viewWithTag(1) {
            let label = checkLabel as! UILabel
            label.text = txt
        }
        else {
            // add totalMinute numers to left side of cells
            let xPos = -self.frame.width / 6
            let yPos = self.frame.height / 2
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width / 6, height: self.frame.height))
            label.font = UIFont(name: "SteelfishRg-Regular", size: self.frame.height/6)
            label.tag = 1
            label.center = CGPoint(x: xPos, y: yPos)
            label.text = txt
            label.textColor = UIColor.white
            
            self.addSubview(label)
        }
        
    }
    
    
    func addActionLabel(txt: String) {
        
        // add action labels on right end of cells
        let xPos = self.frame.width * (11/9)
        let yPos = self.frame.height * (1/2)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width / 6, height: self.frame.height))
        label.font = UIFont(name: "aliensandcows", size: self.frame.height/6)
        label.tag = 2
        label.center = CGPoint(x: xPos, y: yPos)
        label.text = txt
        label.textColor = UIColor.white
        
        self.addSubview(label)
        
    }
    
    

    
}
