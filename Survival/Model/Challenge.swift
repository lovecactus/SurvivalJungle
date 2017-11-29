//
//  Challenge.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

let DieForAge:Int = 100
let CreatureSurviveScore:Double = -100

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

