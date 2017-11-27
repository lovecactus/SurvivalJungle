//
//  RoutineHelper.swift
//  Survival
//
//  Created by YANGWEI on 02/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

func Delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
