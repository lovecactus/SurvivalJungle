//
//  Challenge.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

let DieForAge:Int = 400
let MatureAge:Int = DieForAge/10
let OldAge:Int = DieForAge/2
let CreatureSurviveScore:Double = 0

class Challenge {
}

class OldChallenge : Challenge {
    func surviveChallenge(_ age:Int) -> Bool {
        let DieAge = Int(arc4random_uniform(50))+DieForAge;
        if age >= DieAge {
            return true
        }
        return false
    }
}

class StarveChallenge : Challenge {
    func surviveChallenge(_ surviveResource:SurvivalResource) -> Bool {
        if surviveResource <= CreatureSurviveScore {
            return true
        }
        return false
    }
}

