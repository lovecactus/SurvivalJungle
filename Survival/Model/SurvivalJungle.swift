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

typealias CreatureGroup = [CreatureUniqueID:Creature]

class SurvivalJungle {
    var jungleTotalResource:RewardResource
    var currentSeason:Int
    var creatureNumber:Int

    var allCreatures:CreatureGroup = [:]
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
            let newBornCreature = GenericSpecies.init(familyName: "Generic",
                                                      givenName: String(index),
                                                      methodology: Methodology.randomMethodGenerator(),
                                                      age: Int(arc4random_uniform(50)))
            allCreatures[newBornCreature.identifier.uniqueID] = newBornCreature

        }
    }
    
    func CreaturesSurvival() -> [Creature]{
        var FailedCreature:[Creature] = []
        allCreatures = allCreatures.filter({ (creatureID , ChallengingCreature) -> Bool in
            let tuple = ChallengingCreature.surviveChallenge()
            let surviveSucceed = tuple.0
            let failReason = tuple.1
            if surviveSucceed {
                return true
            }
            //Failed challenge, creature die
            ChallengingCreature.die(by: failReason, with: &allCreatures)
            FailedCreature.append(ChallengingCreature)
            return false
        })
        
        return FailedCreature
    }

    func CreaturesAging() {
        allCreatures.forEach { (Key, Creature) in
            Creature.aging()
        }
    }
    
    func Run(_ seasonNumber:Int) -> [SurvivalStatistic]{
        var previousTimestamp = Date().timeIntervalSince1970
        for _ in currentSeason...currentSeason+seasonNumber-1{
            let currentTimestamp = Date().timeIntervalSince1970
            let costTime = currentTimestamp - previousTimestamp
            previousTimestamp = currentTimestamp
            print ("Cost:"+String(costTime))
            currentSeason += 1;
            var seasonResource = jungleTotalResource
            let social = SocialBehavior(with: &allCreatures, seasonResource:&seasonResource)
            social.SeasonWork()

            let newBornCreatures = social.CreaturesReproduction()
//            social.statistic["New Born"] = Double(newBornCreatures.count)
            newBornCreatures.forEach({ (creature) in
                guard nil == allCreatures[creature.identifier.uniqueID] else {
                    print(#function+": Critical error. Duplicate creature unique ID")
                    return
                }
                allCreatures[creature.identifier.uniqueID] = creature
            })

            let seasonDiedCreature = self.CreaturesSurvival()
//            social.statistic["Died"] = Double(seasonDiedCreature.count)
            diedCreatures.append(contentsOf: seasonDiedCreature)
            
            self.CreaturesAging()
//            social.statistic.countResource(in: allCreatures)
//            for methodologyDescriptor in allCreatures.findAllCreatureMethodology() {
//                social.statistic["Species:"+methodologyDescriptor] = Double(allCreatures.findAllCreatureWith(methodDescriptor:methodologyDescriptor).count)
//            }
            
            if currentSeason % 10 == 0 {
                for (methodologyDescriptor, count) in allCreatures.categoryCreatureMethodologys() {
                    social.statistic["Species:"+methodologyDescriptor] = Double(count)
                }
            }

            social.statistic["Method:ReproLoveChild"] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:"ReproLoveChild").count)
            social.statistic["Method:ReproNormal"] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:"ReproNormal").count)
            social.statistic["Method:Adapter"] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:"Adapter").count)
            let Follower = allCreatures.findAllCreatureWith(fullMethodDescriptor:"Follower")
            social.statistic["Method:Follower"] = Double(Follower.count)
            social.statistic["Method:LazyFollower"] = Double(Follower.findAllCreatureWith(fullMethodDescriptor:"Lazy").count)
            social.statistic["Method:Leader"] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:"Leader").count)
            social.statistic["Method:HeritageAll"] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:"HeritageAll").count)
            social.statistic["Method:HeritageFirstSon"] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:"HeritageFirstSon").count)
//            social.statistic["CreatureCount"] = Double(allCreatures.findAllCreatureMethodology().count)

            statistic.append(social.statistic)
            print("season-\(currentSeason):\(social.statistic.filter{$0.key.hasPrefix("Species:") == false && $0.key.hasPrefix("Method:") == false})")
            print("method-\(currentSeason):\(social.statistic.filter{$0.key.hasPrefix("Method:") == true })")
            print("species-\(currentSeason):\(social.statistic.filter{$0.key.hasPrefix("Species:") == true })")
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


extension Dictionary where Value:Creature {
    func findAllDie(By DieReason:String) -> [Creature] {
        return self.filter({ (_, DieCreature) -> Bool in
            guard let lastWords = DieCreature.Story.last, lastWords.contains("Die by") else {
                return false
            }
            return lastWords.contains(DieReason)
        }).map({$0.value})
    }
    
    func findCreatureBy(name:String) -> Creature? {
        return self.first(where:{ (_, FindCreature) -> Bool in
            return (FindCreature.identifier.familyName+FindCreature.identifier.givenName == name)
        }).map({$0.value})
    }
    
    func findAllCreatureBy(familyName:String) -> [Creature] {
        return self.filter({ (_,FindCreature) -> Bool in
            return (FindCreature.identifier.familyName == familyName)
        }).map({$0.value})
    }

    func findAllCreatureMethodology() -> [String] {
        return self.map({$0.value.method.descriptor()}).removeDuplicates()
    }

    func findAllCreatureWith(methodDescriptor:String) -> [Creature] {
        return self.filter({ (_,FindCreature) -> Bool in
            return (FindCreature.method.descriptor().contains(methodDescriptor))
        }).map({$0.value})
    }
    
    func findAllCreatureWith(fullMethodDescriptor:String) -> [Creature] {
        return self.filter({ (_, FindCreature) -> Bool in
            return (FindCreature.method.detailDescriptor().contains(fullMethodDescriptor))
        }).map({$0.value})
    }
    
    func findCreatureBy(uniqueID:Key) -> Creature? {
        return self[uniqueID]
    }

    func findAllMethodology(Including methodName:String) -> [Creature] {
        return self.filter({ (_, creature) -> Bool in
            guard let methodyDict = try? creature.method.allProperties() else {
                return false
            }
            var find = false
            for (_, value) in methodyDict.enumerated(){
                let valueString = String(describing: type(of: value.value.self))
                if valueString.range(of:methodName) != nil {
                    find = true
                    break
                }
            }
            return find
        }).map({$0.value})
    }

    func categoryCreatureMethodologys() -> [String:Int] {
        var categoryMethdologys:[String:Int] = [:]
        self.forEach { (_, creature) in
            if let methodCount = categoryMethdologys[creature.method.descriptor()] {
                categoryMethdologys[creature.method.descriptor()] = methodCount + 1
            }else{
                categoryMethdologys[creature.method.descriptor()] = 1
            }
        }
        return categoryMethdologys
    }

}

extension Array where Element : Creature {
    func findAllDie(By DieReason:String) -> [Creature] {
        return self.filter({ (DieCreature) -> Bool in
            guard let lastWords = DieCreature.Story.last, lastWords.contains("Die by") else {
                return false
            }
            return lastWords.contains(DieReason)
        })
    }
    
    func findCreatureBy(name:String) -> Creature? {
        return self.first(where:{ (FindCreature) -> Bool in
            return (FindCreature.identifier.familyName+FindCreature.identifier.givenName == name)
        })
    }
    
    func findAllCreatureBy(familyName:String) -> [Creature] {
        return self.filter({ (FindCreature) -> Bool in
            return (FindCreature.identifier.familyName == familyName)
        })
    }
    
    func findAllCreatureMethodology() -> [String] {
        return self.map({$0.method.descriptor()}).removeDuplicates()
    }
    
    func findAllCreatureWith(methodDescriptor:String) -> [Creature] {
        return self.filter({ (FindCreature) -> Bool in
            return (FindCreature.method.descriptor().contains(methodDescriptor))
        })
    }
    
    func findAllCreatureWith(fullMethodDescriptor:String) -> [Creature] {
        return self.filter({ (FindCreature) -> Bool in
            return (FindCreature.method.detailDescriptor().contains(fullMethodDescriptor))
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
    
    func findAllMethodology(Including methodName:String) -> [Creature] {
        return self.filter({ (creature) -> Bool in
            guard let methodyDict = try? creature.method.allProperties() else {
                return false
            }
            var find = false
            for (_, value) in methodyDict.enumerated(){
                let valueString = String(describing: type(of: value.value.self))
                if valueString.range(of:methodName) != nil {
                    find = true
                    break
                }
            }
            return find
        })
    }
    
}

