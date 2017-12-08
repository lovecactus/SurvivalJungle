//
//  SurvivalStatistic.swift
//  Survival
//
//  Created by YANGWEI on 27/11/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

typealias SurvivalStatistic = [String:Double]

extension Dictionary where Key == String, Value == Double {
    mutating func setStatistic(value:Value,for key:Key) {
        self[key] = value
    }
    
    mutating func getStatstic(for key:Key) -> Value{
        if let value = self[key] {
            return value
        }
        let defaultValue = Value(0)
        self[key] = defaultValue
        return defaultValue
    }
    
    mutating func countResource(in creatures:[Creature]) {
        let totalResource:Value = creatures.reduce(0) { (result, creature) -> Value in
            return result+creature.surviveResource
        }
        self["average resource"] = totalResource/Double(creatures.count)
    }
}
