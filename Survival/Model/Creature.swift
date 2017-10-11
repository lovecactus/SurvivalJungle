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
    var Memory:CreatureMemory = CreatureMemory()
    var Age:Int = 0
    let ReproductionAge:Int = 20
    let ReproductionCost:Double = 20
    let CreatureReproductionScore:Double = 50
    let CreatureSurviveScore:Double = -50
    let DieForAge:Int = 100
    public var Story:[String] = []

    init(familyName:String, givenName:String) {
        identifier = Identifer(familyName: familyName, givenName: givenName, bornTime: Date.timeIntervalSinceReferenceDate)
    }

    init(familyName:String, givenName:String, age:Int) {
        identifier = Identifer(familyName: familyName, givenName: givenName, bornTime: Date.timeIntervalSinceReferenceDate)
        Age = age
    }

    func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
//        print (#function+" is for override")
        guard let Coworker = Creatures.randomPick() else { return nil }
        return WorkAction(Worker:self, WorkingPartner:Coworker, WorkingAttitude: .selfish)
    }
    
    func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: .selfish)
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
        //I'm too stupid to think about myself!
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
    
    func findOneFriendFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
        while let OldFriendID = self.Memory.thinkOfOneRandomFriendID() {
            var OldFriend:Creature? = nil
            if let i = Creatures.index(where: { (Creature) -> Bool in
                return (Creature.identifier.uniqueID == OldFriendID)
            }){
                OldFriend = Creatures[i]
            }

            
            if let FindOldFriend = OldFriend {
                return FindOldFriend
            }else{
                self.Memory.forget(AnotherCreatureID: OldFriendID)
            }
        }
        return nil
    }

    func findFriendListFromCandidate(candidate Creatures:[Creature]) -> [Creature]{
        return Creatures.filter { (Creature) -> Bool in
            return (WorkAttitude.helpOther == self.Memory.thinkOf(AnotherCreature: Creature))
        }
    }

    func findNiceGuyFromCandidate(candidate Creatures:inout [Creature]) -> Creature?{
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
            if WorkAttitude.selfish != self.Memory.thinkOf(AnotherCreature: Creatures[index]) {
                randomeNiceGuy = Creatures[index]
                break;
            }
        }
        if nil == randomeNiceGuy {
            for index in 0...randomIndex{
                if WorkAttitude.selfish != self.Memory.thinkOf(AnotherCreature: Creatures[index]) {
                    randomeNiceGuy = Creatures[index]
                    break;
                }
            }
        }
        return randomeNiceGuy
    }

    func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        self.writeStory("Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue)
        self.Memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
    }
    
    func tell(_ creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        self.writeStory("Tell "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue)
        creature.listen(from: self, About: anotherCreatureID, WorkBehavior: behavior)
    }

    func talk(to creature:Creature, after result:WorkResult){
    }
}

class NiceCreature : Creature {
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            NiceCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }

    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures){
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
        }
        return nil
    }

    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: .helpOther)
    }

    override func talk(to creature:Creature, after result:WorkResult){
        //Only tell people nice behaivour
        if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
            self.tell(creature, About: OldFriendID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldFriendID))
        }
    }

}

class ConservativeCreature : Creature{
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            ConservativeCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures){
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
        }
        return nil
    }
    
    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: .selfish)
    }
    
    override func talk(to creature:Creature, after result:WorkResult){
        if result == .doubleWin { //The partner seems to be a nice one, tell him some thing
            if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
                self.tell(creature, About: OldFriendID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldFriendID))
            }
            
            if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
                self.tell(creature, About: OldEnemyID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldEnemyID))
            }
        }
    }

    override func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        if (self.Memory.thinkOf(AnotherCreature: creature) == .helpOther) {
            story += " and trust it"
            self.Memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        }else{
            story += " but don't trust it"
        }
        self.writeStory(story)
    }

}

class OpenBadCreature : Creature {
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            OpenBadCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }

    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: .selfish)
        }
        return nil
    }
    
    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: .selfish)
    }
    
    override func talk(to creature:Creature, after result:WorkResult){
        //Always lie to others
        if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
            self.tell(creature, About: OldFriendID, WorkBehavior: .selfish)
        }
        
        if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
            self.tell(creature, About: OldEnemyID, WorkBehavior: .helpOther)
        }
    }

    override func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        story += " and trust it"
        self.Memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        self.writeStory(story)
    }

}

class ConservativeBadCreature : Creature {
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            ConservativeBadCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }

    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures) {
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: .selfish)
        }
        return nil
    }
    
    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: .selfish)
    }
    
    override func talk(to creature:Creature, after result:WorkResult){
        //Always lie to others
        if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
            self.tell(creature, About: OldFriendID, WorkBehavior: .selfish)
        }
        
        if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
            self.tell(creature, About: OldEnemyID, WorkBehavior: .helpOther)
        }
    }
    
    override func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        story += " but don't trust it"
        self.writeStory(story)
    }

}

class StrategyBadCreature : Creature {
    var SelfishStrategy = SelfishStrategyMemory()

    override func thinking() {
        SelfishStrategy.thinking()
    }
    
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            StrategyBadCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures) {
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: SelfishStrategy.currentStrategyAction)
        }
        return nil
    }
    
    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: SelfishStrategy.currentStrategyAction)
    }
    
    override func talk(to creature:Creature, after result:WorkResult){
        //Always lie to others
        if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
            self.tell(creature, About: OldFriendID, WorkBehavior: .selfish)
        }
        
        if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
            self.tell(creature, About: OldEnemyID, WorkBehavior: .helpOther)
        }
    }
    
    override func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        if (self.Memory.thinkOf(AnotherCreature: creature) == .helpOther) {
            story += " and trust it"
            self.Memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        }else{
            story += " but don't trust it"
        }
        self.writeStory(story)
    }

}

class MeanCreature : Creature{
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            MeanCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }

    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures){
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
        }
        return nil
    }

    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        var workAction = self.Memory.thinkOf(AnotherCreature: AnotherCreature)
        if workAction == .none {
            workAction = .helpOther
        }
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: workAction)
    }

    override func talk(to creature:Creature, after result:WorkResult){
        if result == .doubleWin || result == .exploitation{ //The partner seems to be a nice one, tell him some thing
            if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
                self.tell(creature, About: OldFriendID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldFriendID))
            }
            
            if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
                self.tell(creature, About: OldEnemyID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldEnemyID))
            }
        }
    }

    override func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        if (self.Memory.thinkOf(AnotherCreature: creature) == .helpOther) {
            story += " and trust it"
            self.Memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        }else{
            story += " but don't trust it"
        }
        self.writeStory(story)
    }

}

class SelfishMeanCreature : Creature{
    override func selfReproduction() -> Creature? {
        return super.selfReproduction (ReproductionBlock: { () -> Creature? in
            SelfishMeanCreature.init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
        })
    }
    
    override func findCoWorker(candidate Creatures:inout [Creature]) -> WorkAction?{
        var CoWorkCreature:Creature?
        
        if let OldFriend = self.findOneFriendFromCandidate(candidate: &Creatures){
            CoWorkCreature = OldFriend
        }else if let NewFriend = self.findNiceGuyFromCandidate(candidate: &Creatures){
            CoWorkCreature = NewFriend
        }else {
            CoWorkCreature = Creatures.randomPick()
        }
        
        if let foundCoworker = CoWorkCreature {
            return WorkAction(Worker:self, WorkingPartner: foundCoworker, WorkingAttitude: .helpOther)
        }
        return nil
    }
    
    override func respondWorkAction(to AnotherCreature: Creature) -> WorkAction {
        var workAction = self.Memory.thinkOf(AnotherCreature: AnotherCreature)
        if workAction == .none {
            workAction = .selfish
        }
        return WorkAction(Worker:self, WorkingPartner: AnotherCreature, WorkingAttitude: workAction)
    }
    
    override func talk(to creature:Creature, after result:WorkResult){
        if result == .doubleWin || result == .exploitation { //The partner seems to be a nice one, tell him some thing
            if let OldFriendID = self.Memory.thinkOfOneRandomFriendID(), OldFriendID != creature.identifier.uniqueID{
                self.tell(creature, About: OldFriendID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldFriendID))
            }
            
            if let OldEnemyID = self.Memory.thinkOfOneRandomEnemyID(), OldEnemyID != creature.identifier.uniqueID{
                self.tell(creature, About: OldEnemyID, WorkBehavior: self.Memory.thinkOf(AnotherCreatureID: OldEnemyID))
            }
        }
    }

    override func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        var story = "Been told from "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue
        if (self.Memory.thinkOf(AnotherCreature: creature) == .helpOther) {
            story += " and trust it"
            self.Memory.remember(AnotherCreatureID: anotherCreatureID, Behavior: behavior)
        }else{
            story += " but don't trust it"
        }
        self.writeStory(story)
    }

}


class CreatureMemory{
    var behaviorMemory:[String:WorkAttitude] = [:]

    func remember (AnotherCreatureID:String, Behavior:WorkAttitude){
        behaviorMemory[AnotherCreatureID] = Behavior
    }

    func remember (AnotherCreature:Creature, Behavior:WorkAttitude){
        behaviorMemory[AnotherCreature.identifier.uniqueID] = Behavior
    }
    
    func forget (AnotherCreatureID : String) {
        behaviorMemory.removeValue(forKey: AnotherCreatureID)
    }

    func thinkOf(AnotherCreatureID : String) -> WorkAttitude {
        guard let memoryForThisCreature = behaviorMemory[AnotherCreatureID] else {
            return WorkAttitude.none
        }
        return memoryForThisCreature
    }

    func thinkOf(AnotherCreature:Creature) -> WorkAttitude {
        guard let memoryForThisCreature = behaviorMemory[AnotherCreature.identifier.uniqueID] else {
            return WorkAttitude.none
        }
        return memoryForThisCreature
    }

    func memoryInherit() -> [String:WorkAttitude] {
        var NewMemory:[String:WorkAttitude] = [:]
        let ExpectedRememberMemoryCount = 10
        for (Key,Value) in behaviorMemory {
            if Int(arc4random_uniform(UInt32(behaviorMemory.count))) < ExpectedRememberMemoryCount {
                NewMemory[Key] = Value
            }
        }
        return NewMemory
    }
    
    func thinkOfOneRandomFriendID() -> String? {
        let niceMemories = behaviorMemory.filter{$1 == .helpOther}.map { key,action in key}
        
        return niceMemories.randomPick()
    }

    func thinkOfOneRandomEnemyID() -> String? {
        let badMemories = behaviorMemory.filter{$1 == .selfish}.map { key,action in key}
        return badMemories.randomPick()
    }

    
}

class SelfishStrategyMemory{
    let showSelfCount:Int = 3
    let hideSelfCount:Int = 3
    var disguiseCounter:Int = 0
    var currentStrategyAction  = WorkAttitude.helpOther

    func thinking() {
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

