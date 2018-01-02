//
//  Creature.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

protocol ReproductionProtocol {
    func selfReproduction() -> Creature
    func findAnIdealLover(in creatures:inout [Creature]) -> Creature?
    func pickAnIdealLover(from creatures: [Creature]) -> Creature?
}

protocol ResourceTransferProtocol {
    func giveResource(resource:SurvivalResource) -> SurvivalResource
    func receiveResource(resource:SurvivalResource)
}

protocol WorkProtocol {
    func teamPropose(from creatures:inout CreatureGroup) -> TeamWorkCooperation?
    func acceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?
    func workValue() -> EffortValue
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

class Creature : ReproductionProtocol, CommunicationProtocol, ResourceTransferProtocol, WorkProtocol{
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
    
    func die(by reason:String, with creatures:inout CreatureGroup){
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
    
    func findAnIdealLover(in creatures:inout [Creature]) -> Creature?{
        return creatures.randomPick()
    }
    
    func pickAnIdealLover(from creatures: [Creature]) -> Creature?{
        return creatures.randomPick()
    }
    
    func selfReproduction() -> Creature{
        let newBorn = self.method.reproduction.selfReproduction(of: self)
        self.memory.remember(creatureID: newBorn.identifier.uniqueID, relation: .child)
        writeStory("Born a new herit")
        
        newBorn.writeStory("Born from parent:"+self.identifier.uniqueID)
        newBorn.memory.remember(creatureID: self.identifier.uniqueID, relation: .parent)
        return newBorn
    }
    
    func matingReproduction(with maleCreature:Creature) -> Creature {
        let newBorn = self.method.reproduction.matingReproduction(of: self, with: maleCreature)
        self.memory.remember(creatureID: newBorn.identifier.uniqueID, relation: .child)
        writeStory("Born a new herit with "+maleCreature.identifier.uniqueID)

        maleCreature.memory.remember(creatureID: newBorn.identifier.uniqueID, relation: .child)
        maleCreature.writeStory("Born a new herit with "+self.identifier.uniqueID)
        
        newBorn.writeStory("Born from parents:"+self.identifier.uniqueID+" & "+maleCreature.identifier.uniqueID)
        newBorn.memory.remember(creatureID: self.identifier.uniqueID, relation: .parent)
        newBorn.memory.remember(creatureID: maleCreature.identifier.uniqueID, relation: .parent)
        return newBorn
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
    
    func teamPropose(from creatures:inout CreatureGroup) -> TeamWorkCooperation? {
        if false == method.teamLead.teamLeading.wantToBeLeader(as: self) {
            writeStory("Don't want to lead a team")
            return nil
        }
        
        let TeamProposal = method.teamLead.teamUp.teamPropose(from: self, on: &creatures)
        if nil != TeamProposal {
            surviveResource -= teamStartUpCost
        }
        writeStory("Try leading a team, with cost:"+String(teamStartUpCost))
        return TeamProposal
    }
    
    func assignReward(to coopertion:inout TeamWorkCooperation) {
        writeStory("Assign rewards to members")
        method.teamLead.teamExploitation.assignRewardSelfFirst(to: &coopertion)
        return method.teamLead.teamAssign.assignReward(to: &coopertion)
    }

    func acceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        guard let team = method.teamFollow.teamFollowChoose.acceptInvite(from: self, to: teams) else {
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
        let attitude = method.teamFollow.teamFollowAttitude.workingAttitude(from: self, to: team)
        return TeamCooperationEffort(attitude: attitude, age: age, value: self.workValue())
    }

    func wasteTime(){
        surviveResource -= wasteTimeResource
        writeStory("Nothing to do, waste time wandering, cost:"+String(wasteTimeResource))
    }

    func workCost(_ effort:TeamCooperationEffort) -> WorkingCostResource{
        let workingCost:SurvivalResource
        switch effort.attitude {
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
        writeStory("Working cost:"+String(workingCost)+" with attitude:"+String(describing: effort.attitude)+" & value:"+String(describing: effort.value))
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

