//
//  TeamWorkSocial.swift
//  Survival
//
//  Created by YANGWEI on 27/11/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

typealias EffortValue = Double
let YoungEffortBase:EffortValue = 5
let MaturedEffortBase:EffortValue = 10
let OldEffortBase:EffortValue = 5
let DyingEffortBase:EffortValue = 1


let teamStartUpCost:RewardResource = 0
let teamBounsReward:RewardResource = teamStartUpCost*2
let teamWorkBaseReword:RewardResource = 2
let teamWorkBaseCost:WorkingCostResource = 5

let wasteTimeResource:SurvivalResource = 1


struct CooperationTeam {
    var TeamLeaderID:CreatureUniqueID
    var OtherMemberIDs:[CreatureUniqueID]
    func isSignle() -> Bool {
        return OtherMemberIDs.count == 0
    }
}

struct CooperationAction {
    var memberActions:[CreatureUniqueID:TeamCooperationEffort]
    var workingCosts:[CreatureUniqueID:WorkingCostResource]

    func TotalEffort() -> EffortValue{
        let teamWorkingValue = self.memberActions.enumerated().reduce(0, { (result, action) -> EffortValue in
            let attitudeRate:TeamCooperationAttitudeRate
            switch action.element.value.Attitude {
            case .AllIn:
                attitudeRate = .AllInRate
                break
            case .Responsive:
                attitudeRate = .ResponsiveRate
                break
            case .Lazy:
                attitudeRate = .LazyRate
                break
            }
            let workingValue = action.element.value.Value*attitudeRate.rawValue
            return result+workingValue
        })
        return teamWorkingValue
    }
    
    func WorkMemberCount() -> Int{
        return self.memberActions.count
//        let workMemberCount = self.memberActions.enumerated().reduce(0, { (result, action) -> Int in
//            switch action.element.value.Attitude {
//            case .AllIn:
//                return result + 1
//            case .Responsive:
//                return result + 1
//            case .Lazy:
//                return result
//            }
//        })
//        return workMemberCount
    }
}

struct CooperationGoal {
    var Succeed:Bool
}

struct TeamCooperationEffort{
    var Attitude:TeamCooperationAttitude
    var Age:Int
    var Value:EffortValue
}

enum TeamCooperationAttitude {
    case Lazy
    case Responsive
    case AllIn
}

enum TeamCooperationAttitudeRate : Double{
    case LazyRate = 0.2
    case ResponsiveRate = 0.5
    case AllInRate = 1
}

struct CooperationReward {
    var TotalRewards:RewardResource
    var MemberRewards:[CreatureUniqueID:RewardResource]
}

struct TeamWorkCooperation{
    init(Team:CooperationTeam, TeamProposal:CooperationTeam) {
        Goal = CooperationGoal(Succeed: false)
        Action = CooperationAction(memberActions: [:], workingCosts: [:])
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
