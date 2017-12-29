//
//  CreatureMemory.swift
//  Survival
//
//  Created by YANGWEI on 17/10/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

class ShortMemory {
    public var isAssamblingTeam:Bool = false
}

class LongTermMemorySlice {
}

class LongMemory {
    public var teamWorkCooperation:[TeamWorkMemorySlice] = []
    public var creatureImpression:[CreatureImpressionSlice] = []
    public var creatureRelationShip:[RelationShipSlice] = []
    public var reproductionDesire:Double = 0
}

class CreatureMemory{
    public var shortMemory = ShortMemory()
    public var longTermMemory = LongMemory()

    public func description() -> String {
        return ""
    }
    
    public func remember( teamWorkCooperation:TeamWorkCooperation?) {
        longTermMemory.teamWorkCooperation.append(TeamWorkMemorySlice(teamWorkCooperation))
    }

    public func remember( creatureID:CreatureUniqueID, effort:TeamCooperationEffort) {
        longTermMemory.creatureImpression.append(CreatureImpressionSlice(creatureID, cooperationEffort: effort))
    }

    public func remember( creatureID:CreatureUniqueID, relation:CreatureRelationShip) {
        longTermMemory.creatureRelationShip.append(RelationShipSlice(creatureID, relationShip: relation))
    }

    public func thinkOfMemory(Of leaderID:CreatureUniqueID) -> [TeamWorkCooperation]{
        let teamMemorySlice = self.longTermMemory.teamWorkCooperation.flatMap { (memorySlice) -> TeamWorkCooperation? in
            return memorySlice.teamWorkCooperation
        }
        let teamMemorySliceOfLeaderID = teamMemorySlice.filter {$0.Team.TeamLeaderID == leaderID}
        return teamMemorySliceOfLeaderID
    }

    public func thinkOfTeamWorkMemory() -> [TeamWorkMemorySlice]{
        return self.longTermMemory.teamWorkCooperation
    }

    public func thinkOfLastTeamWorkMemory() -> TeamWorkMemorySlice?{
        return self.longTermMemory.teamWorkCooperation.reversed().first
    }
    
    public func thinkOfSons() -> [CreatureUniqueID]{
        return self.longTermMemory.creatureRelationShip.filter({$0.relationShip == .child}).map({$0.creatureID})
    }
    
    public func growMature(at age:Int) {
        let reproductionDesire:Double
        switch age {
        case 0...MatureAge:
            reproductionDesire = 0
        case MatureAge+1...OldAge:
            reproductionDesire = 2
        case OldAge+1...DieForAge:
            reproductionDesire = 0
        case DieForAge+1...Int.max:
            reproductionDesire = -1
        default:
            reproductionDesire = -1
        }

        self.longTermMemory.reproductionDesire += reproductionDesire
    }

    public func releaseReproductionDesire() {
        self.longTermMemory.reproductionDesire -= reproductionDesireThreshold
    }
    
    public func reproductionDesire() -> Double {
        return self.longTermMemory.reproductionDesire
    }
    
    
//    public func teachExperience() -> [LongTermMemorySlice] {
//        var experienceMemory:[LongTermMemorySlice] = []
//        let ExpectedRememberMemoryCount = 10
//        for memorySlice in longTermMemory.teamWorkCooperation {
//            if Int(arc4random_uniform(UInt32(longTermMemory.count))) < ExpectedRememberMemoryCount {
//                experienceMemory.append(memorySlice)
//            }
//        }
//        return experienceMemory
//    }

//    public func learnFromExperience(_ experienceKnowledge:[LongTermMemorySlice]) {
//        longTermMemory.teamWorkCooperation.append(contentsOf: experienceKnowledge)
//    }
    
}

class TeamWorkMemorySlice:LongTermMemorySlice{
    public var teamWorkCooperation:TeamWorkCooperation?
    required init(_ teamWorkCooperation:TeamWorkCooperation?) {
        self.teamWorkCooperation = teamWorkCooperation
    }
}

class CreatureImpressionSlice:LongTermMemorySlice{
    public var creatureID:CreatureUniqueID
    public var cooperationEffort:TeamCooperationEffort
    required init(_ creatureID:CreatureUniqueID, cooperationEffort:TeamCooperationEffort) {
        self.creatureID = creatureID
        self.cooperationEffort = cooperationEffort
    }
}

enum CreatureRelationShip:Int{
    case parent
    case child
}

class RelationShipSlice:LongTermMemorySlice{
    public var creatureID:CreatureUniqueID
    public var relationShip:CreatureRelationShip
    required init(_ creatureID:CreatureUniqueID, relationShip:CreatureRelationShip) {
        self.creatureID = creatureID
        self.relationShip = relationShip
    }
}
