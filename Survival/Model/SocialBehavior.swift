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

class SocialBehavior {
    var creatures:[Creature]
    var seasonResource:RewardResource
    var statistic:SurvivalStatistic = SurvivalStatistic()

    init(with creatures:[Creature], seasonResource:inout RewardResource) {
        self.creatures = creatures
        self.seasonResource = seasonResource
    }

    func TeamWork() {
        var cooperations:[TeamWorkCooperation] = self.TeamUp(by: self.AssambleTeams())
//        statistic["Team Count"] = Double(cooperations.filter({ $0.Team.OtherMemberIDs.count > 0 }).count)
        self.TeamCompetes(&cooperations)
        for index in cooperations.indices{
            self.Work(as: &(cooperations[index]))
            self.AssignReward(by: &(cooperations[index]))
        }
        statistic["Succeed Team"] = Double(cooperations.filter({ $0.Goal.Succeed}).count)
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
    
    func TeamUp(by teamsProposal:[TeamWorkCooperation]) -> [TeamWorkCooperation]{
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
                    }
                }
                _ = creaturesForTeamUp.removeFirstCreatureBy(uniqueID: memberID)
            }else{
//                print ("leading another team")
            }
        }

        let restCreatureForTeamUp = creaturesForTeamUp
        restCreatureForTeamUp.forEach { (creature) in
            let singleTeam = CooperationTeam(TeamLeaderID: creature.identifier.uniqueID, OtherMemberIDs: [])
            gatheringTeams.append(TeamWorkCooperation(Team: singleTeam, TeamProposal: singleTeam))
        }
        return gatheringTeams
    }
    
    func Work(as cooperation:inout TeamWorkCooperation){
        let totalTeamMember = cooperation.Team.OtherMemberIDs.count+1;
        let bounsReward:RewardResource
        switch totalTeamMember {
        case 0...1:
            bounsReward = 0
            break
        case 2...4:
            bounsReward = 0.1
            break
        case 5...9:
            bounsReward = 0.2
            break
        case 10...Int.max:
            bounsReward = 0.3
            break
        default:
            bounsReward = 0
            break
        }
        
        var totalReward = Double(totalTeamMember) * (teamWorkBaseReword+bounsReward)
        if (seasonResource >= totalReward) {
            seasonResource -= totalReward
            cooperation.Goal.Succeed = true
        }else if (seasonResource > 0) {
            totalReward = seasonResource
            seasonResource = 0
            cooperation.Goal.Succeed = true
        }else {
            totalReward = 0
            cooperation.Goal.Succeed = false
        }
        
        cooperation.Reward = CooperationReward(totalRewards: totalReward, memberRewards: [:])
//        statistic["TotalReward"] = statistic.getStatstic(for: "TotalReward") + Double(cooperation.Reward?.totalRewards ?? 0)
        creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID)?.WorkCost(teamWorkBaseCost)
        for memberID in cooperation.Team.OtherMemberIDs {
            creatures.findCreatureBy(uniqueID: memberID)?.WorkCost(teamWorkBaseCost)
        }
    }
    
    func TeamCompetes(_ cooperations:inout [TeamWorkCooperation]){
        cooperations.shuffle()
        cooperations.sort { $0.Team.OtherMemberIDs.count > $1.Team.OtherMemberIDs.count }
    }

    func AssignReward(by cooperation:inout TeamWorkCooperation){
        guard let teamLeader = creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID) else {
            print ("AssignReward error, missing leader?")
            return
        }
        
        teamLeader.AssignReward(to: &cooperation)
        
        if let rewardAssignment = cooperation.Reward {
            for (memberID, rewardResource) in rewardAssignment.memberRewards {
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
