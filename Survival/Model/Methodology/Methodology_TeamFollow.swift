//
//  Methodology_TeamFollow.swift
//  Survival
//
//  Created by YANGWEI on 22/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation


class TeamFollowMethodology {
    public static func teamFollowRandomMethodGenerator() -> TeamFollowMethodology {
        let method:TeamFollowMethodology
        switch Int(arc4random_uniform(3)) {
        case 0:
            method = TeamFollowMethodology_Random()
            break
        case 1:
            method = TeamFollowMethodology_SelfishRewardFollower()
            break
        case 2:
            method = TeamFollowMethodology_ConservativeRewardFollower()
            break
//        case 3:
//            method = TeamFollowMethodology_FairFollower()
//            break
//        case 4:
//            method = TeamFollowMethodology_ConservativeRewardFollower_Lazy()
//            break
//        case 5:
//            method = TeamFollowMethodology_SelfishRewardFollower_Lazy()
//            break
//        case 6:
//            method = TeamFollowMethodology_FairFollower_Lazy()
//            break
        default:
            method = TeamFollowMethodology()
        }
        return method
    }

    
    func AcceptInvite(from creature:Creature, to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if creature.memory.shortMemory.isAssamblingTeam {
            return nil
        }
        
        return teams.randomPick()
    }
    
    func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .AllIn
    }
    
}

class TeamFollowMethodology_Random:TeamFollowMethodology{
}

class TeamFollowMethodologyLazy:TeamFollowMethodology{
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .Lazy
    }
    
}

class TeamFollowMethodology_ConservativeRewardFollower:TeamFollowMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.AcceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID, teamWorkConservativeReword)
            }
            let rewards = memorySlices.map{$0.Reward?.MemberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .AllIn
    }
}

class TeamFollowMethodology_SelfishRewardFollower:TeamFollowMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.AcceptInvite(from: creature, to: teams) {
            return nil
        }
        let leaderIDs = teams.map { $0.Team.TeamLeaderID}.shuffled()
        let scores = leaderIDs.map { (leaderID) -> (String,Double) in
            let memorySlices = creature.memory.thinkOfMemory(Of: leaderID)
            guard memorySlices.count > 0 else {
                return (leaderID,teamWorkIdealReword)
            }
            let rewards = memorySlices.map{$0.Reward?.MemberRewards[creature.identifier.uniqueID] ?? Double(0)}
            let averageRewards = (rewards.reduce(0, +))/Double(rewards.count)
            return (leaderID,averageRewards)
            }.sorted  { $0.1 > $1.1 }
        if let bestLeaderID = scores.first?.0,
            let bestTeam = teams.first(where: { $0.Team.TeamLeaderID == bestLeaderID}) {
            return bestTeam
        }
        return teams.randomPick()
    }
    
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .AllIn
    }
    
}

class TeamFollowMethodology_FairFollower:TeamFollowMethodology{
    override func AcceptInvite(from creature:Creature,
                               to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        if nil == super.AcceptInvite(from: creature, to: teams) {
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
                    let otherReward = reward.MemberRewards[randomOtherMemberID],
                    let leaderReward = reward.MemberRewards[leaderID] else {
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
    
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .AllIn
    }
    
}

class TeamFollowMethodology_ConservativeRewardFollower_Lazy:TeamFollowMethodology_ConservativeRewardFollower{
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .Lazy
    }
}

class TeamFollowMethodology_SelfishRewardFollower_Lazy:TeamFollowMethodology_SelfishRewardFollower{
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .Lazy
    }
}

class TeamFollowMethodology_FairFollower_Lazy:TeamFollowMethodology_FairFollower{
    override func WorkingAttitude(from creature:Creature, to team:TeamWorkCooperation) -> TeamCooperationAttitude{
        return .Lazy
    }
}
