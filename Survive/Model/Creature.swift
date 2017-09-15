//
//  Creature.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import Foundation

protocol LoveProtocol {
    func loveAction(ToAnotherCreature:Creature) -> LoveAction
}

protocol ReproductionProtocol {
    func selfReproduction() -> Creature
}

enum CoWorkerChooseDecision: UInt32 {
    case ChooseNewFriend
    case ChooseOldFriend
    
    private static let _count: CoWorkerChooseDecision.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = CoWorkerChooseDecision(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func randomChoose() -> CoWorkerChooseDecision {
        // pick and return a new value
        let rand = arc4random_uniform(_count)
        return CoWorkerChooseDecision(rawValue: rand)!
    }

}

class Creature : AnyObject {
    public var SurviveResource:Double = 0
    public let identifier:String
    var Memory:CreatureMemory = CreatureMemory()

    init(creatureIdentifier:String) {
        identifier = creatureIdentifier
    }
    
    func workResult(AnotherCreature: Creature, AnotherAction: WorkAction, result : WorkResult, harvestResource : Double){
        self.Memory.remember(AnotherCreature:AnotherCreature, Behavior:AnotherAction)
        SurviveResource += SocialBehavior.WorkReword(result, harvestResource: harvestResource)
    }
    
    func workAction(ToAnotherCreature: Creature) -> WorkAction {
        return WorkAction.none
    }

    func stayAlone(){
        SurviveResource -= SocialBehavior.StayLonely()
    }
    
    func selfReproduction() -> Creature{
        return Creature.init(creatureIdentifier: self.identifier+".")
    }
    
    func reproductionWith(AnotherCreature:Creature) -> Creature{
        let rollDice = arc4random_uniform(2) + 1;
        var multipliedCreature:Creature
        if rollDice == 1 {
            multipliedCreature = self.selfReproduction()
        }else{
            multipliedCreature = AnotherCreature.selfReproduction()
            
        }
        return multipliedCreature
    }

    func findCoWorker(candidate Creatures:[Creature]) -> Creature?{
        guard Creatures.count > 0 else {
            return nil
        }
        let rollDice = arc4random_uniform(UInt32(Creatures.count));
        return Creatures[Int(rollDice)]
    }
    
    func findOneFriendFromCandidate(candidate Creatures:[Creature]) -> Creature?{
        while let OldFriendID = self.Memory.thinkOfOneRandomFriendID() {
            var OldFriend:Creature? = nil
            if let i = Creatures.index(where: { (Creature) -> Bool in
                return (Creature.identifier == OldFriendID)
            }){
                OldFriend = Creatures[i]
            }

            
            if let FindOldFriend = OldFriend {
                return FindOldFriend
            }else{
                self.Memory.forget(AnotherCreatureID: OldFriendID)
            }
        }
        return nil
    }

    func findFriendListFromCandidate(candidate Creatures:[Creature]) -> [Creature]{
        return Creatures.filter { (Creature) -> Bool in
            return (WorkAction.devote == self.Memory.thinkOf(AnotherCreature: Creature))
        }
    }

    func avoidBadGuysFromCandidate(candidate Creatures:[Creature]) -> [Creature]{
        return Creatures.filter { (Creature) -> Bool in
            return (WorkAction.cheat != self.Memory.thinkOf(AnotherCreature: Creature))
        }
    }

}

class NiceCreature : Creature, ReproductionProtocol {    
    override func workAction(ToAnotherCreature: Creature) -> WorkAction {
        return WorkAction.devote
    }

    override func selfReproduction() -> Creature {
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        return NiceCreature.init(creatureIdentifier: self.identifier+".")
    }
    
    override func findCoWorker(candidate Creatures:[Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: Creatures){
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.avoidBadGuysFromCandidate(candidate: Creatures).randomPick(){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        return CoWorkCreature
    }

}

class BadCreature : Creature, ReproductionProtocol {
    override func workAction(ToAnotherCreature: Creature) -> WorkAction {
        return WorkAction.cheat
    }

    override func selfReproduction() -> Creature {
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        return BadCreature.init(creatureIdentifier: self.identifier+".")
    }
    
    override func findCoWorker(candidate Creatures:[Creature]) -> Creature?{
        return super.findCoWorker(candidate: Creatures)
    }

}

class OpenBadCreature : BadCreature {
    override func selfReproduction() -> Creature {
        print (anotherType)
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        return OpenBadCreature.init(creatureIdentifier: self.identifier+".")
    }

    override func findCoWorker(candidate Creatures:[Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let NewFriend = self.avoidBadGuysFromCandidate(candidate: Creatures).randomPick(){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        return CoWorkCreature
    }
}

class ConservativeBadCreature : BadCreature {
    override func selfReproduction() -> Creature {
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        return ConservativeBadCreature.init(creatureIdentifier: self.identifier+".")
    }

    override func findCoWorker(candidate Creatures:[Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: Creatures) {
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.avoidBadGuysFromCandidate(candidate: Creatures).randomPick(){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        return CoWorkCreature
    }
}

    
class MeanCreature : Creature, ReproductionProtocol {
    override func workAction(ToAnotherCreature: Creature) -> WorkAction {
        var workAction = self.Memory.thinkOf(AnotherCreature: ToAnotherCreature)
        if workAction == .none {
            workAction = .devote
        }
        return workAction
    }
    
    override func selfReproduction() -> Creature {
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        let NewBornCreature = MeanCreature.init(creatureIdentifier: self.identifier+".")
        NewBornCreature.Memory = CreatureMemory()
        NewBornCreature.Memory.memory = self.Memory.memoryInherit()
        return NewBornCreature
    }
    
    override func findCoWorker(candidate Creatures:[Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
//        switch CoWorkerChooseDecision.randomChoose() {
//        case .ChooseNewFriend:
//            CoWorkCreature = self.kickOutBadGuysFromCandidate(candidate: Creatures).randomPick()
//            break
//        case .ChooseOldFriend:
        if let OldFriend = self.findOneFriendFromCandidate(candidate: Creatures) {
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.avoidBadGuysFromCandidate(candidate: Creatures).randomPick(){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
//            break
//        }
        return CoWorkCreature
    }
}


class CreatureMemory{
    var memory:[String:WorkAction] = [:]
    
    func remember (AnotherCreature:Creature, Behavior:WorkAction){
        memory[AnotherCreature.identifier] = Behavior
    }
    
    func forget (AnotherCreatureID : String) {
        memory.removeValue(forKey: AnotherCreatureID)
    }
    
    func thinkOf(AnotherCreature:Creature) -> WorkAction {
        guard let memoryForThisCreature = memory[AnotherCreature.identifier] else {
            return WorkAction.none
        }
        return memoryForThisCreature
    }

    func memoryInherit() -> [String:WorkAction] {
        return memory
    }
    
    func thinkOfOneRandomFriendID() -> String? {
        let niceMemories = memory.filter {
            return  $1 == .devote
        }.map { (key: String, value: WorkAction) -> String in
            return key
        }
        
        return niceMemories.randomPick()
    }
    
    
}

