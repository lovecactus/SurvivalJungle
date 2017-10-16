//
//  Methodology.swift
//  Survival
//
//  Created by YANGWEI on 12/10/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import Foundation

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


struct Methodology {
    var FindCoWorker:FindCoWorkerMethodology = FindCoWorkerMethodology()
    var ResponseCoWorker:ResponseCoWorkerMethodology = ResponseCoWorkerMethodology()
    var Talk:TalkMethodology = TalkMethodology()
    var Listen:ListenMethodology = ListenMethodology()
}

struct FindCoWorkerMethodologyResult{
    var WorkingPartner:Creature? // Ceature may work alone, without a partner
    var WorkingAttitude:WorkAttitude
}

class FindCoWorkerMethodology{
    func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        //print (#class+#function+" is for override")
        return FindCoWorkerMethodologyResult(WorkingPartner:creatures.randomPick(), WorkingAttitude: .selfish)
    }
}

class FindCoWorkerMethodology_OpenNice:FindCoWorkerMethodology{
    override func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        var coWorkCreature:Creature?
        
        if let newFriend = memory.findNiceGuyFromCandidate(candidate: &creatures){
            coWorkCreature = newFriend
        }else {
            coWorkCreature = creatures.randomPick()
        }
        
        if let foundCoworker = coWorkCreature {
            return FindCoWorkerMethodologyResult(WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
        }
        return FindCoWorkerMethodologyResult(WorkingPartner:nil, WorkingAttitude: .selfish)
    }
}

class FindCoWorkerMethodology_OpenSelfish:FindCoWorkerMethodology{
    override func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        var coWorkCreature:Creature?
        
        if let newFriend = memory.findNiceGuyFromCandidate(candidate: &creatures){
            coWorkCreature = newFriend
        }else {
            coWorkCreature = creatures.randomPick()
        }
        
        if let foundCoworker = coWorkCreature {
            return FindCoWorkerMethodologyResult(WorkingPartner: foundCoworker, WorkingAttitude: .selfish)
        }
        return FindCoWorkerMethodologyResult(WorkingPartner:nil, WorkingAttitude: .selfish)
    }
}

class FindCoWorkerMethodology_ConservativeSelfish:FindCoWorkerMethodology{
    override func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        var coWorkCreature:Creature?
        
        if let oldFriend = memory.findOneFriendFromCandidate(candidate: &creatures){
            coWorkCreature = oldFriend
        }else if let newFriend = memory.findNiceGuyFromCandidate(candidate: &creatures){
            coWorkCreature = newFriend
        }else {
            coWorkCreature = creatures.randomPick()
        }
        
        if let foundCoworker = coWorkCreature {
            return FindCoWorkerMethodologyResult(WorkingPartner: foundCoworker, WorkingAttitude: .selfish)
        }
        return FindCoWorkerMethodologyResult(WorkingPartner:nil, WorkingAttitude: .selfish)
    }
}

class FindCoWorkerMethodology_ConservativeFriendly:FindCoWorkerMethodology{
    override func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        var coWorkCreature:Creature?
        
        if let oldFriend = memory.findOneFriendFromCandidate(candidate: &creatures){
            coWorkCreature = oldFriend
        }else if let newFriend = memory.findNiceGuyFromCandidate(candidate: &creatures){
            coWorkCreature = newFriend
        }else {
            coWorkCreature = creatures.randomPick()
        }
        
        if let foundCoworker = coWorkCreature {
            return FindCoWorkerMethodologyResult(WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
        }
        return FindCoWorkerMethodologyResult(WorkingPartner:nil, WorkingAttitude: .selfish)
    }
}

class FindCoWorkerMethodology_DisguiseForSomeTime:FindCoWorkerMethodology{
    override func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        var coWorkCreature:Creature?
        
        if let oldFriend = memory.findOneFriendFromCandidate(candidate: &creatures){
            coWorkCreature = oldFriend
        }else if let newFriend = memory.findNiceGuyFromCandidate(candidate: &creatures){
            coWorkCreature = newFriend
        }else {
            coWorkCreature = creatures.randomPick()
        }
        
        if let disguiseMemory = memory as? DisguiseStrategyMemory {
            if let foundCoworker = coWorkCreature{
                return FindCoWorkerMethodologyResult(WorkingPartner: foundCoworker, WorkingAttitude: disguiseMemory.currentStrategyAction)
            }
        }else{
            if let foundCoworker = coWorkCreature{
                return FindCoWorkerMethodologyResult(WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
            }
        }
        return FindCoWorkerMethodologyResult(WorkingPartner:nil, WorkingAttitude: .selfish)
    }
}

struct ResponseCoWorkerMethodologyResult{
    var WorkingPartner:Creature? // Ceature may work alone, without a partner
    var WorkingAttitude:WorkAttitude
}

class ResponseCoWorkerMethodology{
    func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        //print (#class+#function+" is for override")
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: .selfish)
    }
}

class ResponseCoWorkerMethodology_AlwaysNice:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: .helpOther)
    }
}

class ResponseCoWorkerMethodology_AlwaysSelfish:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: .selfish)
    }
}


class ResponseCoWorkerMethodology_TitForTat:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        var workAction = memory.thinkOf(AnotherCreature: AnotherCreature)
        if workAction == .none {
            workAction = .helpOther
        }
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: workAction)
    }
}

class ResponseCoWorkerMethodology_SelfishTitForTat:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        var workAction = memory.thinkOf(AnotherCreature: AnotherCreature)
        if workAction == .none {
            workAction = .selfish
        }
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: workAction)
    }
}

class ResponseCoWorkerMethodology_DisguiseForSomeTime:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        if let disguiseMemory = memory as? DisguiseStrategyMemory {
            return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: disguiseMemory.currentStrategyAction)
        }
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: .helpOther)
    }
}

class TalkMethodology{
    func talk(to creature:Creature,
              after result:WorkResult,
              memory :CreatureMemory,
              tellBlock:(_ Creature:Creature, _ AnotherCreatureID:String, _ Behavior:WorkAttitude) -> Void){
        //Don't know how to tell
    }
}

class TalkMethodology_TellEveryOne:TalkMethodology{
    override func talk(to creature:Creature,
                       after result:WorkResult,
                       memory:CreatureMemory,
                       tellBlock:(_ Creature:Creature, _ AnotherCreatureID:String, _ Behavior:WorkAttitude) -> Void){
        //Always tell others truth
        if let OldFriendID = memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
            tellBlock(creature, OldFriendID, memory.thinkOf(AnotherCreatureID: OldFriendID))
        }
        
        if let OldEnemyID = memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
            tellBlock(creature, OldEnemyID, memory.thinkOf(AnotherCreatureID: OldEnemyID))
        }
    }
}

class TalkMethodology_OnlyTellFriends:TalkMethodology{
    override func talk(to creature:Creature,
                       after result:WorkResult,
                       memory:CreatureMemory,
                       tellBlock:(_ Creature:Creature, _ AnotherCreatureID:String, _ Behavior:WorkAttitude) -> Void){
        if result == .doubleWin || result == .exploitation{ //The partner seems to be a nice one, tell him some thing
            if let OldFriendID = memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
                tellBlock(creature, OldFriendID, memory.thinkOf(AnotherCreatureID: OldFriendID))
            }
            
            if let OldEnemyID = memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
                tellBlock(creature, OldEnemyID, memory.thinkOf(AnotherCreatureID: OldEnemyID))
            }
        }
    }
}

class TalkMethodology_LieToEveryOne:TalkMethodology{
    override func talk(to creature:Creature,
                       after result:WorkResult,
                       memory:CreatureMemory,
                       tellBlock:(_ Creature:Creature, _ AnotherCreatureID:String, _ Behavior:WorkAttitude) -> Void){
        //Always lie to others
        if let OldFriendID = memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
            tellBlock(creature, OldFriendID, .selfish)
        }
        
        if let OldEnemyID = memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
            tellBlock(creature, OldEnemyID, .helpOther)
        }
    }
}

class ListenMethodology{
    func listen(from creature:Creature,
                about anotherCreatureID:String,
                behavior:WorkAttitude,
                memory:CreatureMemory,
                listenBlock:(_ creature:Creature, _ anotherCreatureID:String, _ behavior:WorkAttitude, _ story:String) -> Void){
        //Trust everyone
        listenBlock(creature, anotherCreatureID, behavior, "This creature is too stupid to listen")
    }
}

class ListenMethodology_OnlyTrustFriends:ListenMethodology{
    override func listen(from creature:Creature,
                         about anotherCreatureID:String,
                         behavior:WorkAttitude,
                         memory:CreatureMemory,
                         listenBlock:(_ creature:Creature, _ anotherCreatureID:String, _ behavior:WorkAttitude, _ story:String) -> Void){
        //Trust everyone
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        if (memory.thinkOf(AnotherCreature: creature) == .helpOther) {
            story += ". Looks like this creature was nice, trust it"
            memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        }else{
            story += ". Looks like this creature wasn't nice, don't trust it"
        }
        listenBlock(creature, anotherCreatureID, behavior, story)
    }

}

class ListenMethodology_TrustEveryOne:ListenMethodology{
    override func listen(from creature:Creature,
                         about anotherCreatureID:String,
                         behavior:WorkAttitude,
                         memory:CreatureMemory,
                         listenBlock:(_ creature:Creature, _ anotherCreatureID:String, _ behavior:WorkAttitude, _ story:String) -> Void){
        //Trust no one
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        story += ", and trust it"
        memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        listenBlock(creature, anotherCreatureID, behavior, story)
    }
    
}


class ListenMethodology_TrustNoOne:ListenMethodology{
    override func listen(from creature:Creature,
                         about anotherCreatureID:String,
                         behavior:WorkAttitude,
                         memory:CreatureMemory,
                         listenBlock:(_ creature:Creature, _ anotherCreatureID:String, _ behavior:WorkAttitude, _ story:String) -> Void){
        //Trust no one
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        story += ", but don't trust it"
        listenBlock(creature, anotherCreatureID, behavior, story)
    }
    
}

