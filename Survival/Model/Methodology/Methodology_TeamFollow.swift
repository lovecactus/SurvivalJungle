//
//  Methodology_TeamFollow.swift
//  Survival
//
//  Created by YANGWEI on 22/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation


class TeamFollowMethodology {
    var teamFollowChoose:TeamFollowChooseMethodology = TeamFollowChooseMethodology()
    var teamFollowAttitude:TeamFollowAttitudeMethodology = TeamFollowAttitudeMethodology()

    public static func randomMethodGenerator() -> TeamFollowMethodology {
        let newRandomMethod = TeamFollowMethodology()
        newRandomMethod.teamFollowChoose = TeamFollowChooseMethodology.randomMethodGenerator()
        newRandomMethod.teamFollowAttitude = TeamFollowAttitudeMethodology.randomMethodGenerator()
        
        return newRandomMethod
    }

    public func descriptor() -> String {
        let descriptor:String = "Follow"+teamFollowChoose.descriptor()+"-"+teamFollowAttitude.descriptor()
        return descriptor
    }
    
}

class TeamFollowChooseMethodology {
    public static func randomMethodGenerator() -> TeamFollowChooseMethodology {
        let method:TeamFollowChooseMethodology
        switch Int(arc4random_uniform(5)) {
        case 0:
            method = TeamFollowChooseMethodology_Random()
            break
        case 1:
            method = TeamFollowChooseMethodology_Consist()
            break
        case 2:
            method = TeamFollowChooseMethodology_LowReward()
            break
        case 3:
            method = TeamFollowChooseMethodology_HighReward()
            break
        case 4:
            method = TeamFollowChooseMethodology_Fair()
            break
        default:
            method = TeamFollowChooseMethodology()
        }
        return method
    }
    
    func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: TeamFollowChooseMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamFollowChooseMethodology_Random.self):
            descriptor = descriptor + "Random"
            break
        case String(describing: TeamFollowChooseMethodology_Consist.self):
            descriptor = descriptor + "Consist"
            break
        case String(describing: TeamFollowChooseMethodology_LowReward.self):
            descriptor = descriptor + "LowReward"
            break
        case String(describing: TeamFollowChooseMethodology_HighReward.self):
            descriptor = descriptor + "HighReward"
            break
        case String(describing: TeamFollowChooseMethodology_Fair.self):
            descriptor = descriptor + "Fair"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }
    
    func acceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if creature.memory.shortMemory.isAssamblingTeam {
            return nil
        }
        
        return teams.randomPick()
    }

}

class TeamFollowChooseMethodology_Random:TeamFollowChooseMethodology{
    override func acceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if creature.memory.shortMemory.isAssamblingTeam {
            return nil
        }
        
        return teams.randomPick()
    }
}

class TeamFollowChooseMethodology_Consist:TeamFollowChooseMethodology{
    override func acceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.acceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID, teamWorkConsistReword)
            }
            let rewards = memorySlices.map{$0.Reward?.memberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
}


class TeamFollowChooseMethodology_LowReward:TeamFollowChooseMethodology{
    override func acceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.acceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID, teamWorkConservativeReword)
            }
            let rewards = memorySlices.map{$0.Reward?.memberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
}

class TeamFollowChooseMethodology_HighReward:TeamFollowChooseMethodology{
    override func acceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.acceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID,teamWorkIdealReword)
            }
            let rewards = memorySlices.map{$0.Reward?.memberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
}

class TeamFollowChooseMethodology_Fair:TeamFollowChooseMethodology{
    override func acceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.acceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Int) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID,0)
            }
            
            let fair = memorySlices.map({ (cooperation) -> Int in
                guard let randomOtherMemberID = cooperation.Team.OtherMemberIDs.randomPick(),
                    let reward = cooperation.Reward,
                    let otherReward = reward.memberRewards[randomOtherMemberID],
                    let leaderReward = reward.memberRewards[leaderID] else {
                        return 0
                }
                
                if 0 == otherReward && 0 == leaderReward {
                    return 0
                }
                if otherReward >= leaderReward {
                    return 1
                }
                return -1
            })
            
            let score = fair.reduce(0, { (result, fair) -> Int in
                return result + fair
            })
            return (leaderID,score)
            }.sorted  { $0.1 > $1.1 }
        
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
}

class TeamFollowAttitudeMethodology {
    public static func randomMethodGenerator() -> TeamFollowAttitudeMethodology {
        let method:TeamFollowAttitudeMethodology
        switch Int(arc4random_uniform(3)) {
        case 0:
            method = TeamFollowAttitudeMethodology_AllIn()
            break
        case 1:
            method = TeamFollowAttitudeMethodology_Responsive()
            break
        case 2:
            method = TeamFollowAttitudeMethodology_Lazy()
            break
        default:
            method = TeamFollowAttitudeMethodology()
        }
        return method
    }
    
    func descriptor() -> String {
        var descriptor:String = ""
        switch String(describing: type(of: self)) {
        case String(describing: TeamFollowAttitudeMethodology.self):
            descriptor = descriptor + ""
            break
        case String(describing: TeamFollowAttitudeMethodology_AllIn.self):
            descriptor = descriptor + "AllIn"
            break
        case String(describing: TeamFollowAttitudeMethodology_Responsive.self):
            descriptor = descriptor + "Responsive"
            break
        case String(describing: TeamFollowAttitudeMethodology_Lazy.self):
            descriptor = descriptor + "BeLazy"
            break
        default:
            descriptor = descriptor + "UnknownDescriptor"
        }
        return descriptor
    }

    func workingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .AllIn
    }
    
}

class TeamFollowAttitudeMethodology_AllIn:TeamFollowAttitudeMethodology{
    override func workingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .AllIn
    }
}

class TeamFollowAttitudeMethodology_Responsive:TeamFollowAttitudeMethodology{
    override func workingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .Responsive
    }
}

class TeamFollowAttitudeMethodology_Lazy:TeamFollowAttitudeMethodology{
    override func workingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .Lazy
    }
}
