//
//  InfoPage.swift
//  AR-Fitness
//
//  Created by Blanca Tebar on 23/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

class ModalViewController: UIViewController {
    var reps = 0
    var time = 0
    var isTimeBased = false
    var exercise = ""
    
    let infoLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        myLabel.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        myLabel.font = UIFont.boldSystemFont(ofSize: 20)
        myLabel.lineBreakMode = .byWordWrapping
        myLabel.numberOfLines = 0
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.adjustsFontSizeToFitWidth = true
        myLabel.clipsToBounds = true
        myLabel.layer.cornerRadius = 25
        return myLabel
    }()
    
    func updateInfo(_ numReps: Int?, timer: Int, exerciseName: String) {
        infoLabel.text = ""
        if(numReps != nil) {
            reps = numReps!
            infoLabel.text = "Number of reps: \(reps) \n"
        } else {
            isTimeBased = true
        }
        time = timer
        exercise = exerciseName
        infoLabel.text! += "Activity time: \(time)"
    }
    
    func dismissButton() -> UIButton {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = UIColor(red: 1.00, green: 0.5, blue: 0.5, alpha: 1.0)
    button.setAttributedTitle(NSAttributedString(string: "Dismiss", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor:
        UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: UIControl.State.normal)
        button.addTarget(nil, action: #selector(self.dismissInfo), for: UIControl.Event.touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        setupViews()
    }
    
    @objc func dismissInfo(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getTimeString() -> String {
        var secs : Int = time
        let mins : Int = time/60
        secs -= (mins*60)
        var timeStr : String = ""
        if(mins < 10) {
            timeStr += "0"
        }
        timeStr += "\(mins):"
        if(secs < 10) {
            timeStr += "0"
        }
        timeStr += "\(secs)"
        return timeStr
    }
    
    func getCaloriesBurnedPerExercise() -> Int {
        switch self.exercise {
        case "Lateral Raises":
            return Int((Float(time)/3600) * 4)
        case "Squats":
            return Int((Float(time)/3600) * 15)
        case "Hundred Ups":
            return Int((Float(time)/3600) * 6)
        default:
            return 0
        }
    }
    
    func getLabelInfo() -> String {
        let timeStr = getTimeString()
        let calories = getCaloriesBurnedPerExercise()
        var labelText = ""
        if(!isTimeBased) {
            labelText += "Number of reps: \(reps)" + "\n"
        }
        labelText += "Activity time: " + timeStr + "\n Calories: \(calories)"
        return labelText
    }
    
    func setupViews() {
        // adding both views
        let button = dismissButton()
        view.addSubview(infoLabel)
        infoLabel.text = getLabelInfo()
        view.addSubview(button)
        // label constraints (position, size...)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1, constant: 10))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 220))
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
    }
}



