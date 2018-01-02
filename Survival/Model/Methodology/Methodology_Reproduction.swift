//
//  Methodology_Reproduction.swift
//  Survival
//
//  Created by YANGWEI on 27/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

let reproductionCost:Double = 80
let matingReproductionCost:Double = 40


let reproductionDesireThreshold_More:Double = Double((OldAge-MatureAge)*2/10)
let reproductionDesireThreshold_Less:Double = Double((OldAge-MatureAge)*4/10)
let reproductionResourceThreshold:Double = 120

class ReproductionMethodology {
    var matingMature:MatingMethodology = MatingMethodology()
    var raiseChildren:RaiseChildrenMethodology = RaiseChildrenMethodology()
    var reproductionType:ReproductionTypeMethodology = ReproductionTypeMethodology()
    var gender:GenderMethodology = GenderMethodology()

    public static func randomMethodGenerator() -> ReproductionMethodology {
        let newRandomMethod = ReproductionMethodology()
        newRandomMethod.matingMature = MatingMethodology.randomMethodGenerator()
        newRandomMethod.raiseChildren = RaiseChildrenMethodology.randomMethodGenerator()
        newRandomMethod.reproductionType = ReproductionTypeMethodology.randomMethodGenerator()
        newRandomMethod.gender = GenderMethodology.randomMethodGenerator()
        return newRandomMethod
    }

    public func descriptor() -> String {
        let descriptor:String = matingMature.descriptor()+"-"+raiseChildren.descriptor()+"-"+reproductionType.descriptor()+"-"+gender.descriptor()
        return descriptor
    }
    
    func selfReproduction(of creature:Creature) -> Creature {
        creature.surviveResource -= reproductionCost
        let newBorn = type(of: creature).init(familyName: creature.identifier.familyName, givenName:creature.identifier.givenName+"#")
        newBorn.method = creature.method
        
        let ChildrenInvest = self.raiseChildren.reproductionInvest()
        newBorn.surviveResource += ChildrenInvest
        creature.surviveResource -= ChildrenInvest
        creature.memory.releaseReproductionDesire()
        return newBorn
    }

    func matingReproduction(of mother:Creature, with father:Creature) -> Creature {
        mother.surviveResource -= matingReproductionCost
        father.surviveResource -= matingReproductionCost
        let newBorn = type(of: mother).init(familyName: mother.identifier.familyName, givenName:mother.identifier.givenName+"#")
        newBorn.method = self.matingMethodologyes(of: mother, father: father)
        
        let ChildrenInvest = mother.method.reproduction.raiseChildren.reproductionInvest()
        newBorn.surviveResource += ChildrenInvest
        mother.surviveResource -= ChildrenInvest
        mother.memory.releaseReproductionDesire()
        
        let ChildrenInvestOther = father.method.reproduction.raiseChildren.reproductionInvest()
        newBorn.surviveResource += ChildrenInvestOther
        father.surviveResource -= ChildrenInvestOther
        father.memory.releaseReproductionDesire()

        return newBorn
    }
    
    private func matingMethodologyes(of mother:Creature, father:Creature) -> Methodology {
        var newMethodology = Methodology()
        newMethodology.teamLead.teamUp = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.teamLead.teamUp
        newMethodology.teamLead.teamAssign = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.teamLead.teamAssign
        newMethodology.teamLead.teamLeading = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.teamLead.teamLeading
        newMethodology.teamLead.teamExploitation = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.teamLead.teamExploitation
        newMethodology.teamFollow.teamFollowAttitude = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.teamFollow.teamFollowAttitude
        newMethodology.teamFollow.teamFollowChoose = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.teamFollow.teamFollowChoose
        newMethodology.reproduction.gender = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.reproduction.gender
        newMethodology.reproduction.matingMature = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.reproduction.matingMature
        newMethodology.reproduction.raiseChildren = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.reproduction.raiseChildren
        newMethodology.reproduction.reproductionType = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.reproduction.reproductionType
        newMethodology.heritage = (Int(arc4random_uniform(2)) == 0 ? mother : father).method.heritage
        
        return newMethodology
    }
}

class MatingMethodology {
    public static func randomMethodGenerator() -> MatingMethodology {
        let method:MatingMethodology
        switch Int(arc4random_uniform(2)) {
        case 0:
            method = MatingMethodology_More()
            break
        case 1:
            method = MatingMethodology_Less()
            break
        default:
            method = MatingMethodology()
        }
        return method
    }
    
    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: MatingMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: MatingMethodology_More.self):
            descriptor = descriptor + "MatingMore"
            break
        case String(describing: MatingMethodology_Less.self):
            descriptor = descriptor + "MatingLess"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }
    
    func readyToReproduction(as creature:Creature ) -> Bool {
        return false
    }

    
}

class MatingMethodology_More : MatingMethodology {
    override func readyToReproduction(as creature:Creature ) -> Bool {
        if creature.memory.reproductionDesire() >= reproductionDesireThreshold_More ,
            creature.surviveResource >= reproductionResourceThreshold{
            return true
        }
        return false
    }
}

class MatingMethodology_Less : MatingMethodology{
    override func readyToReproduction(as creature:Creature ) -> Bool {
        if creature.memory.reproductionDesire() >= reproductionDesireThreshold_Less ,
            creature.surviveResource >= reproductionResourceThreshold{
            return true
        }
        return false
    }
}

class RaiseChildrenMethodology {
    public static func randomMethodGenerator() -> RaiseChildrenMethodology {
        let method:RaiseChildrenMethodology
        switch Int(arc4random_uniform(2)) {
        case 0:
            method = RaiseChildrenMethodology_HateChild()
            break
        case 1:
            method = RaiseChildrenMethodology_LoveChildren()
            break
        default:
            method = RaiseChildrenMethodology()
        }
        return method
    }

    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: RaiseChildrenMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: RaiseChildrenMethodology_HateChild.self):
            descriptor = descriptor + "HateChild"
            break
        case String(describing: RaiseChildrenMethodology_LoveChildren.self):
            descriptor = descriptor + "LoveChild"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }


    func reproductionInvest() -> SurvivalResource {
        return 30
    }
}

class RaiseChildrenMethodology_HateChild : RaiseChildrenMethodology {
    
}

class RaiseChildrenMethodology_LoveChildren : RaiseChildrenMethodology{
    override func reproductionInvest() -> SurvivalResource {
        return 70
    }
}


class ReproductionTypeMethodology {
    public static func randomMethodGenerator() -> ReproductionTypeMethodology {
        let method:ReproductionTypeMethodology
        switch Int(arc4random_uniform(2)) {
//        case 0:
//            method = ReproductionTypeMethodology_Self()
//            break
        case 0...1:
            method = ReproductionTypeMethodology_Mating()
            break
        default:
            method = ReproductionTypeMethodology()
        }
        return method
    }
    
    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: ReproductionTypeMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: ReproductionTypeMethodology_Mating.self):
            descriptor = descriptor + "Mating"
            break
        case String(describing: ReproductionTypeMethodology_Self.self):
            descriptor = descriptor + "Self"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }
    
    func isSelfReproduction() -> Bool {
        return false
    }
}

class ReproductionTypeMethodology_Self:ReproductionTypeMethodology {
    override func isSelfReproduction() -> Bool {
        return true
    }
}

class ReproductionTypeMethodology_Mating:ReproductionTypeMethodology {
    override func isSelfReproduction() -> Bool {
        return false
    }
}

enum Gender:Int{
    case Male
    case Female
}

class GenderMethodology {
    public static func randomMethodGenerator() -> GenderMethodology {
        let method:GenderMethodology
        switch Int(arc4random_uniform(2)) {
        case 0:
            method = GenderMethodology_Male()
            break
        case 1:
            method = GenderMethodology_Female()
            break
        default:
            method = GenderMethodology()
        }
        return method
    }
    
    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: GenderMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: GenderMethodology_Male.self):
            descriptor = descriptor + "Male"
            break
        case String(describing: GenderMethodology_Female.self):
            descriptor = descriptor + "Female"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }
    
    func gender() -> Gender {
        return .Female
    }
    
}

class GenderMethodology_Male : GenderMethodology {
    override func gender() -> Gender {
        return .Male
    }
}

class GenderMethodology_Female : GenderMethodology {
    override func gender() -> Gender {
        return .Female
    }
}
