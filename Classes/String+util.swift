//
//  StringExtension.swift
//  CustomizationArchitectureDemo
//
//  Created by Borja González Jurado on 17/7/16.
//  Copyright © 2016 Borja González Jurado. All rights reserved.
//

import Foundation

extension String {
    
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }
    
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension
        }
    }
}
