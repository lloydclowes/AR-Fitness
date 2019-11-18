//
//  Utilities.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import Foundation

func stringClassFromString(_ className: String) -> AnyClass! {

    /// get namespace
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;

    /// get 'anyClass' with classname and namespace
    let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;

    // return AnyClass!
    return cls;
    
}
