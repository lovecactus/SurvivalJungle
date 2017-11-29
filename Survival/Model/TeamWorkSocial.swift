//
//  TeamWorkSocial.swift
//  Survival
//
//  Created by YANGWEI on 27/11/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

let teamWorkBaseReword:RewardResource = 20
let teamWorkBaseCost:WorkingCostResource = 10


struct CooperationTeam {
    var TeamLeaderID:CreatureUniqueID
    var OtherMemberIDs:[CreatureUniqueID]
    func isSignle() -> Bool {
        return OtherMemberIDs.count == 0
    }
}

struct CooperationAction {
    var memberActions:[CreatureUniqueID:TeamCooperationEffort]
}

struct CooperationGoal {
    var Succeed:Bool
}

enum TeamCooperationEffort {
    case Corruption
    case Lazy
    case Responsive
    case AllIn
}

struct CooperationReward {
    var totalRewards:RewardResource
    var memberRewards:[CreatureUniqueID:RewardResource]
}

struct TeamWorkCooperation{
    init(Team:CooperationTeam, TeamProposal:CooperationTeam) {
        Goal = CooperationGoal(Succeed: false)
        Action = nil
        Reward = nil
        self.Team = Team
        self.TeamProposal = TeamProposal
    }
    var Goal:CooperationGoal
    var Team:CooperationTeam
    var TeamProposal:CooperationTeam
    var Action:CooperationAction?
    var Reward:CooperationReward?
}

