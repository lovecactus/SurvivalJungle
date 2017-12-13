//
//  SocialBehavior.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

typealias SurvivalResource = Double
typealias RewardResource = SurvivalResource
typealias WorkingCostResource = SurvivalResource

let resourceLimitRate:RewardResource = 20

class SocialBehavior {
    var creatures:[Creature]
    var seasonResource:RewardResource
    var statistic:SurvivalStatistic = SurvivalStatistic()

    init(with creatures:[Creature], seasonResource:inout RewardResource) {
        self.creatures = creatures
        self.seasonResource = seasonResource
    }

    func TeamWork() {
        let tuple = self.TeamUp(by: self.AssambleTeams())
        var cooperations = tuple.0
        let failedCreatures = tuple.1
        self.TeamCompetes(&cooperations)
        for index in cooperations.indices{
            self.Work(as: &(cooperations[index]))
            self.AssignReward(by: &(cooperations[index]))
        }
        
        for creatureID in failedCreatures.SingleCreatures {
            creatures.findCreatureBy(uniqueID: creatureID)?.WasteTime()
        }
        
//        statistic["Succeed Team"] = Double(cooperations.filter({ $0.Goal.Succeed}).count)
        statistic["Team Count"] = Double(cooperations.filter({ $0.Team.OtherMemberIDs.count > 0 }).count)
        statistic["Single Wanderer"] = Double(failedCreatures.SingleCreatures.count)
    }

    func AssambleTeams() -> [TeamWorkCooperation]{
        var teamProposals:[TeamWorkCooperation] = []
        for creature in creatures {
            if let teamProposal = creature.TeamPropose(from: creatures) {
                teamProposals.append(teamProposal)
            }
        }
        return teamProposals
    }
    
    func TeamUp(by teamsProposal:[TeamWorkCooperation]) -> ([TeamWorkCooperation],FailedTeamUp){
        var creaturesForTeamUp = creatures
        var gatheringTeams:[TeamWorkCooperation] = []
        var suspendingInvitations:[CreatureUniqueID:[TeamWorkCooperation]] = [:]
        for teamProposal in teamsProposal {
            for memberID in teamProposal.TeamProposal.OtherMemberIDs {
                var invitationsForThisMemberID:[TeamWorkCooperation]
                if let existingInvitations = suspendingInvitations[memberID] {
                    invitationsForThisMemberID = existingInvitations
                }else{
                    invitationsForThisMemberID = []
                }
                invitationsForThisMemberID.append(teamProposal)
                suspendingInvitations[memberID] = invitationsForThisMemberID
            }
            _ = creaturesForTeamUp.removeFirstCreatureBy(uniqueID: teamProposal.TeamProposal.TeamLeaderID)
            gatheringTeams.append(teamProposal)
        }
        
        for (memberID,invitationTeams) in suspendingInvitations {
            guard let creature = creaturesForTeamUp.findCreatureBy(uniqueID: memberID) else {
                continue
            }
            
            if let acceptedTeam = creature.AcceptInvite(to: invitationTeams) {
                for (index, team) in gatheringTeams.enumerated() {
                    if team.TeamProposal.TeamLeaderID == acceptedTeam.TeamProposal.TeamLeaderID {
                        gatheringTeams[index].Team.OtherMemberIDs.append(memberID)
                        gatheringTeams[index].Action.MemberActions[memberID] = creature.WorkEffort(to:team)
                    }
                }
                _ = creaturesForTeamUp.removeFirstCreatureBy(uniqueID: memberID)
            }else{
//                print ("leading another team")
            }
        }

        var failedTeamUpCreatures:[CreatureUniqueID] = []
        let restCreatureForTeamUp = creaturesForTeamUp
        restCreatureForTeamUp.forEach { (creature) in
            failedTeamUpCreatures.append(creature.identifier.uniqueID)
        }
        let failedTeamUp = FailedTeamUp(SingleCreatures: failedTeamUpCreatures)
        return (gatheringTeams,failedTeamUp)
    }
    
    func Work(as cooperation:inout TeamWorkCooperation){
        let totalTeamMember = cooperation.Action.WorkMemberCount()
        let bounsReward:RewardResource
        switch totalTeamMember {
        case 0...1:
            bounsReward = 0
            break
        case 2...4:
            bounsReward = 5
            break
        case 5...9:
            bounsReward = 6
            break
        case 10...Int.max:
            bounsReward = 7
            break
        default:
            bounsReward = 0
            break
        }
        
        var workingAverage = teamWorkBaseReword+bounsReward
        let maxAvailableAverage = seasonResource/resourceLimitRate
        
        if (workingAverage <= maxAvailableAverage){
            cooperation.Goal.Succeed = true
        }else{
            //Not sufficent resource
            cooperation.Goal.Succeed = false
            workingAverage = maxAvailableAverage
        }

        var totalReward = Double(totalTeamMember) * workingAverage + teamBounsReward
        if (seasonResource >= totalReward) {
            seasonResource -= totalReward
        }else if (seasonResource > 0) {
            totalReward = seasonResource
            seasonResource = 0
        }else {
            totalReward = 0
        }
        
        cooperation.Reward = CooperationReward(TotalRewards: totalReward, MemberRewards: [:])
//        statistic["TotalReward"] = statistic.getStatstic(for: "TotalReward") + Double(cooperation.Reward?.totalRewards ?? 0)
        if let leaderWorkingEffort = cooperation.Action.MemberActions[cooperation.Team.TeamLeaderID] {
            creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID)?.WorkCost(leaderWorkingEffort)
        }else{
            print(#function+": Critical error. Missing leader's effort ")
        }
        for memberID in cooperation.Team.OtherMemberIDs {
            guard let workingEffort = cooperation.Action.MemberActions[memberID] else {
                print(#function+": Critical error. Missing member's effort ")
                continue
            }
            creatures.findCreatureBy(uniqueID: memberID)?.WorkCost(workingEffort)
        }
    }
    
    func TeamCompetes(_ cooperations:inout [TeamWorkCooperation]){
        cooperations.shuffle()
        cooperations.sort { $0.Action.TotalEffort() > $1.Action.TotalEffort() }
    }

    func AssignReward(by cooperation:inout TeamWorkCooperation){
        guard let teamLeader = creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID) else {
            print ("AssignReward error, missing leader?")
            return
        }
        
        teamLeader.AssignReward(to: &cooperation)
        
        if let rewardAssignment = cooperation.Reward {
            for (memberID, rewardResource) in rewardAssignment.MemberRewards {
                creatures.findCreatureBy(uniqueID: memberID)?.GetReward(rewardResource, as: cooperation)
            }
        }
    }
    
    func CreaturesReproduction() -> [Creature]{
        var newBornCreatures:[Creature] = []
        
        creatures.forEach { (creature) in
            if let newBornCreature = creature.selfReproduction(){
                newBornCreatures.append(newBornCreature)
            }
        }

        return newBornCreatures
    }

}
