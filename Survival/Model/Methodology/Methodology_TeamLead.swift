//
//  Methodology_TeamLead.swift
//  Survival
//
//  Created by YANGWEI on 22/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

class TeamLeadMethodology{
    public static func teamLeadRandomMethodGenerator() -> TeamLeadMethodology {
        let method:TeamLeadMethodology
        switch Int(arc4random_uniform(14)) {
        case 0:
            method = TeamLeadMethodology_FairLeaderShip()
            break
        case 1:
            method = TeamLeadMethodology_SelfishLeaderShip()
            break
        case 2:
            method = TeamLeadMethodology_FairLeaderShip_Adapter()
            break
        case 3:
            method = TeamLeadMethodology_BetterSelfishLeaderShip()
            break
        case 4:
            method = TeamLeadMethodology_SelfishLeaderShip_Adapter()
            break
        case 5:
            method = TeamLeadMethodology_BetterSelfishLeaderShip_Adapter()
            break
        case 6...13: //More than half rate for follower
            method = TeamLeadMethodology_OnlyFollow()
            break
//        case 7:
//            method = TeamLeadMethodology_LeaderShip_NoLazy()
//            break
//        case 8:
//            method = TeamLeadMethodology_SelfishLeader_NoLazy()
//            break
//        case 9:
//            method = TeamLeadMethodology_FairLeaderShip_NoLazy()
//            break
        default:
            method = TeamLeadMethodology()
        }
        return method
    }

    func teamPropose(from creature:Creature, on creatures:inout [Creature]) -> TeamWorkCooperation? {
        return nil
    }
    
    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        return
    }
}

class TeamLeadMethodology_OnlyFollow:TeamLeadMethodology{
}

class TeamLeadMethodology_LeaderShip:TeamLeadMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout [Creature]) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        //        let teamWorkMemories = creature.memory.thinkOfTeamWorkMemory()
        //        let allHistoryMembers:[CreatureUniqueID] = Array(Set(teamWorkMemories.map{$0.teamWorkCooperation.Team.OtherMemberIDs}.flatMap {$0}))
        //
        //        let pickedMembers = allHistoryMembers.prefix(maxLeadingMembers)
        //        teamMembers.append(contentsOf: pickedMembers)
        
        if let otherOldMemberIDs = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation?.Team.OtherMemberIDs {
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
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
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
    override func teamPropose(from creature:Creature,
                              on creatures:inout [Creature]) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let lastCooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            let otherOldMemberIDs = lastCooperation.Team.OtherMemberIDs.filter({ (memberID) -> Bool in
                guard let memberEffort = lastCooperation.Action.memberActions[memberID] else {
                    return false
                }
                return memberEffort.Attitude != .Lazy
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
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
        return cooperation
    }
    
}

class TeamLeadMethodology_LeaderShip_ValueDigger:TeamLeadMethodology_LeaderShip{
    override func teamPropose(from creature:Creature,
                              on creatures:inout [Creature]) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let lastCooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            let otherOldMemberIDs = lastCooperation.Team.OtherMemberIDs.filter({ (memberID) -> Bool in
                guard let memberEffort = lastCooperation.Action.memberActions[memberID] else {
                    return false
                }
                return memberEffort.Value >= EffortValue(MaturedEffortBase*TeamCooperationAttitudeRate.ResponsiveRate.rawValue)
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
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
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

class TeamLeadMethodology_BetterSelfishLeaderShip_Adapter:TeamLeadMethodology_BetterSelfishLeaderShip, TeamLeadAdapterMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout [Creature]) -> TeamWorkCooperation? {
        if self.AdapterCurrentSituationAsLeader(as: creature) {
            return super.teamPropose(from: creature, on: &creatures)
        }
        creature.memory.shortMemory.isAssamblingTeam = false
        return nil
    }
}

protocol TeamLeadAdapterMethodology {
    func AdapterCurrentSituationAsLeader(as creature:Creature) -> Bool
}

extension TeamLeadAdapterMethodology where Self: TeamLeadMethodology{
    func AdapterCurrentSituationAsLeader(as creature:Creature) -> Bool {
        if let cooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            //If it's self leading
            if cooperation.Team.TeamLeaderID == creature.identifier.uniqueID{
                if cooperation.Team.OtherMemberIDs.count > 0
                    || cooperation.Goal.Succeed{
                    //If goes good, keep leading
                    return true
                }else {
                    //otherwise follow other team to make some money
                    return false
                }
            }else {
                //Work good as a follower, keep as-is
                if (cooperation.Goal.Succeed) {
                    return false
                }else if let selfReward = cooperation.Reward?.MemberRewards[creature.identifier.uniqueID], selfReward >= teamWorkBaseCost {
                    return false
                } else {
                    //Try a lead
                    return true
                }
            }
        }
        //Wandering last season, lead for a try
        return true
    }
    
}

class TeamLeadMethodology_SelfishLeaderShip_Adapter:TeamLeadMethodology_SelfishLeaderShip, TeamLeadAdapterMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout [Creature]) -> TeamWorkCooperation? {
        if self.AdapterCurrentSituationAsLeader(as: creature) {
            return super.teamPropose(from: creature, on: &creatures)
        }
        creature.memory.shortMemory.isAssamblingTeam = false
        return nil
    }
}

class TeamLeadMethodology_FairLeaderShip_Adapter:TeamLeadMethodology_FairLeaderShip, TeamLeadAdapterMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout [Creature]) -> TeamWorkCooperation? {
        if self.AdapterCurrentSituationAsLeader(as: creature) {
            return super.teamPropose(from: creature, on: &creatures)
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
