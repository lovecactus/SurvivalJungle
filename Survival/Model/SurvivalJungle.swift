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
            allCreatures.append(Creature(familyName: "Test", givenName: String(index), age: Int(arc4random_uniform(50))))
        }

    }
    
    func CreturesSurvival() -> [Creature]{
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

    func CreturesAging() {
        allCreatures.forEach { (Creature) in
            Creature.aging()
        }
    }

//    func SurviveStart() -> [SurvivalStatistic]{
//        //Check if a creature is about to die or reproduction
//        for season in 1...seasonNumber{
//            var SeasonStatistic = SurvivalStatistic()
//            self.Working(&SeasonStatistic)
//            self.CreturesReproduction(&SeasonStatistic)
//            self.CreturesSurvival()
//            self.CreturesAging()
//            self.SurviveCreaturesStatistic(season,SeasonStatistic:&SeasonStatistic)
//            statistic.append(SeasonStatistic)
//        }
//        return statistic
//    }
//
//    func SurviveCreaturesStatistic(_ season:Int, SeasonStatistic:inout SurvivalStatistic){
//        let creatureResources:[Double] = allCreatures.map { (Creature) -> Double in
//            return Creature.surviveResource
//        }
//
//        let survivedNiceCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is NiceCreature
//        }
//
//        let survivedConservativeCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is ConservativeCreature
//        }
//
//        let survivedOpenBadCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is OpenBadCreature
//        }
//
//        let survivedStrategyBadCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is StrategyBadCreature
//        }
//
//        let survivedConservativeBadCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is ConservativeBadCreature
//        }
//
//        let survivedMeanCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is MeanCreature
//        }
//
//        let survivedSelfishMeanCreature = allCreatures.filter { (Creature) -> Bool in
//            return Creature is SelfishMeanCreature
//        }
//
//        SeasonStatistic.Total = allCreatures.count
//        SeasonStatistic.Died = diedCreatures.count
//        SeasonStatistic.Nice = survivedNiceCreature.count
//        SeasonStatistic.Conservative = survivedConservativeCreature.count
//        SeasonStatistic.OpenBad = survivedOpenBadCreature.count
//        SeasonStatistic.ConservativeBad = survivedConservativeBadCreature.count
//        SeasonStatistic.StrategyBad = survivedStrategyBadCreature.count
//        SeasonStatistic.Mean = survivedMeanCreature.count
//        SeasonStatistic.SelfishMean = survivedSelfishMeanCreature.count
//
//        print ("round:",season,
//               "\t cooperate:",SeasonStatistic.Cooperate,
//               "\t cheat:",SeasonStatistic.Cheat,
//               "\t failure:",SeasonStatistic.Failure,
//               "\t NewBorn:",SeasonStatistic.NewBorn,
//               "\t died:",SeasonStatistic.Died);
//
//        print ("All creatures:",SeasonStatistic.Total,
//               "History died creatures:",SeasonStatistic.Died,
//               "\t NiceCreature:",SeasonStatistic.Nice,
//               "\t ConservativeCreature:",SeasonStatistic.Conservative,
//               "\t OpenBadCreature:",SeasonStatistic.OpenBad,
//               "\t ConservativeBadCreature:",SeasonStatistic.ConservativeBad,
//               "\t StrategyBadCreature:",SeasonStatistic.StrategyBad,
//               "\t MeanCreature:",SeasonStatistic.Mean,
//               "\t SelfishMeanCreature:",SeasonStatistic.SelfishMean
//               )
//
//        print ("group resource:", creatureResources.reduce(0, +), "average resource:",creatureResources.average)
//    }
    
    func SandboxStart() -> [SurvivalStatistic]{
        for _ in 1...seasonNumber{
            var seasonResource = jungleTotalResource
            let social = SocialBehavior(with: allCreatures, seasonResource:&seasonResource)
            social.TeamWork()

            let newBornCreatures = social.CreturesReproduction()
            social.statistic["NewBorn"] = Double(newBornCreatures.count)
            allCreatures.append(contentsOf: newBornCreatures)

            let seasonDiedCreature = self.CreturesSurvival()
            diedCreatures.append(contentsOf: seasonDiedCreature)
            social.statistic["Died"] = Double(diedCreatures.count)
            
            self.CreturesAging()
            social.statistic.countTotalResource(in: &allCreatures)
            social.statistic["total creature"] = Double(allCreatures.count)
            social.statistic["died creature"] = Double(diedCreatures.count)
            statistic.append(social.statistic)
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

