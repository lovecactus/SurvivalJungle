//
//  Methodology.swift
//  Survival
//
//  Created by YANGWEI on 12/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
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
    var TeamUp:TeamUpMethodology = TeamUpMethodology()
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
        
        if let newFriend = memory.findNotBadGuyFromCandidate(candidate: &creatures){
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
        
        if let newFriend = memory.findNotBadGuyFromCandidate(candidate: &creatures){
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
        }else if let newFriend = memory.findNotBadGuyFromCandidate(candidate: &creatures){
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
        }else if let newFriend = memory.findNotBadGuyFromCandidate(candidate: &creatures){
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
        }else if let newFriend = memory.findNotBadGuyFromCandidate(candidate: &creatures){
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

class FindCoWorkerMethodology_TrustBestFriend:FindCoWorkerMethodology{
    override func findCoWorker(candidate creatures:inout [Creature], memory:CreatureMemory) -> FindCoWorkerMethodologyResult{
        var coWorkCreature:Creature?
        let oldFriends = memory.thinkOfCreatureScores()
        if let bestFriendID = oldFriends.sorted(by: { (arg0, arg1) -> Bool in
            let (_, score2) = arg1
            let (_, score1) = arg0
            return score1 > score2
        }).first(where: { (arg0) -> Bool in
            let (creatureID, _) = arg0
            return nil != creatures.findCreatureBy(uniqueID: creatureID)
        })?.key {
            coWorkCreature = creatures.findCreatureBy(uniqueID: bestFriendID)
        }else if let newFriend = memory.findNotBadGuyFromCandidate(candidate: &creatures){
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
        let workAction:WorkAttitude
        if memory.thinkScoreOf(AnotherCreatureID: AnotherCreature.identifier.uniqueID) >= 0 {
            workAction = .helpOther
        }else {
            workAction = .selfish
        }
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: workAction)
    }
}

class ResponseCoWorkerMethodology_ConservativeTitForTat:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        let workAction:WorkAttitude
        if memory.thinkScoreOf(AnotherCreatureID: AnotherCreature.identifier.uniqueID) > 0 {
            workAction = .helpOther
        }else {
            workAction = .selfish
        }
        return ResponseCoWorkerMethodologyResult(WorkingPartner:AnotherCreature, WorkingAttitude: workAction)
    }
}

class ResponseCoWorkerMethodology_OnceBadAlwaysBad:ResponseCoWorkerMethodology{
    override func responseCoWorker(to AnotherCreature:Creature, memory:CreatureMemory) -> ResponseCoWorkerMethodologyResult{
        let workAction:WorkAttitude
        let impressions = memory.thinkOfWorkAction(from: AnotherCreature.identifier.uniqueID)
        
        if impressions.first(where: {$0.Attitude == .selfish}) != nil {
            workAction = .selfish
        }else {
            workAction = .helpOther
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
        if let OldFriendID = memory.thinkOfOneRandomFriendID(),
            OldFriendID != creature.identifier.uniqueID,
            let behaviour = memory.thinkOfLastWorkActionImpression(from: OldFriendID)?.Attitude{
            tellBlock(creature, OldFriendID, behaviour)
        }
        
        if let OldEnemyID = memory.thinkOfOneRandomEnemyID(),
            OldEnemyID != creature.identifier.uniqueID,
            let behaviour = memory.thinkOfLastWorkActionImpression(from: OldEnemyID)?.Attitude{
            tellBlock(creature, OldEnemyID, behaviour)
        }
    }
}

class TalkMethodology_OnlyTellFriends:TalkMethodology{
    override func talk(to creature:Creature,
                       after result:WorkResult,
                       memory:CreatureMemory,
                       tellBlock:(_ Creature:Creature, _ AnotherCreatureID:String, _ Behavior:WorkAttitude) -> Void){
        if result == .doubleWin || result == .exploitation{ //The partner seems to be a nice one, tell him some thing
            if let OldFriendID = memory.thinkOfOneRandomFriendID(),
                OldFriendID != creature.identifier.uniqueID,
                let behaviour = memory.thinkOfLastWorkActionImpression(from: OldFriendID)?.Attitude{
                tellBlock(creature, OldFriendID, behaviour)
            }
            
            if let OldEnemyID = memory.thinkOfOneRandomEnemyID(),
                OldEnemyID != creature.identifier.uniqueID,
                let behaviour = memory.thinkOfLastWorkActionImpression(from: OldEnemyID)?.Attitude{
                tellBlock(creature, OldEnemyID, behaviour)
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

class ListenMethodology_TrustFriendsAndStranger:ListenMethodology{
    override func listen(from creature:Creature,
                         about anotherCreatureID:String,
                         behavior:WorkAttitude,
                         memory:CreatureMemory,
                         listenBlock:(_ creature:Creature, _ anotherCreatureID:String, _ behavior:WorkAttitude, _ story:String) -> Void){
        //Trust everyone
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        if memory.thinkScoreOf(AnotherCreatureID: creature.identifier.uniqueID) >= 0 {
            story += ". Looks like this creature was not bad, trust it"
            memory.remember(AnotherCreatureID: anotherCreatureID, Attitude: behavior)
        }else{
            story += ". Looks like this creature wasn't nice, don't trust it"
        }
        listenBlock(creature, anotherCreatureID, behavior, story)
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
        if memory.thinkScoreOf(AnotherCreatureID: creature.identifier.uniqueID) > 0 {
            story += ". Looks like this creature was not bad, trust it"
            memory.remember(AnotherCreatureID: anotherCreatureID, Attitude: behavior)
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
        memory.remember(AnotherCreatureID: anotherCreatureID, Attitude: behavior)
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

class TeamUpMethodology{
    func TeamPropose(from creature:Creature, on creatures:[Creature]) -> TeamWorkCooperation? {
        if arc4random_uniform(10)>6 {
            var teamMembers:[CreatureUniqueID] = []
            if let otherMemberCandidates = creatures.randomPick(some: 10) {
                teamMembers.append(contentsOf: otherMemberCandidates.flatMap({ (creature) -> String? in
                    return creature.identifier.uniqueID
                }))
            }
            let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
            let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
            creature.Memory.isAssamblingTeam = true
            return TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
            
        }else{
            creature.Memory.isAssamblingTeam = false
            return nil
        }
    }
    
    func AcceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if creature.Memory.isAssamblingTeam {
            return nil
        }
        return teams.randomPick()
    }
    
    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let averageSplitReward = Reward.totalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.memberRewards[memberID] = averageSplitReward
        }
        Reward.memberRewards[coopertion.Team.TeamLeaderID] = averageSplitReward
        coopertion.Reward = Reward
    }
}
