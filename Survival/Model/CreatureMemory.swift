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

class CreatureMemory{
    public var shortMemory = ShortMemory()
    public var longTermMemory:[LongTermMemorySlice] = []

    public func description() -> String {
        return ""
    }
    
    public func remember( teamWorkCooperation:TeamWorkCooperation) {
        longTermMemory.append(TeamWorkMemorySlice(teamWorkCooperation))
    }
    
    public func thinkOfMemory(Of leaderID:CreatureUniqueID) -> [TeamWorkCooperation]{
        let memorySlice:[TeamWorkMemorySlice] = self.longTermMemory.flatMap { (memorySlice) -> TeamWorkMemorySlice? in
            return memorySlice as? TeamWorkMemorySlice
        }
        
        let teamMemorySliceOfLeaderID = memorySlice.filter {$0.teamWorkCooperation.Team.TeamLeaderID == leaderID}
        let teamMemoryOfLeaderID = teamMemorySliceOfLeaderID.map {$0.teamWorkCooperation}
        return teamMemoryOfLeaderID
    }

    public func thinkOfTeamWorkMemory() -> [TeamWorkMemorySlice]{
        return self.longTermMemory.flatMap{$0 as? TeamWorkMemorySlice}
    }

    public func thinkOfLastTeamWorkMemory() -> TeamWorkMemorySlice?{
        return self.longTermMemory.reversed().first(where: {$0 is TeamWorkMemorySlice}) as? TeamWorkMemorySlice
    }
    
    public func teachExperience() -> [LongTermMemorySlice] {
        var experienceMemory:[LongTermMemorySlice] = []
        let ExpectedRememberMemoryCount = 10
        for memorySlice in longTermMemory {
            if Int(arc4random_uniform(UInt32(longTermMemory.count))) < ExpectedRememberMemoryCount {
                experienceMemory.append(memorySlice)
            }
        }
        return experienceMemory
    }

    public func learnFromExperience(_ experienceKnowledge:[LongTermMemorySlice]) {
        longTermMemory.append(contentsOf: experienceKnowledge)
    }
    
}

class TeamWorkMemorySlice:LongTermMemorySlice{
    public var teamWorkCooperation:TeamWorkCooperation
    required init(_ teamWorkCooperation:TeamWorkCooperation) {
        self.teamWorkCooperation = teamWorkCooperation
    }
}
