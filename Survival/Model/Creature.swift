//
//  Creature.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

protocol ReproductionProtocol {
    func selfReproduction() -> Creature?
}

protocol ResourceTransferProtocol {
    func giveResource(resource:SurvivalResource) -> SurvivalResource
    func receiveResource(resource:SurvivalResource)
}

protocol WorkProtocol {
    func TeamPropose(from creatures:inout [Creature]) -> TeamWorkCooperation?
    func AcceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?
    func WorkValue() -> EffortValue
}

protocol CommunicationProtocol {
    func findSomeOneToTalk() -> CreatureUniqueID
    func talk(to creature:Creature, story:LongTermMemorySlice)
    func listen(to creature:Creature, about story:LongTermMemorySlice)
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

class Creature : ReproductionProtocol, CommunicationProtocol, ResourceTransferProtocol{
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
    
    func die(by reason:String, with creatures:inout [Creature]){
        self.method.heritage.heritage(of: self, to: &creatures)
        writeStory("Die by "+reason)
    }
    
    func giveResource(resource: SurvivalResource) -> SurvivalResource{
        let giveOutResource = (surviveResource > resource) ? resource : surviveResource
        surviveResource -= giveOutResource
        return giveOutResource
    }
    
    func receiveResource(resource: SurvivalResource) {
        surviveResource += resource
    }
    
    func selfReproduction() -> Creature?{
        let readyToReproduction = self.method.reproduction.readyToReproduction(of: self)
        if readyToReproduction {
            surviveResource -= reproductionCost
            let newBorn = self.method.reproduction.reproduction(of: self)
            self.memory.remember(creatureID: newBorn.identifier.uniqueID, relation: .child)
            writeStory("Born a new herit")
            
            newBorn.writeStory("Born from parent:"+self.identifier.uniqueID)
            newBorn.memory.remember(creatureID: self.identifier.uniqueID, relation: .parent)
            return newBorn
        }
        return nil
    }
    
    func surviveChallenge() -> (Bool,String) {
        if OldChallenge().surviveChallenge(age) {
            return (false, "old")
        }

        if StarveChallenge().surviveChallenge(surviveResource){
            return (false, "starve")
        }
        return (true, "")
    }
    
    func teamPropose(from creatures:inout [Creature]) -> TeamWorkCooperation? {
        let TeamProposal = method.teamLead.teamPropose(from: self, on: &creatures)
        if nil != TeamProposal {
            writeStory("Try leading a team, with cost:"+String(teamStartUpCost))
            surviveResource -= teamStartUpCost
        }
        return TeamProposal
    }
    
    func acceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        guard let team = method.teamFollow.AcceptInvite(from: self, to: teams) else {
            writeStory("Failed to accept all invitations... How did this happen?")
            return nil
        }
        writeStory("Accept invite from leader:"+team.Team.TeamLeaderID)
        return team
    }

    func workValue() -> EffortValue {
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
    
    func workEffort(to team:TeamWorkCooperation) -> TeamCooperationEffort{
        let attitude = method.teamFollow.WorkingAttitude(from: self, to: team)
        return TeamCooperationEffort(Attitude: attitude, Age: age, Value: self.workValue())
    }

    func wasteTime(){
        surviveResource -= wasteTimeResource
        writeStory("Nothing to do, waste time wandering, cost:"+String(wasteTimeResource))
    }

    func assignReward(to coopertion:inout TeamWorkCooperation) {
        writeStory("Assign rewards to members")
        return method.teamLead.AssignReward(to: &coopertion)
    }

    func workCost(_ effort:TeamCooperationEffort) -> WorkingCostResource{
        let workingCost:SurvivalResource
        switch effort.Attitude {
        case .AllIn:
            workingCost = 3
            break
        case .Responsive:
            workingCost = 2
            break
        case .Lazy:
            workingCost = 1
            break
        }
        writeStory("Working cost:"+String(workingCost)+" with attitude:"+String(describing: effort.Attitude)+" & value:"+String(describing: effort.Value))
        self.surviveResource -= workingCost
        return workingCost
    }

    func getReward(_ rewardResource:RewardResource, as cooperation:TeamWorkCooperation) {
        writeStory("Get reward from team:"+String(rewardResource)+", leader:"+cooperation.Team.TeamLeaderID)
        self.surviveResource += rewardResource
        self.memory.remember(teamWorkCooperation: cooperation)
    }
    
    func findSomeOneToTalk() -> CreatureUniqueID {
        let creatureID = ""
//        self.method.Talk
        return creatureID
    }
    
    func talk(to creature: Creature, story: LongTermMemorySlice) {
//        memory.remember(teamWorkCooperation: <#T##TeamWorkCooperation#>)
    }
    
    func listen(to creature: Creature, about story: LongTermMemorySlice) {
//        <#code#>
    }
}

