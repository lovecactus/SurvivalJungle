//
//  Methodology_TeamLead.swift
//  Survival
//
//  Created by YANGWEI on 22/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

class TeamLeadMethodology{
    var teamLeading:TeamLeadingMethodology = TeamLeadingMethodology()
    var teamUp:TeamUpMethodology = TeamUpMethodology()
    var teamExploitation:TeamExploitationMethodology = TeamExploitationMethodology()
    var teamAssign:TeamAssignRewardMethodology = TeamAssignRewardMethodology()
    
    public static func randomMethodGenerator() -> TeamLeadMethodology {
        let newRandomMethod = TeamLeadMethodology()
        newRandomMethod.teamLeading = TeamLeadingMethodology.randomMethodGenerator()
        newRandomMethod.teamUp = TeamUpMethodology.randomMethodGenerator()
        newRandomMethod.teamExploitation = TeamExploitationMethodology.randomMethodGenerator()
        newRandomMethod.teamAssign = TeamAssignRewardMethodology.rewardRandomMethodGenerator()

        return newRandomMethod
    }

    public func descriptor() -> String {
        let descriptor:String = teamLeading.descriptor()+"-"+teamUp.descriptor()+"-"+teamExploitation.descriptor()+"-"+teamAssign.descriptor()
        return descriptor
    }

}

class TeamLeadingMethodology{
    public static func randomMethodGenerator() -> TeamLeadingMethodology {
        let method:TeamLeadingMethodology
        switch Int(arc4random_uniform(4)) {
        case 0:
            method = TeamLeadingMethodology_Adapter()
            break
        case 1:
            method = TeamLeadingMethodology_BornLeader()
            break
        case 2...3:
            method = TeamLeadingMethodology_BornFollower()
            break
        default:
            method = TeamLeadingMethodology()
        }
        return method
    }

    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: TeamLeadingMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamLeadingMethodology_BornLeader.self):
            descriptor = descriptor + "BornLeader"
            break
        case String(describing: TeamLeadingMethodology_BornFollower.self):
            descriptor = descriptor + "BornFollower"
            break
        case String(describing: TeamLeadingMethodology_Adapter.self):
            descriptor = descriptor + "Adapter"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }

    func wantToBeLeader(as creature:Creature) -> Bool {
        return false
    }
}

class TeamLeadingMethodology_BornLeader:TeamLeadingMethodology{
    override func wantToBeLeader(as creature:Creature) -> Bool {
        return true
    }
}

class TeamLeadingMethodology_BornFollower:TeamLeadingMethodology{
    override func wantToBeLeader(as creature:Creature) -> Bool {
        return false
    }
}

class TeamLeadingMethodology_Adapter:TeamLeadingMethodology{
    override func wantToBeLeader(as creature:Creature) -> Bool {
        if let cooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            //If it's self leading
            if cooperation.Team.TeamLeaderID == creature.identifier.uniqueID{
                if cooperation.Team.OtherMemberIDs.count > 0
                    || cooperation.Goal.succeed{
                    //If goes good, keep leading
                    return true
                }else {
                    //otherwise follow other team to make some money
                    return false
                }
            }else {
                //Work good as a follower, keep as-is
                if (cooperation.Goal.succeed) {
                    return false
                }else if let selfReward = cooperation.Reward?.memberRewards[creature.identifier.uniqueID], selfReward >= teamWorkBaseCost {
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

class TeamUpMethodology{
    public static func randomMethodGenerator() -> TeamUpMethodology {
        let method:TeamUpMethodology
        switch Int(arc4random_uniform(4)) {
        case 0:
            method = TeamUpMethodology_AnyOneOK()
            break
        case 1:
            method = TeamUpMethodology_NoLazy()
            break
        case 2:
            method = TeamUpMethodology_ValueDigger()
            break
        case 3:
            method = TeamUpMethodology_OnlyAllIn()
            break
        default:
            method = TeamUpMethodology()
        }
        return method
    }
    
    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: TeamUpMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamUpMethodology_AnyOneOK.self):
            descriptor = descriptor + "AnyOneOK"
            break
        case String(describing: TeamUpMethodology_NoLazy.self):
            descriptor = descriptor + "NoLazy"
            break
        case String(describing: TeamUpMethodology_ValueDigger.self):
            descriptor = descriptor + "ValueDigger"
            break
        case String(describing: TeamUpMethodology_OnlyAllIn.self):
            descriptor = descriptor + "OnlyAllIn"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }

    func teamPropose(from creature:Creature, on creatures:inout CreatureGroup) -> TeamWorkCooperation? {
        return nil
    }
}

class TeamUpMethodology_AnyOneOK:TeamUpMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout CreatureGroup) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let otherOldMemberIDs = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation?.Team.OtherMemberIDs {
            teamMembers.append(contentsOf: otherOldMemberIDs)
        }
        
        if teamMembers.count < maxLeadingMembers{
            teamMembers.append(contentsOf: creatures.randomPick(some: maxLeadingMembers-teamMembers.count).flatMap({ (creature) -> String? in
                return creature.identifier.uniqueID
            }))
        }
        
        let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
        let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
        creature.memory.shortMemory.isAssamblingTeam = true
        var cooperation = TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
        return cooperation
    }

}

class TeamUpMethodology_NoLazy:TeamUpMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout CreatureGroup) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let lastCooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            let otherOldMemberIDs = lastCooperation.Team.OtherMemberIDs.filter({ (memberID) -> Bool in
                guard let memberEffort = lastCooperation.Action.memberActions[memberID] else {
                    return false
                }
                return memberEffort.attitude != .Lazy
            })
            teamMembers.append(contentsOf: otherOldMemberIDs)
        }
        
        if teamMembers.count < maxLeadingMembers{
            teamMembers.append(contentsOf: creatures.randomPick(some: maxLeadingMembers-teamMembers.count).flatMap({ (creature) -> String? in
                return creature.identifier.uniqueID
            }))
        }
        
        let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
        let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
        creature.memory.shortMemory.isAssamblingTeam = true
        var cooperation = TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
        return cooperation
    }
}

class TeamUpMethodology_OnlyAllIn:TeamUpMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout CreatureGroup) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let lastCooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            let otherOldMemberIDs = lastCooperation.Team.OtherMemberIDs.filter({ (memberID) -> Bool in
                guard let memberEffort = lastCooperation.Action.memberActions[memberID] else {
                    return false
                }
                return memberEffort.attitude == .AllIn
            })
            teamMembers.append(contentsOf: otherOldMemberIDs)
        }
        
        if teamMembers.count < maxLeadingMembers{
            teamMembers.append(contentsOf: creatures.randomPick(some: maxLeadingMembers-teamMembers.count).flatMap({ (creature) -> String? in
                return creature.identifier.uniqueID
            }))
        }
        
        let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
        let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
        creature.memory.shortMemory.isAssamblingTeam = true
        var cooperation = TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
        return cooperation
    }
}

class TeamUpMethodology_ValueDigger:TeamUpMethodology{
    override func teamPropose(from creature:Creature,
                              on creatures:inout CreatureGroup) -> TeamWorkCooperation? {
        var teamMembers:[CreatureUniqueID] = []
        if let lastCooperation = creature.memory.thinkOfLastTeamWorkMemory()?.teamWorkCooperation {
            let otherOldMemberIDs = lastCooperation.Team.OtherMemberIDs.filter({ (memberID) -> Bool in
                guard let memberEffort = lastCooperation.Action.memberActions[memberID] else {
                    return false
                }
                return memberEffort.value >= EffortValue(MaturedEffortBase*TeamCooperationAttitudeRate.ResponsiveRate.rawValue)
            })
            teamMembers.append(contentsOf: otherOldMemberIDs)
        }
        
        if teamMembers.count < maxLeadingMembers{
            teamMembers.append(contentsOf: creatures.randomPick(some: maxLeadingMembers-teamMembers.count).flatMap({ (creature) -> String? in
                return creature.identifier.uniqueID
            }))
        }
        
        let teamProposal = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: teamMembers)
        let currentTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
        creature.memory.shortMemory.isAssamblingTeam = true
        var cooperation = TeamWorkCooperation(Team: currentTeam, TeamProposal: teamProposal)
        cooperation.Action.memberActions[creature.identifier.uniqueID] = creature.workEffort(to: cooperation)
        return cooperation
    }
}

class TeamExploitationMethodology{
    public static func randomMethodGenerator() -> TeamExploitationMethodology {
        let method:TeamExploitationMethodology
        switch Int(arc4random_uniform(3)) {
        case 0:
            method = TeamExploitationMethodology_Fair()
            break
        case 1:
            method = TeamExploitationMethodology_Selfish()
            break
        case 2:
            method = TeamExploitationMethodology_BetterSelfish()
            break
        default:
            method = TeamExploitationMethodology()
        }
        return method
    }

    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: TeamExploitationMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamExploitationMethodology_Fair.self):
            descriptor = descriptor + "Fair"
            break
        case String(describing: TeamExploitationMethodology_Selfish.self):
            descriptor = descriptor + "Selfish"
            break
        case String(describing: TeamExploitationMethodology_BetterSelfish.self):
            descriptor = descriptor + "BetterSelfish"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }

    func assignRewardSelfFirst(to coopertion:inout TeamWorkCooperation) {
        return
    }
}

class TeamExploitationMethodology_Fair:TeamExploitationMethodology{
    override func assignRewardSelfFirst(to coopertion:inout TeamWorkCooperation) {
        return
    }
}

class TeamExploitationMethodology_Selfish:TeamExploitationMethodology{
    override func assignRewardSelfFirst(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let leaderReward = Reward.totalRewards/2 //Take 1/2 first before assignment
        Reward.totalRewards -= leaderReward
        Reward.memberRewards[coopertion.Team.TeamLeaderID] = (Reward.memberRewards[coopertion.Team.TeamLeaderID] ?? 0) + leaderReward
        Reward.leaderExploitation = leaderReward
        coopertion.Reward = Reward
    }
}

class TeamExploitationMethodology_BetterSelfish:TeamExploitationMethodology{
    override func assignRewardSelfFirst(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let leaderReward = Reward.totalRewards/3 //Take 1/3 first before assignment
        Reward.totalRewards -= leaderReward
        Reward.memberRewards[coopertion.Team.TeamLeaderID] = (Reward.memberRewards[coopertion.Team.TeamLeaderID] ?? 0) + leaderReward
        Reward.leaderExploitation = leaderReward
        coopertion.Reward = Reward
    }
}

class TeamAssignRewardMethodology {
    public static func rewardRandomMethodGenerator() -> TeamAssignRewardMethodology {
        let method:TeamAssignRewardMethodology
        switch Int(arc4random_uniform(2)) {
        case 0:
            method = TeamAssignRewardMethodology_AverageSplit()
            break
        case 1:
            method = TeamAssignRewardMethodology_WorkMoreEarnMore()
            break
        default:
            method = TeamAssignRewardMethodology()
        }
        return method
    }
    
    public func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: TeamAssignRewardMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamAssignRewardMethodology_AverageSplit.self):
            descriptor = descriptor + "Average"
            break
        case String(describing: TeamAssignRewardMethodology_WorkMoreEarnMore.self):
            descriptor = descriptor + "WorkMoreEarnMore"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }

    func assignReward(to coopertion:inout TeamWorkCooperation) {
    }
}

class TeamAssignRewardMethodology_WorkMoreEarnMore:TeamAssignRewardMethodology{
    override func assignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        let allEffortValue = coopertion.Action.totalEffort()
        let originalTotalRewards = Reward.totalRewards
        var totalRewards = Reward.totalRewards
        for memberID in coopertion.Team.OtherMemberIDs {
            guard let memberEffort = coopertion.Action.memberActions[memberID] else {
                print(#function+": Critical error. Missing member's effort")
                continue
            }
            let memberEffortValue = memberEffort.effortValue()
            let memberReward = originalTotalRewards/allEffortValue*memberEffortValue
            Reward.memberRewards[memberID] = (Reward.memberRewards[memberID] ?? 0) + memberReward
            totalRewards -= memberReward
            if (totalRewards < 0){
                print(#function+": Critical error. Invalid total rewards")
            }
        }
        
        let restReward = totalRewards
        Reward.memberRewards[coopertion.Team.TeamLeaderID] = (Reward.memberRewards[coopertion.Team.TeamLeaderID] ?? 0) + restReward
        
        coopertion.Reward = Reward
    }
}

class TeamAssignRewardMethodology_AverageSplit:TeamAssignRewardMethodology{
    override func assignReward(to coopertion:inout TeamWorkCooperation) {
        guard var Reward = coopertion.Reward else{
            return
        }
        
        var totalRewards = Reward.totalRewards
        
        let restAverageReward = totalRewards/Double(coopertion.Team.OtherMemberIDs.count+1)
        for memberID in coopertion.Team.OtherMemberIDs {
            Reward.memberRewards[memberID] = (Reward.memberRewards[memberID] ?? 0) + restAverageReward
            totalRewards -= restAverageReward
        }
        let restReward = totalRewards
        Reward.memberRewards[coopertion.Team.TeamLeaderID] = (Reward.memberRewards[coopertion.Team.TeamLeaderID] ?? 0) + restReward
        
        coopertion.Reward = Reward
    }
}
