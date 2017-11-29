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
        statistic["TeamCount"] = Double(cooperations.count)
        self.TeamCompetes(&cooperations)
        for index in cooperations.indices{
            self.Work(as: &(cooperations[index]))
            self.AssignReward(by: &(cooperations[index]))
        }
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
            bounsReward = 1
            break
        case 2...5:
            bounsReward = 2
            break
        case 5...10:
            bounsReward = 3
            break
        case 10...Int.max:
            bounsReward = 3
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
        statistic["TotalReward"] = statistic.getStatstic(for: "TotalReward") + Double(cooperation.Reward?.totalRewards ?? 0)
        creatures.findCreatureBy(uniqueID: cooperation.Team.TeamLeaderID)?.WorkCost(teamWorkBaseCost)
        for memberID in cooperation.Team.OtherMemberIDs {
            creatures.findCreatureBy(uniqueID: memberID)?.WorkCost(teamWorkBaseCost)
        }
        
    }
    
    func TeamCompetes(_ cooperations:inout [TeamWorkCooperation]){
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
                creatures.findCreatureBy(uniqueID: memberID)?.GetReward(rewardResource)
            }
        }
    }
    
    func CreturesReproduction() -> [Creature]{
        var newBornCreatures:[Creature] = []
        
        creatures.forEach { (creature) in
            if let newBornCreature = creature.selfReproduction(){
                newBornCreatures.append(newBornCreature)
            }
        }

        return newBornCreatures
    }

//    func Work(As Cooperation:WorkCooperation, AverageResource:Double) -> WorkCooperationResult{
//        let RequestWorkAction = Cooperation.RequestWorkAction
//        let RequestResult:WorkResult
//        let ResponseResult:WorkResult?
//
//        if let ResponseWorkAction = Cooperation.ResponseWorkAction {
//            if RequestWorkAction.WorkingAttitude == .helpOther && ResponseWorkAction.WorkingAttitude == .helpOther {
//                RequestResult = .doubleWin
//                ResponseResult = .doubleWin
//            }else if RequestWorkAction.WorkingAttitude == .helpOther && ResponseWorkAction.WorkingAttitude == .selfish {
//                RequestResult = .beenCheated
//                ResponseResult = .exploitation
//            }else if RequestWorkAction.WorkingAttitude == .selfish && ResponseWorkAction.WorkingAttitude == .helpOther {
//                RequestResult = .exploitation
//                ResponseResult = .beenCheated
//            }else if RequestWorkAction.WorkingAttitude == .selfish && ResponseWorkAction.WorkingAttitude == .selfish {
//                RequestResult = .doubleLose
//                ResponseResult = .doubleLose
//            }else {
//                //Work alone
//                RequestResult = .stayAlone
//                ResponseResult = nil
//            }
//        }else{
//            //Work alone
//            RequestResult = .stayAlone
//            ResponseResult = nil
//        }
//
//        return WorkCooperationResult(HarvestResource:AverageResource, RequestResult: RequestResult, ResponseResult: ResponseResult)
//    }
//
//    public static func WorkReword(of workresult: WorkResult, harvestResource: Double) -> Double{
//        var rewardResource:Double
//        switch workresult {
//        case .doubleWin:
//            rewardResource = harvestResource
//        case .exploitation:
//            rewardResource = harvestResource*1.8
//        case .beenCheated:
//            rewardResource = -harvestResource*0.5
//        case .doubleLose:
//            rewardResource = -harvestResource*0
//        case .stayAlone:
//            rewardResource = harvestResource*0.2
//        }
//        rewardResource -= pairWorkBaseCost
//        return rewardResource
//    }
}
