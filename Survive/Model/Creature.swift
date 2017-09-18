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
        if result == .doubleWin {
            if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != AnotherCreature.identifier{
                self.tell(Other: AnotherCreature, About: OldFriendID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldFriendID))
            }

            if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != AnotherCreature.identifier{
                self.tell(Other: AnotherCreature, About: OldEnemyID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldEnemyID))
            }

        }
        SurviveResource += SocialBehavior.WorkReword(result, harvestResource: harvestResource)
    }
    
    func workAction(ToAnotherCreature: Creature) -> WorkAction {
        return WorkAction.none
    }

    func thinking() {
        //I'm too stupid to think about myself!
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

    func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        guard Creatures.count > 0 else {
            return nil
        }
        let rollDice = arc4random_uniform(UInt32(Creatures.count));
        return Creatures[Int(rollDice)]
    }
    
    func findOneFriendFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
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

    func findNiceGuyFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
        guard Creatures.count > 0 else {
            return nil
        }
        /*return Creatures.first(where: { (Creature) -> Bool in
            return (WorkAction.cheat != self.Memory.thinkOf(AnotherCreature: Creature))
        })*/

        /*
        return Creatures.filter({ (Creature) -> Bool in
            return (WorkAction.cheat != self.Memory.thinkOf(AnotherCreature: Creature))
        }).randomPick()*/

        let randomIndex = Int(arc4random_uniform(UInt32(Creatures.count)))
        var randomeNiceGuy:Creature? = nil
        for index in randomIndex...Creatures.count-1{
            if WorkAction.cheat != self.Memory.thinkOf(AnotherCreature: Creatures[index]) {
                randomeNiceGuy = Creatures[index]
                break;
            }
        }
        if nil == randomeNiceGuy {
            for index in 0...randomIndex{
                if WorkAction.cheat != self.Memory.thinkOf(AnotherCreature: Creatures[index]) {
                    randomeNiceGuy = Creatures[index]
                    break;
                }
            }
        }
        return randomeNiceGuy
    }

    func tell(Other Creature:Creature, About AnotherCreature:Creature, WorkBehavior Bahavior:WorkAction){
        Creature.Memory.remember(AnotherCreature: AnotherCreature, Behavior: Bahavior)
    }
    
    func tell(Other Creature:Creature, About AnotherCreatureID:String, WorkBehavior Bahavior:WorkAction){
        Creature.Memory.remember(AnotherCreatureID: AnotherCreatureID, Behavior: Bahavior)
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
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures){
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
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
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        return super.findCoWorker(candidate: &Creatures)
    }

}

class OpenBadCreature : BadCreature {
    override func selfReproduction() -> Creature {
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        return OpenBadCreature.init(creatureIdentifier: self.identifier+".")
    }

    override func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
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

    override func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures) {
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        return CoWorkCreature
    }
}

class StrategyBadCreature : BadCreature {
    var disguiseCounter:Int = 0
    let showSelfCount:Int = 10
    var currentStrategyAction  = WorkAction.devote
    override func workAction(ToAnotherCreature: Creature) -> WorkAction {
        return currentStrategyAction
    }

    override func thinking() {
        //Think about how to disguise myself
        disguiseCounter += 1
        if disguiseCounter > showSelfCount {
            currentStrategyAction = WorkAction.cheat
        }else {
            currentStrategyAction = WorkAction.devote
        }

    }

/*    override func workAction(ToAnotherCreature: Creature) -> WorkAction {
        guard let randomAction = [WorkAction.cheat, WorkAction.devote].randomPick() else {
            return WorkAction.none
        }
        return randomAction
    }
*/
    
    override func selfReproduction() -> Creature {
        SurviveResource -= SurvivalJungle.CreatureReproductionScore
        return StrategyBadCreature.init(creatureIdentifier: self.identifier+".")
    }
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
        if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
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
        NewBornCreature.Memory.behaviorMemory = self.Memory.memoryInherit()
        return NewBornCreature
    }
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> Creature?{
        var CoWorkCreature:Creature?
        
//        switch CoWorkerChooseDecision.randomChoose() {
//        case .ChooseNewFriend:
//            CoWorkCreature = self.kickOutBadGuysFromCandidate(candidate: Creatures).randomPick()
//            break
//        case .ChooseOldFriend:
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures) {
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
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
    var behaviorMemory:[String:WorkAction] = [:]

    func remember (AnotherCreatureID:String, Behavior:WorkAction){
        behaviorMemory[AnotherCreatureID] = Behavior
    }

    func remember (AnotherCreature:Creature, Behavior:WorkAction){
        behaviorMemory[AnotherCreature.identifier] = Behavior
    }
    
    func forget (AnotherCreatureID : String) {
        behaviorMemory.removeValue(forKey: AnotherCreatureID)
    }

    func thinkOf(AnotherCreatureID : String) -> WorkAction {
        guard let memoryForThisCreature = behaviorMemory[AnotherCreatureID] else {
            return WorkAction.none
        }
        return memoryForThisCreature
    }

    func thinkOf(AnotherCreature:Creature) -> WorkAction {
        guard let memoryForThisCreature = behaviorMemory[AnotherCreature.identifier] else {
            return WorkAction.none
        }
        return memoryForThisCreature
    }

    func memoryInherit() -> [String:WorkAction] {
        return behaviorMemory
    }
    
    func thinkOfOneRandomFriendID() -> String? {
        let niceMemories = behaviorMemory.filter {
            return  $1 == .devote
        }.map { (key: String, value: WorkAction) -> String in
            return key
        }
        
        return niceMemories.randomPick()
    }

    func thinkOfOneRandomEnemyID() -> String? {
        let badMemories = behaviorMemory.filter {
            return  $1 == .cheat
            }.map { (key: String, value: WorkAction) -> String in
                return key
        }
        
        return badMemories.randomPick()
    }

    
}

