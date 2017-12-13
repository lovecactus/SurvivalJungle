//
//  Methodology.swift
//  Survival
//
//  Created by YANGWEI on 12/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation


let maxLeadingMembers = 20
let teamWorkConservativeReword:RewardResource = 4
let teamWorkIdealReword:RewardResource = 8

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
    var Talk:TalkMethodology = TalkMethodology()
    var Listen:ListenMethodology = ListenMethodology()
    var TeamLead:TeamLeadMethodology = TeamLeadMethodology()
    var TeamFollow:TeamFollowMethodology = TeamFollowMethodology()
}

class TalkMethodology{
    func talk(to creature:Creature,
              after result:WorkResult,
              memory :CreatureMemory,
              tellBlock:(_ Creature:Creature, _ AnotherCreatureID:String, _ Behavior:WorkAttitude) -> Void){
        //Don't know how to tell
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

class TeamLeadMethodology{
    func TeamPropose(from creature:Creature, on creatures:[Creature]) -> TeamWorkCooperation? {
        return nil
    }
    
    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        return
    }
}

class TeamFollowMethodology {
    func AcceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if creature.memory.shortMemory.isAssamblingTeam {
            return nil
        }
        
        return teams.randomPick()
    }
    
    func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .AllIn
    }

}

class TeamFollowMethodologyLazy:TeamFollowMethodology{
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .Lazy
    }
    
}

class TeamLeadMethodology_LeaderShip:TeamLeadMethodology{
    override func TeamPropose(from creature:Creature,
                              on creatures:[Creature]) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
//        let teamWorkMemories = creature.memory.thinkOfTeamWorkMemory()
//        let allHistoryMembers:[CreatureUniqueID] = Array(Set(teamWorkMemories.map{$0.teamWorkCooperation.Team.OtherMemberIDs}.flatMap {$0}))
//
//        let pickedMembers = allHistoryMembers.prefix(maxLeadingMembers)
//        teamMembers.append(contentsOf: pickedMembers)

        if let otherOldMemberIDs = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation.Team.OtherMemberIDs {
            teamMembers.append(contentsOf: otherOldMemberIDs)
        }
        
        if teamMembers.count < maxLeadingMembers{
            if let otherMemberCandidates = creatures.randomPick(some: maxLeadingMembers-teamMembers.count) {
                teamMembers.append(contentsOf: otherMemberCandidates.flatMap({ (creature) -> String? in
                    return creature.identifier.uniqueID
                }))
            }
        }
        
        let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
        let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
        creature.memory.shortMemory.isAssamblingTeam = true
        var cooperation = TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
        cooperation.Action.MemberActions[creature.identifier.uniqueID] = .AllIn
        return cooperation
    }

    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let averageSplitReward = Reward.TotalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.MemberRewards[memberID] = averageSplitReward
        }
        Reward.MemberRewards[coopertion.Team.TeamLeaderID] = averageSplitReward
        coopertion.Reward = Reward
    }
}

class TeamLeadMethodology_LeaderShip_NoLazy:TeamLeadMethodology_LeaderShip{
    override func TeamPropose(from creature:Creature,
                              on creatures:[Creature]) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let lastMemory = creature.memory.thinkOfLastTeamWorkMemory() {
            let otherOldMemberIDs = lastMemory.teamWorkCooperation.Team.OtherMemberIDs.filter({ (memberID) -> Bool in
                guard let memberEffort = lastMemory.teamWorkCooperation.Action.MemberActions[memberID] else {
                    return false
                }
                return memberEffort != .Lazy
            })
            teamMembers.append(contentsOf: otherOldMemberIDs)
        }
        
        if teamMembers.count < maxLeadingMembers{
            if let otherMemberCandidates = creatures.randomPick(some: maxLeadingMembers-teamMembers.count) {
                teamMembers.append(contentsOf: otherMemberCandidates.flatMap({ (creature) -> String? in
                    return creature.identifier.uniqueID
                }))
            }
        }
        
        let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
        let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
        creature.memory.shortMemory.isAssamblingTeam = true
        var cooperation = TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
        cooperation.Action.MemberActions[creature.identifier.uniqueID] = .AllIn
        return cooperation
    }
    
}

class TeamLeadMethodology_FairLeaderShip:TeamLeadMethodology_LeaderShip{
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let averageSplitReward = Reward.TotalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.MemberRewards[memberID] = averageSplitReward
        }
        Reward.MemberRewards[coopertion.Team.TeamLeaderID] = averageSplitReward
        coopertion.Reward = Reward
    }
}

class TeamLeadMethodology_FairLeaderShip_NoLazy:TeamLeadMethodology_LeaderShip_NoLazy{
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let averageSplitReward = Reward.TotalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.MemberRewards[memberID] = averageSplitReward
        }
        Reward.MemberRewards[coopertion.Team.TeamLeaderID] = averageSplitReward
        coopertion.Reward = Reward
    }
}

class TeamLeadMethodology_BetterSelfishLeaderShip:TeamLeadMethodology_LeaderShip{
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        var totalRewards = Reward.TotalRewards
        let leaderReward = totalRewards/3 //Take 1/3 first before assignment
        totalRewards -= leaderReward

        let restAverageReward = totalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.MemberRewards[memberID] = restAverageReward
            totalRewards -= restAverageReward
        }
        let restReward = totalRewards
        Reward.MemberRewards[coopertion.Team.TeamLeaderID] = restReward+leaderReward
        
        coopertion.Reward = Reward
    }
}

class TeamLeadMethodology_BetterSelfishLeaderShip_Adapter:TeamLeadMethodology_BetterSelfishLeaderShip{
    override func TeamPropose(from creature:Creature,
                              on creatures:[Creature]) -> TeamWorkCooperation? {
        if (creature.surviveResource > 0){
            return super.TeamPropose(from: creature, on: creatures)
        }
        creature.memory.shortMemory.isAssamblingTeam = false
        return nil
    }
}

class TeamLeadMethodology_SelfishLeaderShip_Adapter:TeamLeadMethodology_SelfishLeaderShip{
    override func TeamPropose(from creature:Creature,
                              on creatures:[Creature]) -> TeamWorkCooperation? {
        if (creature.surviveResource > 0){
            return super.TeamPropose(from: creature, on: creatures)
        }
        creature.memory.shortMemory.isAssamblingTeam = false
        return nil
    }
}

class TeamLeadMethodology_FairLeaderShip_Adapter:TeamLeadMethodology_FairLeaderShip{
    override func TeamPropose(from creature:Creature,
                              on creatures:[Creature]) -> TeamWorkCooperation? {
        if (creature.surviveResource > 0){
            return super.TeamPropose(from: creature, on: creatures)
        }
        creature.memory.shortMemory.isAssamblingTeam = false
        return nil
    }
}

class TeamLeadMethodology_SelfishLeaderShip:TeamLeadMethodology_LeaderShip{
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }

        var totalRewards = Reward.TotalRewards
        let leaderReward = totalRewards/2 //Take 1/2 first before assignment
        totalRewards -= leaderReward
        
        let restAverageReward = totalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.MemberRewards[memberID] = restAverageReward
            totalRewards -= restAverageReward
        }
        let restReward = totalRewards
        Reward.MemberRewards[coopertion.Team.TeamLeaderID] = restReward+leaderReward

        coopertion.Reward = Reward
    }
}

class TeamLeadMethodology_SelfishLeader_NoLazy:TeamLeadMethodology_LeaderShip_NoLazy{
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        var totalRewards = Reward.TotalRewards
        let otherReward = totalRewards/2
        let restAverageReward = otherReward/Double(coopertion.Team.OtherMemberIDs.count)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.MemberRewards[memberID] = restAverageReward
            totalRewards -= restAverageReward
        }
        
        let restReward = totalRewards
        Reward.MemberRewards[coopertion.Team.TeamLeaderID] = restReward
        coopertion.Reward = Reward
    }
}


class TeamFollowMethodology_ConservativeRewardFollower:TeamFollowMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.AcceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID, teamWorkConservativeReword)
            }
            let rewards = memorySlices.map{$0.Reward?.MemberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .AllIn
    }
}

class TeamFollowMethodology_SelfishRewardFollower:TeamFollowMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.AcceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID,teamWorkIdealReword)
            }
            let rewards = memorySlices.map{$0.Reward?.MemberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .AllIn
    }

}

class TeamFollowMethodology_FairFollower:TeamFollowMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.AcceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Int) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID,0)
            }
            
            let fair = memorySlices.map({ (cooperation) -> Int in
                guard let randomOtherMemberID = cooperation.Team.OtherMemberIDs.randomPick(),
                    let reward = cooperation.Reward,
                    let otherReward = reward.MemberRewards[randomOtherMemberID],
                    let leaderReward = reward.MemberRewards[leaderID] else {
                    return 0
                }

                if 0 == otherReward && 0 == leaderReward {
                    return 0
                }
                if otherReward >= leaderReward {
                    return 1
                }
                return -1
            })
            
            let score = fair.reduce(0, { (result, fair) -> Int in
                return result + fair
            })
            return (leaderID,score)
            }.sorted  { $0.1 > $1.1 }
        
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .AllIn
    }

}

class TeamFollowMethodology_ConservativeRewardFollower_Lazy:TeamFollowMethodology_ConservativeRewardFollower{
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .Lazy
    }
}

class TeamFollowMethodology_SelfishRewardFollower_Lazy:TeamFollowMethodology_SelfishRewardFollower{
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .Lazy
    }
}

class TeamFollowMethodology_FairFollower_Lazy:TeamFollowMethodology_FairFollower{
    override func WorkingEffort(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return .Lazy
    }
}


