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

let resourceLimitRate:RewardResource = 0.8

class SocialBehavior {
    var creatures:CreatureGroup
    var seasonResource:RewardResource
    var statistic:SurvivalStatistic = SurvivalStatistic()

    init(with creatures:inout CreatureGroup, seasonResource:inout RewardResource) {
        self.creatures = creatures
        self.seasonResource = seasonResource
    }
    
    func SeasonWork() {
        let tuple = self.TeamUp(by: self.AssambleTeams())
        var cooperations = tuple.0
        var failedCreatures = tuple.1
        self.TeamCompetes(&cooperations)
        self.TeamWork(&cooperations)
        self.SingleWandering(&failedCreatures)
//        self.Community()

        
//        statistic["Succeed Team"] = Double(cooperations.filter({ $0.Goal.Succeed}).count)
//        statistic["TeamUp Count"] = Double(cooperations.filter({ $0.Team.OtherMemberIDs.count > 0 }).count)
        statistic["Leader Count"] = Double(cooperations.count)
        statistic["Member Count"] = Double(cooperations.filter({ $0.Team.OtherMemberIDs.count > 0 }).reduce(0, { (result, cooperation) -> Int in
            return result + cooperation.Team.OtherMemberIDs.count
            }))
        statistic["Single Wanderer"] = Double(failedCreatures.SingleCreatures.count)
        statistic["Total Income"] = cooperations.map({$0.Reward?.memberRewards}).flatMap({$0}).flatMap({$0}).map({(key: CreatureUniqueID, value: RewardResource) -> RewardResource in return value}).reduce(0, +)
        statistic["Total Cost"] = cooperations.map({$0.Action.workingCosts}).flatMap({$0}).flatMap({ (key:CreatureUniqueID, value: WorkingCostResource) -> WorkingCostResource? in return value}).reduce(0, +)
    }

    func AssambleTeams() -> [TeamWorkCooperation]{
        var teamProposals:[TeamWorkCooperation] = []
        for (_, creature) in creatures {
            if let teamProposal = creature.teamPropose(from: &creatures) {
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
            creaturesForTeamUp.removeValue(forKey: teamProposal.TeamProposal.TeamLeaderID)
            gatheringTeams.append(teamProposal)
        }
        
        for (memberID,invitationTeams) in suspendingInvitations {
            guard let creature = creaturesForTeamUp.findCreatureBy(uniqueID: memberID) else {
                continue
            }
            
            if let acceptedTeam = creature.acceptInvite(to: invitationTeams) {
                for (index, team) in gatheringTeams.enumerated() {
                    if team.TeamProposal.TeamLeaderID == acceptedTeam.TeamProposal.TeamLeaderID {
                        gatheringTeams[index].Team.OtherMemberIDs.append(memberID)
                        gatheringTeams[index].Action.memberActions[memberID] = creature.workEffort(to:team)
                    }
                }
                creaturesForTeamUp.removeValue(forKey: memberID)
            }else{
//                print ("leading another team")
            }
        }

        var failedTeamUpCreatures:[CreatureUniqueID] = []
        let restCreatureForTeamUp = creaturesForTeamUp
        restCreatureForTeamUp.forEach { (_, creature) in
            failedTeamUpCreatures.append(creature.identifier.uniqueID)
        }
        let failedTeamUp = FailedTeamUp(SingleCreatures: failedTeamUpCreatures)
        return (gatheringTeams,failedTeamUp)
    }
    
    func Work(as cooperation:inout TeamWorkCooperation){
        let totalTeamMember = cooperation.Action.workMemberCount()
        let effort = cooperation.Action.totalEffort()
        let bounsReward:RewardResource
        switch totalTeamMember {
        case 0...1:
            bounsReward = 0
            break
        case 2...4:
            bounsReward = 10
            break
        case 5...9:
            bounsReward = 20
            break
        case 10...Int.max:
            bounsReward = 30
            break
        default:
            bounsReward = 0
            break
        }
        
        var totalReward = effort + bounsReward
        let maxAvailableReward = seasonResource*resourceLimitRate
        
        if (totalReward <= maxAvailableReward){
            cooperation.Goal.succeed = true
        }else{
            //Not sufficent resource
            cooperation.Goal.succeed = false
            totalReward = maxAvailableReward
        }

        totalReward = round(totalReward)
        
        if (seasonResource >= totalReward) {
            seasonResource -= totalReward
        }else if (seasonResource > 0) {
            totalReward = seasonResource
            seasonResource = 0
        }else {
            totalReward = 0
        }
        
        cooperation.Reward = CooperationReward(totalRewards: totalReward, leaderExploitation: 0, memberRewards: [:])
//        statistic["TotalReward"] = statistic.getStatstic(for: "TotalReward") + Double(cooperation.Reward?.totalRewards ?? 0)
        if let leaderWorkingEffort = cooperation.Action.memberActions[cooperation.Team.TeamLeaderID] {
            if let workingCreature = creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID) {
                cooperation.Action.workingCosts[cooperation.Team.TeamLeaderID] = workingCreature.workCost(leaderWorkingEffort)
                workingCreature.writeStory("Work with "+String(cooperation.Team.OtherMemberIDs.count)+" other members")
            }
        }else{
            print(#function+": Critical error. Missing leader's effort ")
        }
        for memberID in cooperation.Team.OtherMemberIDs {
            guard let workingEffort = cooperation.Action.memberActions[memberID] else {
                print(#function+": Critical error. Missing member's effort ")
                continue
            }
            if let workingCreature = creatures.findCreatureBy(uniqueID: memberID) {
                cooperation.Action.workingCosts[memberID] = workingCreature.workCost(workingEffort)
                workingCreature.writeStory("Work with "+String(cooperation.Team.OtherMemberIDs.count)+" other members")
            }
        }
    }
    
    func TeamCompetes(_ cooperations:inout [TeamWorkCooperation]){
        cooperations.shuffle()
        cooperations.sort { $0.Action.totalEffort() > $1.Action.totalEffort() }
//        statistic["Avg. Competes"] = cooperations.map({$0.Action.TotalEffort()}).average
    }

    func TeamWork(_ cooperations:inout [TeamWorkCooperation]){
        for index in cooperations.indices{
            self.Work(as: &(cooperations[index]))
            self.AssignReward(by: &(cooperations[index]))
        }
    }
    
    func SingleWandering(_ failedCreatures:inout FailedTeamUp){
        for creatureID in failedCreatures.SingleCreatures {
            creatures.findCreatureBy(uniqueID: creatureID)?.wasteTime()
        }

    }

    func Community(){
    }

    func AssignReward(by cooperation:inout TeamWorkCooperation){
        guard let teamLeader = creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID) else {
            print ("AssignReward error, missing leader?")
            return
        }
        
        teamLeader.assignReward(to: &cooperation)
        
        if let rewardAssignment = cooperation.Reward {
            for (memberID, rewardResource) in rewardAssignment.memberRewards {
                creatures.findCreatureBy(uniqueID: memberID)?.getReward(rewardResource, as: cooperation)
            }
        }
    }
    
    func CreaturesReproduction() -> [Creature]{
        var newBornCreatures:[Creature] = []
        
        creatures.filter{$0.value.method.reproduction.reproductionType.isSelfReproduction()}.forEach{(_, creature) in
            if creature.method.reproduction.reproductionType.isSelfReproduction(){
                if creature.method.reproduction.matingMature.readyToReproduction(as: creature) {
                    newBornCreatures.append(creature.selfReproduction())
                }
            }
        }

        var courtships:[CreatureUniqueID:[Creature]] = [:]
        let maturedMales = creatures.filter{$0.value.method.reproduction.reproductionType.isSelfReproduction() == false}
            .filter{$0.value.method.reproduction.gender.gender() == .Male
                && $0.value.method.reproduction.matingMature.readyToReproduction(as: $0.value)}
            .map{$0.value}

        var maturedFemales = creatures.filter{$0.value.method.reproduction.reproductionType.isSelfReproduction() == false}
            .filter{$0.value.method.reproduction.gender.gender() == .Female
                && $0.value.method.reproduction.matingMature.readyToReproduction(as: $0.value)}
            .map{$0.value}
        
        maturedMales.forEach { (creature) in
            guard let wantingCreatureID = creature.findAnIdealLover(in: &maturedFemales)?.identifier.uniqueID else {return}
            
            var courtshipOfThisCreature:[Creature]
            if let existingCourtships = courtships[wantingCreatureID] {
                courtshipOfThisCreature = existingCourtships
            }else{
                courtshipOfThisCreature = []
            }
            courtshipOfThisCreature.append(creature)
            courtships[wantingCreatureID] = courtshipOfThisCreature
        }

        courtships.forEach { (femaleID, maleLovers) in
            guard let femaleCreature = creatures[femaleID] else {return}
            guard femaleCreature.method.reproduction.matingMature.readyToReproduction(as: femaleCreature) else {return}
            if let chosenOne = femaleCreature.pickAnIdealLover(from: maleLovers) {
                newBornCreatures.append(femaleCreature.matingReproduction(with: chosenOne))
            }
        }
    
        return newBornCreatures
    }

}
