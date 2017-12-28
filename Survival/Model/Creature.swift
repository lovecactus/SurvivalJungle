//
//  Creature.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

protocol ReproductionProtocol {
    func SelfReproduction() -> Creature?
}

protocol WorkProtocol {
    func TeamPropose(from creatures:[Creature]) -> TeamWorkCooperation?
    func AcceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?
    func WorkValue() -> EffortValue
}

protocol CommunicationProtocol {
    func FindSomeOneToTalk() -> CreatureUniqueID
    func Talk(to creature:Creature, story:LongTermMemorySlice)
    func Listen(to creature:Creature, about story:LongTermMemorySlice)
}

typealias CreatureUniqueID = String

struct Identifer {
    let familyName:String
    let givenName:String
    let bornID:Int
    var uniqueID: CreatureUniqueID {
        return familyName+givenName+"-"+String(bornID)
    }
}

class Creature : ReproductionProtocol, CommunicationProtocol{
    public var surviveResource:SurvivalResource = 0
    public let identifier:Identifer
    var age:Int = 0
    public var Story:[String] = []
    var memory = CreatureMemory()
    var method = Methodology()

    static var idCounter = Int(0)
    
    required init(familyName:String, givenName:String) {
        Creature.idCounter += 1
        identifier = Identifer(familyName: familyName, givenName: givenName, bornID: Creature.idCounter)
        surviveResource = newBornResource
    }

    convenience init(familyName:String, givenName:String, age:Int) {
        self.init(familyName: familyName, givenName: givenName)
        self.age = age
    }

    func writeStory(_ NewStory:String) {
        Story.append("Age:"+String(age)+"-Resource:"+String(surviveResource)+":"+NewStory)
    }
    
    func aging(){
        age += 1
        memory.growMature(at: age)
    }
    
    func SelfReproduction() -> Creature?{
        let readyToReproduction = self.method.Reproduction.ReadyToReproduction(of: self)
        if readyToReproduction {
            surviveResource -= reproductionCost
            let newBorn = self.method.Reproduction.Reproduction(of: self)
            writeStory("Born a new herit")
            
            newBorn.writeStory("Born from parent:"+self.identifier.uniqueID)
            return newBorn
        }
        return nil
    }
    
    func surviveChallenge() -> Bool {
        if OldChallenge().surviveChallenge(age) {
            writeStory("Die by old")
            return false
        }

        if StarveChallenge().surviveChallenge(surviveResource){
            writeStory("Die by starve")
            return false
        }
        return true
    }
    
    func TeamPropose(from creatures:[Creature]) -> TeamWorkCooperation? {
        let TeamProposal = method.TeamLead.TeamPropose(from: self, on: creatures)
        if nil != TeamProposal {
            writeStory("Try leading a team, with cost:"+String(teamStartUpCost))
            surviveResource -= teamStartUpCost
        }
        return TeamProposal
    }
    
    func AcceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        guard let team = method.TeamFollow.AcceptInvite(from: self, to: teams) else {
            writeStory("Failed to accept all invitations... How did this happen?")
            return nil
        }
        writeStory("Accept invite from leader:"+team.Team.TeamLeaderID)
        return team
    }

    func WorkValue() -> EffortValue {
        let value:EffortValue
        switch age {
        case 0...MatureAge:
            value = YoungEffortBase
        case MatureAge+1...OldAge:
            value = MaturedEffortBase
        case OldAge+1...DieForAge:
            value = OldEffortBase
        case DieForAge+1...Int.max:
            value = DyingEffortBase
        default:
            value = 0
        }
        return value
    }
    
    func WorkEffort(to team:TeamWorkCooperation) -> TeamCooperationEffort{
        let attitude = method.TeamFollow.WorkingAttitude(from: self, to: team)
        return TeamCooperationEffort(Attitude: attitude, Age: age, Value: self.WorkValue())
    }

    func WasteTime(){
        surviveResource -= wasteTimeResource
        writeStory("Nothing to do, waste time wandering, cost:"+String(wasteTimeResource))
    }

    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        writeStory("Assign rewards to members")
        return method.TeamLead.AssignReward(to: &coopertion)
    }

    func WorkCost(_ effort:TeamCooperationEffort) -> WorkingCostResource{
        let workingCost:SurvivalResource
        switch effort.Attitude {
        case .AllIn:
            workingCost = 5
            break
        case .Responsive:
            workingCost = 3
            break
        case .Lazy:
            workingCost = 1
            break
        }
        writeStory("Working cost:"+String(workingCost)+" with attitude:"+String(describing: effort.Attitude)+" & value:"+String(describing: effort.Value))
        self.surviveResource -= workingCost
    }

    func GetReward(_ rewardResource:RewardResource, as cooperation:TeamWorkCooperation) {
        writeStory("Get reward from team:"+String(rewardResource)+", leader:"+cooperation.Team.TeamLeaderID)
        self.surviveResource += rewardResource
        self.memory.remember(teamWorkCooperation: cooperation)
    }
    
    func FindSomeOneToTalk() -> CreatureUniqueID {
        let creatureID = ""
//        self.method.Talk
        return creatureID
    }
    
    func Talk(to creature: Creature, story: LongTermMemorySlice) {
//        memory.remember(teamWorkCooperation: <#T##TeamWorkCooperation#>)
    }
    
    func Listen(to creature: Creature, about story: LongTermMemorySlice) {
//        <#code#>
    }
}

