//
//  TeamWorkSocial.swift
//  Survival
//
//  Created by YANGWEI on 27/11/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

typealias WorkingEffort = Double


let teamStartUpCost:RewardResource = 5
let teamBounsReward:RewardResource = teamStartUpCost*2
let teamWorkBaseReword:RewardResource = 5
let teamWorkBaseCost:WorkingCostResource = 5

let wasteTimeResource:SurvivalResource = teamWorkBaseReword

struct CooperationTeam {
    var TeamLeaderID:CreatureUniqueID
    var OtherMemberIDs:[CreatureUniqueID]
    func isSignle() -> Bool {
        return OtherMemberIDs.count == 0
    }
}

struct CooperationAction {
    var MemberActions:[CreatureUniqueID:TeamCooperationEffort]
    
    func TotalEffort() -> WorkingEffort{
        let teamWorkingEffort = self.MemberActions.enumerated().reduce(0, { (result, action) -> WorkingEffort in
            let workingEffort:WorkingEffort
            switch action.element.value {
            case .AllIn:
                workingEffort = 5
                break
            case .Responsive:
                workingEffort = 3
                break
            case .Lazy:
                workingEffort = 1
                break
            }
            return result+workingEffort
        })
        return teamWorkingEffort
    }
    
    func WorkMemberCount() -> Int{
        let workMemberCount = self.MemberActions.enumerated().reduce(0, { (result, action) -> Int in
            switch action.element.value {
            case .AllIn:
                return result + 1
            case .Responsive:
                return result + 1
            case .Lazy:
                return result
            }
        })
        return workMemberCount
    }
}

struct CooperationGoal {
    var Succeed:Bool
}

enum TeamCooperationEffort {
    case Lazy
    case Responsive
    case AllIn
}

struct CooperationReward {
    var TotalRewards:RewardResource
    var MemberRewards:[CreatureUniqueID:RewardResource]
}

struct TeamWorkCooperation{
    init(Team:CooperationTeam, TeamProposal:CooperationTeam) {
        Goal = CooperationGoal(Succeed: false)
        Action = CooperationAction(MemberActions: [:])
        Reward = nil
        self.Team = Team
        self.TeamProposal = TeamProposal
    }
    var Goal:CooperationGoal
    var Team:CooperationTeam
    var TeamProposal:CooperationTeam
    var Action:CooperationAction
    var Reward:CooperationReward?
}

struct FailedTeamUp{
    var SingleCreatures:[CreatureUniqueID]
}
