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


protocol CommunicationProtocol {
    func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude)
    func tell(_ creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude)
    func talk(to creature:Creature, after result:WorkResult)
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
    let reproductionAge:Int = 20
    let reproductionCost:Double = 30
    let creatureReproductionThreshold:Double = 100
    public var Story:[String] = []
    var memory = CreatureMemory()
    var method = Methodology()

    static var idCounter = Int(0)
    
    required init(familyName:String, givenName:String) {
        Creature.idCounter += 1
        identifier = Identifer(familyName: familyName, givenName: givenName, bornID: Creature.idCounter)
        surviveResource = 20
    }

    convenience init(familyName:String, givenName:String, age:Int) {
        self.init(familyName: familyName, givenName: givenName)
        self.age = age
    }

    func talk(to creature:Creature, after result:WorkResult){
        method.Talk.talk(to: creature, after: result, memory: self.memory) { (creature, creatureID, behaviour) in
            self.tell(creature, About: creatureID, WorkBehavior: behaviour)
        }
    }
    
    func tell(_ creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        self.writeStory("Tell "+creature.identifier.uniqueID+" about "+anotherCreatureID+"'s behavior:"+behavior.rawValue)
        creature.listen(from: self, About: anotherCreatureID, WorkBehavior: behavior)
    }

    func listen(from creature:Creature, About anotherCreatureID:String, WorkBehavior behavior:WorkAttitude){
        method.Listen.listen(from: creature, about: anotherCreatureID, behavior: behavior, memory: self.memory) { (creature, creatureID, behaviour, story) in
            self.writeStory(story)
        }
    }

    func writeStory(_ NewStory:String) {
        Story.append("Age:"+String(age)+":"+NewStory)
    }
    
    func aging(){
        age += 1
    }
    
    func selfReproduction() -> Creature?{
        if age >= reproductionAge , surviveResource >= creatureReproductionThreshold{
            surviveResource -= reproductionCost
            writeStory("Born a new herit")
            
            let newBorn = type(of: self).init(familyName: identifier.familyName, givenName:identifier.givenName+"#")
            
            newBorn.memory.learnFromExperience(self.memory.teachExperience())
            newBorn.writeStory("Inherit memory from parent:"+newBorn.memory.description())
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
        let TeamProposal = method.TeamUp.TeamPropose(from: self, on: creatures)
        if nil != TeamProposal {
            writeStory("Try leading a team")
        }
        return TeamProposal
    }
    
    func AcceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        return method.TeamUp.AcceptInvite(from: self, to: teams)
    }
    
    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        writeStory("Assign rewards to members")
        return method.TeamUp.AssignReward(to: &coopertion)
    }

    func WorkCost(_ workingCost:WorkingCostResource) {
        writeStory("Working cost:"+String(workingCost))
        self.surviveResource -= workingCost
    }

    func GetReward(_ rewardResource:RewardResource, as cooperation:TeamWorkCooperation) {
        writeStory("Get reward from team:"+String(rewardResource)+", leader:"+cooperation.Team.TeamLeaderID)
        self.surviveResource += rewardResource
        self.memory.remember(teamWorkCooperation: cooperation)
    }
}

class FairLeader : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamUp: TeamUpMethodology_LeaderShip())
    }
}

class SelfishLeader : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamUp: TeamUpMethodology_SelfishLeader())
    }
}

class Follower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamUp: TeamUpMethodology_Follower())
    }
}


class ConservativeFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamUp: TeamUpMethodology_ConservativeFollower())
    }
}

class EliteFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamUp: TeamUpMethodology_EliteFollower())
    }
}
