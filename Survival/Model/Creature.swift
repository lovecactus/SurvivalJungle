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
    let reproductionAge:Int = 40
    let reproductionCost:Double = 60
    let newBornResource:Double = 40
    let creatureReproductionThreshold:Double = 200
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
        let TeamProposal = method.TeamLead.TeamPropose(from: self, on: creatures)
        if nil != TeamProposal {
            writeStory("Try leading a team, with cost:"+String(teamStartUpCost))
            surviveResource -= teamStartUpCost
        }
        return TeamProposal
    }
    
    func AcceptInvite(to teams:[TeamWorkCooperation]) -> TeamWorkCooperation?{
        return method.TeamFollow.AcceptInvite(from: self, to: teams)
    }

    func WorkEffort(to team:TeamWorkCooperation) -> TeamCooperationEffort{
        return method.TeamFollow.WorkingEffort(from: self, to: team)
    }

    func WasteTime(){
        surviveResource -= wasteTimeResource
        writeStory("Nothing to do, waste time wandering.")
    }

    func AssignReward(to coopertion:inout TeamWorkCooperation) {
        writeStory("Assign rewards to members")
        return method.TeamLead.AssignReward(to: &coopertion)
    }

    func WorkCost(_ effort:TeamCooperationEffort) {
        let workingCost:SurvivalResource
        switch effort {
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
        writeStory("Working cost:"+String(workingCost)+" with attitude:"+String(describing: effort))
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
                                  TeamLead: TeamLeadMethodology_FairLeaderShip(),
                                  TeamFollow: TeamFollowMethodology())
    }
}

class FairNoLazyLeader : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology_FairLeaderShip_NoLazy(),
                                  TeamFollow: TeamFollowMethodology())
    }
}

class SelfishLeader : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology_SelfishLeader(),
                                  TeamFollow: TeamFollowMethodology())
    }
}

class SelfishNoLazyLeader : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology_SelfishLeader_NoLazy(),
                                  TeamFollow: TeamFollowMethodology())
    }
}

class BetterSelfishLeader : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology_BetterSelfishLeaderShip(),
                                  TeamFollow: TeamFollowMethodology())
    }
}

class Follower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology())
    }
}


class ConservativeRewardFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology_ConservativeRewardFollower())
    }
}

class SelfishRewardFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology_SelfishRewardFollower())
    }
}

class FairFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology_FairFollower())
    }
}

class ConservativeRewardLazyFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology_ConservativeRewardFollower_Lazy())
    }
}

class SelfishRewardLazyFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology_SelfishRewardFollower_Lazy())
    }
}

class FairLazyFollower : Creature {
    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
        self.method = Methodology(Talk: TalkMethodology(),
                                  Listen: ListenMethodology(),
                                  TeamLead: TeamLeadMethodology(),
                                  TeamFollow: TeamFollowMethodology_FairFollower_Lazy())
    }
}
