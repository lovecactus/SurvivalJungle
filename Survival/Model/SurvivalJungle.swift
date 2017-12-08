//
//  SurvivalJungle.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

struct CreatureSocialGroup {
    var groupMember : [Creature]
}

class SurvivalJungle {
    var jungleTotalResource:RewardResource
    var seasonNumber:Int
    var creatureNumber:Int

    var allCreatures:[Creature] = []
    var diedCreatures:[Creature] = []
    var social:SocialBehavior? = nil
    
    var statistic:[SurvivalStatistic] = []
    
    init(totalResource:Double, totalSeasonNumber:Int, averageCreatureNumber:Int) {
        jungleTotalResource = totalResource
        seasonNumber = totalSeasonNumber
        creatureNumber = averageCreatureNumber
        self.initialCreatureGroup()
    }
    
    func initialCreatureGroup() {
        for index in 1...creatureNumber {
            allCreatures.append(FairLeader(familyName: "Fair Leader", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(SelfishLeader(familyName: "SelfishLeader", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(EliteFollower(familyName: "EliteFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(ConservativeFollower(familyName: "ConservativeFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
        }
        allCreatures.shuffle()
    }
    
    func CreaturesSurvival() -> [Creature]{
        var FailedCreature:[Creature] = []
        allCreatures = allCreatures.filter({ (ChallengingCreature:Creature) -> Bool in
            if ChallengingCreature.surviveChallenge() {
                return true
            }
            FailedCreature.append(ChallengingCreature)
            return false
        })
        
        return FailedCreature
    }

    func CreaturesAging() {
        allCreatures.forEach { (Creature) in
            Creature.aging()
        }
    }
    
    func SandboxStart() -> [SurvivalStatistic]{
        for season in 1...seasonNumber{
            var seasonResource = jungleTotalResource
            let social = SocialBehavior(with: allCreatures, seasonResource:&seasonResource)
            social.TeamWork()

            let newBornCreatures = social.CreaturesReproduction()
            allCreatures.append(contentsOf: newBornCreatures)

            let seasonDiedCreature = self.CreaturesSurvival()
            diedCreatures.append(contentsOf: seasonDiedCreature)
            
            self.CreaturesAging()
//            social.statistic.countResource(in: allCreatures)
            social.statistic["FairLeader"] = Double(allCreatures.findAllCeatures(Of: "FairLeader").count)
            social.statistic["SelfishLeader"] = Double(allCreatures.findAllCeatures(Of: "SelfishLeader").count)
            social.statistic["EliteFollower"] = Double(allCreatures.findAllCeatures(Of: "EliteFollower").count)
            social.statistic["ConservativeFollower"] = Double(allCreatures.findAllCeatures(Of: "ConservativeFollower").count)
            statistic.append(social.statistic)
            print("season-\(season):\(social.statistic)")
        }
        return statistic
    }

}


extension Array {
    func findAllCeatures(Of CreatureTypeName:String) -> [Iterator.Element] {
        return self.filter({ (Element) -> Bool in
            return String(describing: type(of: Element)) == CreatureTypeName
        })
    }
}


extension Array where Element : Creature {
    func findAllDie(By DieReason:String) -> [Creature] {
        return self.filter({ (DieCreature) -> Bool in
            return DieCreature.Story.last == DieReason
        })
    }
    func findCreatureBy(name:String) -> Creature? {
        return self.first(where:{ (FindCreature) -> Bool in
            return (FindCreature.identifier.familyName+FindCreature.identifier.givenName == name)
        })
    }
    mutating func removeFirstCreatureBy(uniqueID:String) -> Bool {
        var findCreatures = false
        for index in 0...self.count-1 {
            if (self[index].identifier.uniqueID == uniqueID){
                self.remove(at: index)
                findCreatures = true
                break
            }
        }
        return findCreatures
    }

    func findCreatureBy(uniqueID:String) -> Creature? {
        return self.first(where:{ (FindCreature) -> Bool in
            return (FindCreature.identifier.uniqueID == uniqueID)
        })
    }

}

