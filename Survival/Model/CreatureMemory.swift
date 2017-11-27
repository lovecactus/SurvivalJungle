//
//  CreatureMemory.swift
//  Survival
//
//  Created by YANGWEI on 17/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

struct CreatureWorkActionImpression {
    let CreatureID : String
    let Attitude : WorkAttitude
}


class CreatureMemory{
    public var workActionImpressionMemory:[CreatureWorkActionImpression] = []
    public var isAssamblingTeam:Bool = false
    
    public func remember(_ workAction:WorkAction) {
        workActionImpressionMemory.append(CreatureWorkActionImpression(CreatureID: workAction.Worker.identifier.uniqueID, Attitude: workAction.WorkingAttitude))
    }
    
    public func remember (AnotherCreatureID:String, Attitude:WorkAttitude){
        workActionImpressionMemory.append(CreatureWorkActionImpression(CreatureID: AnotherCreatureID, Attitude: Attitude))
    }

    public func forget (ForgetCreatureID:String){
        workActionImpressionMemory = workActionImpressionMemory.filter({ (impression) -> Bool in
            impression.CreatureID != ForgetCreatureID
        })
    }

    public func thinkOfLastWorkActionImpression(from creatureID: String) -> CreatureWorkActionImpression?{
        return self.thinkOfWorkAction(from: creatureID).last
    }

    public func thinkOfWorkAction(from creatureID: String) -> [CreatureWorkActionImpression]{
        let workActionMemoryForThisCreature = workActionImpressionMemory.filter { (workActionImpression) -> Bool in
            return workActionImpression.CreatureID == creatureID
        }
        
        return workActionMemoryForThisCreature
    }

    public func thinkOfCreatureScores() -> [String:Int] {
        var CreatureScores:[String:Int] = [:]
        for (_, workActionImpression) in workActionImpressionMemory.enumerated() {
            var CreatureScore = 0
            if let FetchCreatureScore = CreatureScores[workActionImpression.CreatureID]{
                CreatureScore = FetchCreatureScore
            } else {
                CreatureScore = 0
            }
            
            if workActionImpression.Attitude == .helpOther{
                CreatureScore = CreatureScore+1
            }else if workActionImpression.Attitude == .selfish{
                CreatureScore = CreatureScore-1
            }
            CreatureScores[workActionImpression.CreatureID] = CreatureScore
        }

        return CreatureScores
    }

    public func thinkScoreOf(AnotherCreatureID : String) -> Int {
        return self.thinkOf(AnotherCreatureID: AnotherCreatureID).reduce(0, { (score, impression) -> Int in
            return score + ((impression.Attitude == .helpOther) ? 1 : -1)
        })
    }
    
    public func thinkOf(AnotherCreatureID : String) -> [CreatureWorkActionImpression] {
        let memoryForThisCreature = workActionImpressionMemory.filter({ (impression) -> Bool in
            return impression.CreatureID == AnotherCreatureID
        })
        
        return memoryForThisCreature
    }
    
    public func memoryInherit() -> CreatureMemory {
        var NewWorkActionMemory:[CreatureWorkActionImpression] = []
        let ExpectedRememberMemoryCount = 10
        for impression in workActionImpressionMemory {
            if Int(arc4random_uniform(UInt32(workActionImpressionMemory.count))) < ExpectedRememberMemoryCount {
                NewWorkActionMemory.append(impression)
            }
        }
        let NewMemory = CreatureMemory()
        NewMemory.workActionImpressionMemory = NewWorkActionMemory
        return NewMemory
    }
    
    public func thinkOfOneRandomFriendID() -> String? {
        let niceCreatureIDs = self.thinkOfCreatureScores().filter { (_ , score) -> Bool in
            return score >= 0
            }.map { (creatureID, _) -> String in
                return creatureID
        }
        
        return niceCreatureIDs.randomPick()
    }
    
    public func thinkOfOneRandomEnemyID() -> String? {
        let badCreatureIDs = self.thinkOfCreatureScores().filter { (_ , score) -> Bool in
            return score < 0
            }.map { (creatureID, _) -> String in
                return creatureID
        }
        
        return badCreatureIDs.randomPick()
    }

    public func findOneFriendFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
        while let OldFriendID = self.thinkOfOneRandomFriendID() {
            var OldFriend:Creature? = nil
            if let i = Creatures.index(where: { (Creature) -> Bool in
                return (Creature.identifier.uniqueID == OldFriendID)
            }){
                OldFriend = Creatures[i]
            }
            
            
            if let FindOldFriend = OldFriend {
                return FindOldFriend
            }else{
                self.forget(ForgetCreatureID: OldFriendID)
            }
        }
        return nil
    }
    
    public func findNotBadGuyFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
        guard Creatures.count > 0 else {
            return nil
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(Creatures.count)))
        var randomeNiceGuy:Creature? = nil
        for index in randomIndex...Creatures.count-1{
            if self.thinkScoreOf(AnotherCreatureID: Creatures[index].identifier.uniqueID) >= 0  {
                randomeNiceGuy = Creatures[index]
                break;
            }
        }
        if nil == randomeNiceGuy {
            for index in 0...randomIndex{
                if self.thinkScoreOf(AnotherCreatureID: Creatures[index].identifier.uniqueID) >= 0  {
                    randomeNiceGuy = Creatures[index]
                    break;
                }
            }
        }
        return randomeNiceGuy
    }
    
    public func thinking() {
    }
    
}

class DisguiseStrategyMemory:CreatureMemory{
    let showSelfCount:Int = 3
    let hideSelfCount:Int = 3
    var disguiseCounter:Int = 0
    var currentStrategyAction  = WorkAttitude.helpOther
    
    override func thinking() {
        //Think about how to disguise myself
        disguiseCounter += 1
        if disguiseCounter < showSelfCount {
            currentStrategyAction = .helpOther
        }else if disguiseCounter < showSelfCount+hideSelfCount {
            currentStrategyAction = .selfish
        }else {
            disguiseCounter = 0
            currentStrategyAction = .helpOther
        }
        
    }
    
}

