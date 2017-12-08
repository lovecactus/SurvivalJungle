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
    var Talk:TalkMethodology = TalkMethodology()
    var Listen:ListenMethodology = ListenMethodology()
    var TeamUp:TeamUpMethodology = TeamUpMethodology()
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

let maxLeadingMembers = 10

class TeamUpMethodology{
    func TeamPropose(from creature:Creature, on creatures:[Creature]) -> TeamWorkCooperation? {
        return nil
    }
    
    func AcceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        return nil
    }
    
    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        return
    }
}


class TeamUpMethodology_Random:TeamUpMethodology{
    private func randomOfRate(_ rate:Int) -> Bool {
        return (arc4random_uniform(100) > rate)
    }
    
    override func TeamPropose(from creature:Creature, on creatures:[Creature]) -> TeamWorkCooperation? {
        if randomOfRate(70) {
            var teamMembers:[CreatureUniqueID] = []
            if let otherMemberCandidates = creatures.randomPick(some: maxLeadingMembers) {
                teamMembers.append(contentsOf: otherMemberCandidates.flatMap({ (creature) -> String? in
                    return creature.identifier.uniqueID
                }))
            }
            let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
            let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
            creature.memory.shortMemory.isAssamblingTeam = true
            return TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
            
        }else{
            creature.memory.shortMemory.isAssamblingTeam = false
            return nil
        }
    }
    
    override func AcceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if creature.memory.shortMemory.isAssamblingTeam {
            return nil
        }
        return teams.randomPick()
    }
    
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
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

class TeamUpMethodology_LeaderShip:TeamUpMethodology{
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
        return TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
    }

    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
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


class TeamUpMethodology_SelfishLeader:TeamUpMethodology_LeaderShip{
    override func AssignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }

        var totalRewards = Reward.totalRewards
        let otherReward = totalRewards/2
        let restAverageReward = otherReward/Double(coopertion.Team.OtherMemberIDs.count)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.memberRewards[memberID] = restAverageReward
            totalRewards -= restAverageReward
        }

        let restReward = totalRewards
        Reward.memberRewards[coopertion.Team.TeamLeaderID] = restReward
        coopertion.Reward = Reward
    }
}



class TeamUpMethodology_Follower:TeamUpMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        return teams.randomPick()
    }
    
}

class TeamUpMethodology_ConservativeFollower:TeamUpMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID, teamWorkBaseReword/2)
            }
            let rewards = memorySlices.map{$0.Reward?.memberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
}

let teamWorkIdealReword:RewardResource = teamWorkBaseReword

class TeamUpMethodology_EliteFollower:TeamUpMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID,teamWorkIdealReword)
            }
            let rewards = memorySlices.map{$0.Reward?.memberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
}
