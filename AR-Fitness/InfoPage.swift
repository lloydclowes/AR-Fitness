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
    
    let infoLabel : UILabel = {
        
          let myLabel = UILabel()
          myLabel.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
          myLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
          myLabel.font = UIFont.boldSystemFont(ofSize: 20)
        myLabel.lineBreakMode = .byWordWrapping
        myLabel.numberOfLines = 0
          myLabel.textAlignment = NSTextAlignment.center
          myLabel.adjustsFontSizeToFitWidth = true
          return myLabel
    }()
    
    func updateReps(_ numReps: Int, timer: Int) {
        reps = numReps
        time = timer
        infoLabel.text = "Number of reps: \(reps)" + "\n" + "Activity time: \(time)"
    }
    
    func dismissButton() -> UIButton {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = .red
    button.setAttributedTitle(NSAttributedString(string: "Dismiss", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor:
        UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: UIControl.State.normal)
        button.addTarget(nil, action: #selector(self.dismissInfo), for: UIControl.Event.touchUpInside)
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
    
    
    func setupViews() {
        // adding both views
        let button = dismissButton()
        view.addSubview(infoLabel)
        infoLabel.text = "Number of reps: \(reps)" + "\n" + "Activity time: \(time)"
        view.addSubview(button)
        // label constraints (position, size...)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1, constant:-30))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200))
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
    }
}


