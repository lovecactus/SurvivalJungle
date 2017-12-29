//
//  Methodology.swift
//  Survival
//
//  Created by YANGWEI on 12/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation


let maxLeadingMembers = 20
let teamWorkConservativeReword:RewardResource = 4
let teamWorkIdealReword:RewardResource = 8

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

struct Methodology:Loopable{
    var teamLead:TeamLeadMethodology = TeamLeadMethodology()
    var teamFollow:TeamFollowMethodology = TeamFollowMethodology()
    var reproduction:ReproductionMethodology = ReproductionMethodology()
    var heritage:HeritageMethodology = HeritageMethodology()
    
    func descriptor() ->String {
        let teamLeadDescriptor = descriptorOfTeamLead()
        let teamFollowDescriptor = descriptorOfTeamFollow()
        var totalDescriptor = ""
        if teamLeadDescriptor == "Follower" {
            totalDescriptor = teamFollowDescriptor
        }else if teamLeadDescriptor.hasSuffix("Adapter") {
            totalDescriptor = teamLeadDescriptor+"-"+teamFollowDescriptor
        }else {
            totalDescriptor = teamLeadDescriptor
        }
        totalDescriptor = totalDescriptor + "-" + descriptorOfReproduction()
        totalDescriptor = totalDescriptor + "-" + descriptorOfHeritage()
        return totalDescriptor
    }
    
    func detailDescriptor() ->String {
        return descriptorOfTeamLead()+"-"+descriptorOfTeamFollow()+"-"+descriptorOfReproduction()+"-"+descriptorOfHeritage()
    }
    
    func descriptorOfTeamLead() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: teamLead)) {
        case String(describing: TeamLeadMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamLeadMethodology_LeaderShip.self):
            descriptor = descriptor + "Leader"
            break
        case String(describing: TeamLeadMethodology_OnlyFollow.self):
            descriptor = descriptor + "Follower"
            break
        case String(describing: TeamLeadMethodology_FairLeaderShip.self):
            descriptor = descriptor + "FairLeader"
            break
        case String(describing: TeamLeadMethodology_SelfishLeaderShip.self):
            descriptor = descriptor + "SelfLeader"
            break
        case String(describing: TeamLeadMethodology_SelfishLeader_NoLazy.self):
            descriptor = descriptor + "SelfLeaderNoLazy"
            break
        case String(describing: TeamLeadMethodology_FairLeaderShip_NoLazy.self):
            descriptor = descriptor + "FairLeaderNoLazy"
            break
        case String(describing: TeamLeadMethodology_FairLeaderShip_Adapter.self):
            descriptor = descriptor + "FairAdapter"
            break
        case String(describing: TeamLeadMethodology_BetterSelfishLeaderShip.self):
            descriptor = descriptor + "BetterSelfLeader"
            break
        case String(describing: TeamLeadMethodology_SelfishLeaderShip_Adapter.self):
            descriptor = descriptor + "SelfAdapter"
            break
        case String(describing: TeamLeadMethodology_BetterSelfishLeaderShip_Adapter.self):
            descriptor = descriptor + "BetterSelfAdapter"
            break
        default:
            descriptor = descriptor + ".."
        }
        return descriptor
    }
    
    func descriptorOfTeamFollow() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: teamFollow)) {
        case String(describing: TeamFollowMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamFollowMethodology_Random.self):
            descriptor = descriptor + "FollowRandom"
            break
        case String(describing: TeamFollowMethodology_FairFollower.self):
            descriptor = descriptor + "FollowFair"
            break
        case String(describing: TeamFollowMethodology_FairFollower_Lazy.self):
            descriptor = descriptor + "FollowFairLazy"
            break
        case String(describing: TeamFollowMethodology_SelfishRewardFollower.self):
            descriptor = descriptor + "FollowReward"
            break
        case String(describing: TeamFollowMethodology_ConservativeRewardFollower.self):
            descriptor = descriptor + "FollowConservative"
            break
        case String(describing: TeamFollowMethodology_SelfishRewardFollower_Lazy.self):
            descriptor = descriptor + "FollowRewardLazy"
            break
        case String(describing: TeamFollowMethodology_ConservativeRewardFollower_Lazy.self):
            descriptor = descriptor + "FollowConservativeLazy"
            break
        default:
            descriptor = descriptor + ".."
        }
        return descriptor
    }
    
    func descriptorOfReproduction() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: reproduction)) {
        case String(describing: ReproductionMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: ReproductionMethodology_Normal.self):
            descriptor = descriptor + "ReproNormal"
            break
        case String(describing: ReproductionMethodology_LoveChildren.self):
            descriptor = descriptor + "ReproLoveChild"
            break
        default:
            descriptor = descriptor + ".."
        }
        return descriptor
    }

    func descriptorOfHeritage() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: heritage)) {
        case String(describing: HeritageMethodology.self):
            descriptor = descriptor + "0"
            break
        case String(describing: HeritageMethodology_Normal.self):
            descriptor = descriptor + "HeritageAll"
            break
        case String(describing: HeritageMethodology_OnlyFirstSon.self):
            descriptor = descriptor + "HeritageFirstSon"
            break
        default:
            descriptor = descriptor + ".."
        }
        return descriptor
    }

    static func randomMethodGenerator() -> Methodology {
        return Methodology(teamLead: TeamLeadMethodology.teamLeadRandomMethodGenerator(),
                           teamFollow: TeamFollowMethodology.teamFollowRandomMethodGenerator(),
                           reproduction: ReproductionMethodology.reproductionRandomMethodGenerator(),
                           heritage:HeritageMethodology.heritageRandomMethodGenerator())
    }
}

class TalkMethodology{
}

class ListenMethodology{
}

class CommunityMethodology{
    
}
