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

protocol WorkProtocol {
    func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?
    func respondWorkAction(to AnotherCreature: Creature) -> WorkAction
}

protocol CommunicationProtocol {
    func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude)
    func tell(_ creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude)
    func talk(to creature:Creature, after result:WorkResult)
}

typealias CreatureUniqueID = String

struct Identifer {
    let familyName:String
    let givenName:String
    let bornTime:TimeInterval
    var uniqueID: CreatureUniqueID {
        return familyName+givenName+"-"+String(Int(bornTime))
    }
}

class Creature : ReproductionProtocol, WorkProtocol, CommunicationProtocol{
    public var surviveResource:SurvivalResource = 0
    public let identifier:Identifer
    var age:Int = 0
    let ReproductionAge:Int = 20
    let ReproductionCost:Double = 20
    let CreatureReproductionThreshold:Double = 100
    public var Story:[String] = []
    var Memory = CreatureMemory()
    var Method = Methodology()

    required init(familyName:String, givenName:String) {
        identifier = Identifer(familyName: familyName, givenName: givenName, bornTime: Date.timeIntervalSinceReferenceDate)
    }

    convenience init(familyName:String, givenName:String, age:Int) {
        self.init(familyName: familyName, givenName: givenName)
        self.age = age
    }

    func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        let methodResult = Method.FindCoWorker.findCoWorker(candidate: &Creatures, memory: self.Memory)
        return WorkAction(Worker: self, WorkingPartner: methodResult.WorkingPartner, WorkingAttitude: methodResult.WorkingAttitude)
    }
    
    func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        let methodResult = Method.ResponseCoWorker.responseCoWorker(to: AnotherCreature, memory: self.Memory)
        return WorkAction(Worker: self, WorkingPartner: methodResult.WorkingPartner, WorkingAttitude: methodResult.WorkingAttitude)
    }
    
    func talk(to creature:Creature, after result:WorkResult){
        Method.Talk.talk(to: creature, after: result, memory: self.Memory) { (creature, creatureID, behaviour) in
            self.tell(creature, About: creatureID, WorkBehavior: behaviour)
        }
    }
    
    func tell(_ creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        self.writeStory("Tell "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue)
        creature.listen(from: self, About: anotherCreatureID, WorkBehavior: behavior)
    }

    func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        Method.Listen.listen(from: creature, about: anotherCreatureID, behavior: behavior, memory: self.Memory) { (creature, creatureID, behaviour, story) in
            self.writeStory(story)
        }
    }

//    func requestWorkResult(of Cooperation:WorkCooperation, CooperationResult:WorkCooperationResult){
//        let RequestWorkAction = Cooperation.RequestWorkAction
//        let RequestResult = CooperationResult.RequestResult
//        if let ResponseWorkAction = Cooperation.ResponseWorkAction,
//            let AnotherCreature = RequestWorkAction.WorkingPartner {
//            self.Memory.remember(ResponseWorkAction)
//
//            let WorkReword = SocialBehavior.WorkReword(of:RequestResult, harvestResource: CooperationResult.HarvestResource)
//            surviveResource += WorkReword
//            var story = "Request work with "+AnotherCreature.identifier.uniqueID+","
//            story += " "+RequestWorkAction.WorkingAttitude.rawValue+" VS "+ResponseWorkAction.WorkingAttitude.rawValue
//            story += ", result:"+RequestResult.rawValue
//            story += " reward:"+String(WorkReword)
//            story += " resource:"+String(surviveResource)
//            writeStory(story)
//        }else{
//            let WorkReword = SocialBehavior.WorkReword(of:RequestResult, harvestResource: CooperationResult.HarvestResource)
//            surviveResource += WorkReword
//            var story = "Stay alone"
//            story += " reward:"+String(WorkReword)
//            story += " resource:"+String(surviveResource)
//            writeStory(story)
//        }
//    }
    
//    func responseWorkResult(of Cooperation:WorkCooperation, CooperationResult:WorkCooperationResult){
//        guard let ResponseWorkAction = Cooperation.ResponseWorkAction,
//            let ResponseResult = CooperationResult.ResponseResult,
//            let AnotherCreature = ResponseWorkAction.WorkingPartner else {
//            return
//        }
//        let RequestWorkAction = Cooperation.RequestWorkAction
//
//        self.Memory.remember(RequestWorkAction)
//
//        let WorkReword = SocialBehavior.WorkReword(of:ResponseResult, harvestResource: CooperationResult.HarvestResource)
//        surviveResource += WorkReword
//        var story = "Response work with "+AnotherCreature.identifier.uniqueID+","
//        story += " "+ResponseWorkAction.WorkingAttitude.rawValue+" VS "+RequestWorkAction.WorkingAttitude.rawValue
//        story += ", result:"+ResponseResult.rawValue
//        story += " reward:"+String(WorkReword)
//        story += " resource:"+String(surviveResource)
//        writeStory(story)
//    }

    func writeStory(_ NewStory:String) {
        Story.append("Age:"+String(age)+":"+NewStory)
    }
    
    func aging(){
        age += 1
    }
    
    func selfReproduction() -> Creature?{
        if age >= ReproductionAge , surviveResource >= CreatureReproductionThreshold{
            surviveResource -= ReproductionCost
            writeStory("Born a new herit")
            
            let newBorn = type(of: self).init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
            
            newBorn.Memory = self.Memory.memoryInherit()
            newBorn.writeStory("Inherit memory from parent:"+newBorn.Memory.workActionImpressionMemory.description)
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
        let TeamProposal = Method.TeamUp.TeamPropose(from: self, on: creatures)
        if nil != TeamProposal {
            writeStory("Try leading a team")
        }
        return TeamProposal
    }
    
    func AcceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        return Method.TeamUp.AcceptInvite(from: self, to: teams)
    }
    
    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        writeStory("Assign rewards to members")
        return Method.TeamUp.AssignReward(to: &coopertion)
    }

    func WorkCost(_ workingCost:WorkingCostResource) {
        writeStory("Working cost:"+String(workingCost))
        self.surviveResource -= workingCost
    }

    func GetReward(_ rewardResource:RewardResource) {
        writeStory("Get reward from team:"+String(rewardResource))
        self.surviveResource += rewardResource
    }
}


