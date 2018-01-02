//
//  Methodology.swift
//  Survival
//
//  Created by YANGWEI on 12/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation


let maxLeadingMembers = 20
let teamWorkConsistReword:RewardResource = 0
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
        let teamLeadDescriptor = teamLead.descriptor()
        let teamFollowDescriptor = teamFollow.descriptor()
        var totalDescriptor = ""
        if teamLead.teamLeading.descriptor() == "BornLeader" {
            totalDescriptor = teamLeadDescriptor+"-"+teamFollow.teamFollowAttitude.descriptor()
        }else if teamLead.teamLeading.descriptor() == "BornFollower" {
            totalDescriptor = teamLead.teamLeading.descriptor()+"-"+teamFollow.teamFollowAttitude.descriptor()+"-"+teamFollow.teamFollowChoose.descriptor()
        }else {
            totalDescriptor = teamLeadDescriptor+"-"+teamFollowDescriptor
        }

        totalDescriptor = totalDescriptor + "-" + reproduction.descriptor()
        totalDescriptor = totalDescriptor + "-" + heritage.descriptor()
        return totalDescriptor
    }
    
    func detailDescriptor() ->String {
        return teamLead.descriptor()+"-"+teamFollow.descriptor()+"-"+reproduction.descriptor()+"-"+heritage.descriptor()
    }

    static func randomMethodGenerator() -> Methodology {
        return Methodology(teamLead: TeamLeadMethodology.randomMethodGenerator(),
                           teamFollow: TeamFollowMethodology.randomMethodGenerator(),
                           reproduction: ReproductionMethodology.randomMethodGenerator(),
                           heritage:HeritageMethodology.randomMethodGenerator())
    }
}

class TalkMethodology{
}

class ListenMethodology{
}

class CommunityMethodology{
    
}
