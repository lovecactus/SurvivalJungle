//
//  Methodology_Heritage.swift
//  Survival
//
//  Created by YANGWEI on 28/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

class HeritageMethodology {
    public static func randomMethodGenerator() -> HeritageMethodology {
        let method:HeritageMethodology
        switch Int(arc4random_uniform(2)) {
        case 0:
            method = HeritageMethodology_Normal()
            break
        case 1:
            method = HeritageMethodology_OnlyFirstSon()
            break
        default:
            method = HeritageMethodology()
        }
        return method
    }
    
    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: HeritageMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: HeritageMethodology_Normal.self):
            descriptor = descriptor + "AllSons"
            break
        case String(describing: HeritageMethodology_OnlyFirstSon.self):
            descriptor = descriptor + "FirstSon"
            break
        default:
            descriptor = descriptor + ".."
        }
        return descriptor
    }

    public func heritage(of creature:Creature, to creatures:inout CreatureGroup) {
        let sonIDs = creature.memory.thinkOfSons()
        guard sonIDs.count > 0 && creature.surviveResource > 0 else {
            return
        }
        
        let averageSplitResource = creature.surviveResource/Double(sonIDs.count)
        sonIDs.forEach { (sonID) in
            let giveOutResource = creature.giveResource(resource: averageSplitResource)
            creatures.findCreatureBy(uniqueID: sonID)?.receiveResource(resource: giveOutResource)
        }
    }
}

class HeritageMethodology_Normal:HeritageMethodology {
}

class HeritageMethodology_OnlyFirstSon:HeritageMethodology {
    override public func heritage(of creature:Creature, to creatures:inout CreatureGroup) {
        let sonIDs = creature.memory.thinkOfSons()
        guard let firstSonID = sonIDs.first, creature.surviveResource > 0 else {
            return
        }
        
        let giveOutResource = creature.giveResource(resource: creature.surviveResource)
        creatures.findCreatureBy(uniqueID: firstSonID)?.receiveResource(resource: giveOutResource)
    }
}

