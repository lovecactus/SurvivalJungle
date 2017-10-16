//
//  Creature.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
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

struct Identifer {
    let familyName:String
    let givenName:String
    let bornTime:TimeInterval
    var uniqueID: String {
        return familyName+givenName+"-"+String(Int(bornTime))
    }
}

class Creature : ReproductionProtocol, WorkProtocol, CommunicationProtocol{
    public var SurviveResource:Double = 0
    public let identifier:Identifer
    var Age:Int = 0
    let ReproductionAge:Int = 20
    let ReproductionCost:Double = 20
    let CreatureReproductionScore:Double = 50
    let CreatureSurviveScore:Double = -50
    let DieForAge:Int = 100
    public var Story:[String] = []
    var Memory = CreatureMemory()
    var Method = Methodology()

    init(familyName:String, givenName:String) {
        identifier = Identifer(familyName: familyName, givenName: givenName, bornTime: Date.timeIntervalSinceReferenceDate)
    }

    convenience init(familyName:String, givenName:String, age:Int) {
        self.init(familyName: familyName, givenName: givenName)
        Age = age
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

    func requestWorkResult(of Cooperation:WorkCooperation, CooperationResult:WorkCooperationResult){
        let RequestWorkAction = Cooperation.RequestWorkAction
        let RequestResult = CooperationResult.RequestResult
        if let ResponseWorkAction = Cooperation.ResponseWorkAction,
            let AnotherCreature = RequestWorkAction.WorkingPartner {
            self.Memory.remember(AnotherCreature:ResponseWorkAction.Worker, Behavior:ResponseWorkAction.WorkingAttitude)
            
            let WorkReword = SocialBehavior.WorkReword(of:RequestResult, harvestResource: CooperationResult.HarvestResource)
            SurviveResource += WorkReword
            var story = "Request work with "+AnotherCreature.identifier.uniqueID+","
            story += " "+RequestWorkAction.WorkingAttitude.rawValue+" VS "+ResponseWorkAction.WorkingAttitude.rawValue
            story += ", result:"+RequestResult.rawValue
            story += " reward:"+String(WorkReword)
            story += " resource:"+String(SurviveResource)
            writeStory(story)
        }else{
            let WorkReword = SocialBehavior.WorkReword(of:RequestResult, harvestResource: CooperationResult.HarvestResource)
            SurviveResource += WorkReword
            var story = "Stay alone"
            story += " reward:"+String(WorkReword)
            story += " resource:"+String(SurviveResource)
            writeStory(story)
        }
    }
    
    func responseWorkResult(of Cooperation:WorkCooperation, CooperationResult:WorkCooperationResult){
        guard let ResponseWorkAction = Cooperation.ResponseWorkAction,
            let ResponseResult = CooperationResult.ResponseResult,
            let AnotherCreature = ResponseWorkAction.WorkingPartner else {
            return
        }
        let RequestWorkAction = Cooperation.RequestWorkAction

        self.Memory.remember(AnotherCreature:AnotherCreature, Behavior:RequestWorkAction.WorkingAttitude)
        
        SurviveResource += SocialBehavior.WorkReword(of:ResponseResult, harvestResource: CooperationResult.HarvestResource)
        var story = "Response work with "+AnotherCreature.identifier.uniqueID+","
        story += " "+ResponseWorkAction.WorkingAttitude.rawValue+" VS "+RequestWorkAction.WorkingAttitude.rawValue
        story += ", result:"+ResponseResult.rawValue
        story += " resource:"+String(SurviveResource)
        writeStory(story)
    }
    

    func writeStory(_ NewStory:String) {
        Story.append("Age:"+String(Age)+":"+NewStory)
    }
    
    func thinking() {
        Memory.thinking()
    }
    
    func aging(){
        Age += 1
    }
    
    func selfReproduction() -> Creature?{
        print (#function+" is for override")
        return nil
    }
    
    func selfReproduction(ReproductionBlock:()->Creature?) -> Creature?{
        if Age >= ReproductionAge , SurviveResource >= CreatureReproductionScore{
            SurviveResource -= ReproductionCost
            writeStory("Born a new herit")
            if let NewBornCreature = ReproductionBlock() {
                NewBornCreature.Memory = CreatureMemory()
                NewBornCreature.Memory.behaviorMemory = self.Memory.memoryInherit()
                NewBornCreature.writeStory("Inherit memory from parent:"+NewBornCreature.Memory.behaviorMemory.description)
                return NewBornCreature
            }else{
                print (#function+" reproduction error!")
                return nil
            }
        }
        return nil
    }
    
    func surviveChallenge() -> Bool {
        let DieAge = Int(arc4random_uniform(50))+DieForAge;
        if Age >= DieAge {
            writeStory("Die by old")
            return false
        }
        
        if SurviveResource <= CreatureSurviveScore {
            writeStory("Die by starve")
            return false
        }
        return true
    }
    
}

class NiceCreature : Creature {
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Method.FindCoWorker = FindCoWorkerMethodology_OpenNice()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_AlwaysNice()
        Method.Talk = TalkMethodology_TellEveryOne()
        Method.Listen = ListenMethodology_TrustEveryOne()
    }

    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            NiceCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }


}

class ConservativeCreature : Creature{
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Method.FindCoWorker = FindCoWorkerMethodology_ConservativeFriendly()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_AlwaysSelfish()
        Method.Talk = TalkMethodology_OnlyTellFriends()
        Method.Listen = ListenMethodology_OnlyTrustFriends()
    }

    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            ConservativeCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
    
}

class OpenBadCreature : Creature {
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Method.FindCoWorker = FindCoWorkerMethodology_OpenSelfish()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_AlwaysSelfish()
        Method.Talk = TalkMethodology_LieToEveryOne()
        Method.Listen = ListenMethodology_TrustNoOne()
    }

    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            OpenBadCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
}

class ConservativeBadCreature : Creature {
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Method.FindCoWorker = FindCoWorkerMethodology_ConservativeSelfish()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_AlwaysSelfish()
        Method.Talk = TalkMethodology_LieToEveryOne()
        Method.Listen = ListenMethodology_TrustNoOne()
    }

    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            ConservativeBadCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }

}

class StrategyBadCreature : Creature {
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Memory = DisguiseStrategyMemory()
        Method.FindCoWorker = FindCoWorkerMethodology_DisguiseForSomeTime()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_DisguiseForSomeTime()
        Method.Talk = TalkMethodology_LieToEveryOne()
        Method.Listen = ListenMethodology_OnlyTrustFriends()
    }
    
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            StrategyBadCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
    
}

class MeanCreature : Creature{
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Method.FindCoWorker = FindCoWorkerMethodology_ConservativeFriendly()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_TitForTat()
        Method.Talk = TalkMethodology_OnlyTellFriends()
        Method.Listen = ListenMethodology_OnlyTrustFriends()
    }
    
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            MeanCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
}

class SelfishMeanCreature : Creature{
    override init(familyName: String, givenName: String) {
        super.init(familyName: familyName, givenName:givenName)
        Method.FindCoWorker = FindCoWorkerMethodology_ConservativeFriendly()
        Method.ResponseCoWorker = ResponseCoWorkerMethodology_SelfishTitForTat()
        Method.Talk = TalkMethodology_OnlyTellFriends()
        Method.Listen = ListenMethodology_OnlyTrustFriends()
    }

    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            SelfishMeanCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
    
}


class CreatureMemory{
    public var behaviorMemory:[String:WorkAttitude] = [:]

    public func remember (AnotherCreatureID:String, Behavior:WorkAttitude){
        behaviorMemory[AnotherCreatureID] = Behavior
    }

    public func remember (AnotherCreature:Creature, Behavior:WorkAttitude){
        behaviorMemory[AnotherCreature.identifier.uniqueID] = Behavior
    }
    
    public func forget (AnotherCreatureID : String) {
        behaviorMemory.removeValue(forKey: AnotherCreatureID)
    }

    public func thinkOf(AnotherCreatureID : String) -> WorkAttitude {
        guard let memoryForThisCreature = behaviorMemory[AnotherCreatureID] else {
            return WorkAttitude.none
        }
        return memoryForThisCreature
    }

    public func thinkOf(AnotherCreature:Creature) -> WorkAttitude {
        guard let memoryForThisCreature = behaviorMemory[AnotherCreature.identifier.uniqueID] else {
            return WorkAttitude.none
        }
        return memoryForThisCreature
    }

    public func memoryInherit() -> [String:WorkAttitude] {
        var NewMemory:[String:WorkAttitude] = [:]
        let ExpectedRememberMemoryCount = 10
        for (Key,Value) in behaviorMemory {
            if Int(arc4random_uniform(UInt32(behaviorMemory.count))) < ExpectedRememberMemoryCount {
                NewMemory[Key] = Value
            }
        }
        return NewMemory
    }
    
    public func thinkOfOneRandomFriendID() -> String? {
        let niceMemories = behaviorMemory.filter{$1 == .helpOther}.map { key,action in key}
        
        return niceMemories.randomPick()
    }

    public func thinkOfOneRandomEnemyID() -> String? {
        let badMemories = behaviorMemory.filter{$1 == .selfish}.map { key,action in key}
        return badMemories.randomPick()
    }

    public func findOneFriendFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
        while let OldFriendID = self.thinkOfOneRandomFriendID() {
            var OldFriend:Creature? = nil
            if let i = Creatures.index(where: { (Creature) -> Bool in
                return (Creature.identifier.uniqueID == OldFriendID)
            }){
                OldFriend = Creatures[i]
            }
            
            
            if let FindOldFriend = OldFriend {
                return FindOldFriend
            }else{
                self.forget(AnotherCreatureID: OldFriendID)
            }
        }
        return nil
    }
    
    public func findFriendListFromCandidate(candidate Creatures:[Creature]) -> [Creature]{
        return Creatures.filter { (Creature) -> Bool in
            return (WorkAttitude.helpOther == self.thinkOf(AnotherCreature: Creature))
        }
    }
    
    public func findNiceGuyFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
        guard Creatures.count > 0 else {
            return nil
        }
        /*
         return Creatures.filter({ (Creature) -> Bool in
         return (WorkAction.cheat != self.Memory.thinkOf(AnotherCreature: Creature))
         }).randomPick()*/
        
        let randomIndex = Int(arc4random_uniform(UInt32(Creatures.count)))
        var randomeNiceGuy:Creature? = nil
        for index in randomIndex...Creatures.count-1{
            if WorkAttitude.selfish != self.thinkOf(AnotherCreature: Creatures[index]) {
                randomeNiceGuy = Creatures[index]
                break;
            }
        }
        if nil == randomeNiceGuy {
            for index in 0...randomIndex{
                if WorkAttitude.selfish != self.thinkOf(AnotherCreature: Creatures[index]) {
                    randomeNiceGuy = Creatures[index]
                    break;
                }
            }
        }
        return randomeNiceGuy
    }

    public func thinking() {
    }

}

class DisguiseStrategyMemory:CreatureMemory{
    let showSelfCount:Int = 3
    let hideSelfCount:Int = 3
    var disguiseCounter:Int = 0
    var currentStrategyAction  = WorkAttitude.helpOther

    override func thinking() {
        //Think about how to disguise myself
        disguiseCounter += 1
        if disguiseCounter < showSelfCount {
            currentStrategyAction = .helpOther
        }else if disguiseCounter < showSelfCount+hideSelfCount {
            currentStrategyAction = .selfish
        }else {
            disguiseCounter = 0
            currentStrategyAction = .helpOther
        }
        
    }

}

