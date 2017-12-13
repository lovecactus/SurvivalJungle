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
    var currentSeason:Int
    var creatureNumber:Int

    var allCreatures:[Creature] = []
    var diedCreatures:[Creature] = []
    var social:SocialBehavior? = nil
    
    var statistic:[SurvivalStatistic] = []
    
    init(totalResource:Double, averageCreatureNumber:Int) {
        jungleTotalResource = totalResource
        creatureNumber = averageCreatureNumber
        currentSeason = 0
        self.initialCreatureGroup()
    }
    
    func initialCreatureGroup() {
        for index in 1...creatureNumber {
            allCreatures.append(FairLeader(familyName: "FairLeader", givenName: String(index), age: Int(arc4random_uniform(50))))
//            allCreatures.append(FairNoLazyLeader(familyName: "FairNoLazyLeader", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(SelfishLeader(familyName: "SelfishLeader", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(BetterSelfishLeader(familyName: "BetterSelfishLeader", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(BetterSelfishAdapter(familyName: "BetterSelfishAdapter", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(SelfishRewardFollower(familyName: "SelfishRewardFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(FairFollower(familyName: "FairFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
            allCreatures.append(ConservativeRewardFollower(familyName: "ConservativeRewardFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
//            allCreatures.append(SelfishRewardLazyFollower(familyName: "SelfishRewardLazyFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
//            allCreatures.append(FairLazyFollower(familyName: "FairLazyFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
//            allCreatures.append(ConservativeRewardLazyFollower(familyName: "ConservativeRewardLazyFollower", givenName: String(index), age: Int(arc4random_uniform(50))))
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
    
    func Run(_ seasonNumber:Int) -> [SurvivalStatistic]{
        for _ in currentSeason...currentSeason+seasonNumber-1{
            currentSeason += 1;
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
//            social.statistic["FairNoLazyLeader"] = Double(allCreatures.findAllCeatures(Of: "FairNoLazyLeader").count)
            social.statistic["SelfishLeader"] = Double(allCreatures.findAllCeatures(Of: "SelfishLeader").count)
            social.statistic["BetterSelfishLeader"] = Double(allCreatures.findAllCeatures(Of: "BetterSelfishLeader").count)
            social.statistic["BetterSelfishAdapter"] = Double(allCreatures.findAllCeatures(Of: "BetterSelfishAdapter").count)
            social.statistic["SelfishRewardFollower"] = Double(allCreatures.findAllCeatures(Of: "SelfishRewardFollower").count)
            social.statistic["FairFollower"] = Double(allCreatures.findAllCeatures(Of: "FairFollower").count)
            social.statistic["ConservativeRewardFollower"] = Double(allCreatures.findAllCeatures(Of: "ConservativeRewardFollower").count)
//            social.statistic["SelfishRewardLazyFollower"] = Double(allCreatures.findAllCeatures(Of: "SelfishRewardLazyFollower").count)
//            social.statistic["FairLazyFollower"] = Double(allCreatures.findAllCeatures(Of: "FairLazyFollower").count)
//            social.statistic["ConservativeRewardLazyFollower"] = Double(allCreatures.findAllCeatures(Of: "ConservativeRewardLazyFollower").count)
            statistic.append(social.statistic)
            print("season-\(currentSeason):\(social.statistic)")
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

