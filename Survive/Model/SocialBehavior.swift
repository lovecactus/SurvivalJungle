//
//  SocialBehavior.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import Foundation

enum LoveAction {
    case devote
    case cheat
    case none
}

enum LoveResult {
    case fallInLove
    case beenLoved
    case beenCheated
    case doubleLose
    case none
}

enum WorkAction {
    case devote
    case cheat
    case none
}

enum WorkResult {
    case doubleWin
    case exploitation
    case beenCheated
    case doubleLose
    case none
}

class SocialBehavior {
    static let workingCost:Double = 2

    init() {
    }
        
    func Work(Creature1:Creature, Action1:WorkAction, Result1:inout WorkResult, Creature2:Creature, Action2:WorkAction, Result2:inout WorkResult) {
        if Action1 == .devote && Action2 == .devote {
            Result1 = .doubleWin
            Result2 = .doubleWin
        }else if Action1 == .devote && Action2 == .cheat {
            Result1 = .beenCheated
            Result2 = .exploitation
        }else if Action1 == .cheat && Action2 == .devote {
            Result1 = .exploitation
            Result2 = .beenCheated
        }else if Action1 == .cheat && Action2 == .cheat {
            Result1 = .doubleLose
            Result2 = .doubleLose
        }
    }

    public static func StayLonely() -> Double{
        return -workingCost
    }
    
    public static func WorkReword(_ workresult: WorkResult, harvestResource: Double) -> Double{
        var rewardResource:Double
        switch workresult {
        case .doubleWin:
            rewardResource = harvestResource
        case .exploitation:
            rewardResource = harvestResource*2.5
        case .beenCheated:
            rewardResource = -harvestResource*0.5
        case .doubleLose:
            rewardResource = -harvestResource*0
        case .none:
            rewardResource = 0
        }
        rewardResource -= workingCost
        return rewardResource
    }
}
