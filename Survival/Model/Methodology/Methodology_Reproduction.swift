//
//  Methodology_Reproduction.swift
//  Survival
//
//  Created by YANGWEI on 27/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

let reproductionCost:Double = 40
let newBornResource:Double = reproductionCost


let reproductionDesireThreshold:Double = Double((OldAge-MatureAge)*2/10)
let reproductionResourceThreshold:Double = 120

class ReproductionMethodology {
    public static func reproductionRandomMethodGenerator() -> ReproductionMethodology {
        let method:ReproductionMethodology
        switch Int(arc4random_uniform(2)) {
        case 0:
            method = ReproductionMethodology_Normal()
            break
        case 1:
            method = ReproductionMethodology_LoveChildren()
            break
        default:
            method = ReproductionMethodology()
        }
        return method
    }

    func readyToReproduction(of creature:Creature ) -> Bool {
        if creature.memory.reproductionDesire() >= reproductionDesireThreshold ,
            creature.surviveResource >= reproductionResourceThreshold{
            return true
        }
        return false
    }

    func reproduction(of creature:Creature) -> Creature {
        let newBorn = type(of: creature).init(familyName: creature.identifier.familyName, givenName:creature.identifier.givenName+"#")
        newBorn.method = creature.method
        
        let ChildrenInvest = self.reproductionInvest()
        newBorn.surviveResource += ChildrenInvest
        creature.surviveResource -= ChildrenInvest
        creature.memory.releaseReproductionDesire()
        return newBorn
    }

    func reproductionInvest() -> SurvivalResource {
        return 0
    }
}

class ReproductionMethodology_Normal : ReproductionMethodology {
    
}

class ReproductionMethodology_LoveChildren : ReproductionMethodology{
    override func reproductionInvest() -> SurvivalResource {
        return 40
    }
}
