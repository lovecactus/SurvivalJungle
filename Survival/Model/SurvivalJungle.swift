//
//  SurvivalJungle.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

typealias CreatureGroup = [CreatureUniqueID:Creature]

class SurvivalJungle {
    var jungleTotalResource:RewardResource
    var jungleTotalResourceMax:RewardResource
    var jungleTotalResourceMin:RewardResource
    var currentSeason:Int
    var creatureNumber:Int

    var allCreatures:CreatureGroup = [:]
    var diedCreatures:[Creature] = []
    var social:SocialBehavior? = nil
    
    var statistic:[SurvivalStatistic] = []
    var statisticFilter:[String] = []
    
    init(totalResource:Double, averageCreatureNumber:Int) {
        jungleTotalResourceMax = totalResource
        jungleTotalResourceMin = totalResource/3
        jungleTotalResource = totalResource*2/3
        creatureNumber = averageCreatureNumber
        currentSeason = 0
        self.initialCreatureGroup()
        statisticFilter = [
//            "Method:-MatingMore",
//            "Method:-MatingLess",
//            "Method:-LoveChild",
//            "Method:-HateChild",
            "Method:-Male",
            "Method:-Female",
            "Method:Adapter",
            "Method:BornLeader",
            "Method:BornFollower",
//            "Method:AllSons",
//            "Method:FirstSon"
//            "Method:-AllIn",
//            "Method:-Responsive",
//            "Method:-BeLazy",
//            "Method:-AnyOneOK",
//            "Method:-NoLazy",
//            "Method:-ValueDigger",
//            "Method:-OnlyAllIn",
        ]

    }
    
    func initialCreatureGroup() {
        for index in 1...creatureNumber {
            let newBornCreature = GenericSpecies.init(familyName: "Generic",
                                                      givenName: String(index),
                                                      methodology: Methodology.randomMethodGenerator(),
                                                      age: Int(arc4random_uniform(50)))
            newBornCreature.surviveResource = 40+SurvivalResource(arc4random_uniform(40))
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
            jungleTotalResource += SurvivalResource(arc4random_uniform(UInt32(jungleTotalResourceMax/10))) - jungleTotalResourceMax/20
            jungleTotalResource = (jungleTotalResource > jungleTotalResourceMax) ? jungleTotalResourceMax : jungleTotalResource
            jungleTotalResource = (jungleTotalResource < jungleTotalResourceMin) ? jungleTotalResourceMin : jungleTotalResource
            var seasonResource = jungleTotalResource
            let social = SocialBehavior(with: &allCreatures, seasonResource:&seasonResource)
            social.statistic["Season Resource"] = seasonResource
            social.SeasonWork()

            let newBornCreatures = social.CreaturesReproduction()
            social.statistic["Ignore:New Born"] = Double(newBornCreatures.count)
            newBornCreatures.forEach({ (creature) in
                guard nil == allCreatures[creature.identifier.uniqueID] else {
                    print(#function+": Critical error. Duplicate creature unique ID")
                    return
                }
                allCreatures[creature.identifier.uniqueID] = creature
            })

            let seasonDiedCreature = self.CreaturesSurvival()
            social.statistic["Ignore:Died"] = Double(seasonDiedCreature.count)
            diedCreatures.append(contentsOf: seasonDiedCreature)
            
            self.CreaturesAging()
            
            social.statistic["Ignore:Creature Type"] = Double(allCreatures.findAllCreatureMethodology().count)

//            for methodologyDescriptor in allCreatures.findAllCreatureMethodology() {
//                social.statistic["Species:"+methodologyDescriptor] = Double(allCreatures.findAllCreatureWith(methodDescriptor:methodologyDescriptor).count)
//            }
            for filterKey in statisticFilter.filter({$0.hasPrefix("Method:")}).map({String($0.suffix(from: $0.index($0.startIndex, offsetBy: "Method:".count)))}) {
                social.statistic[filterKey] = Double(allCreatures.findAllCreatureWith(fullMethodDescriptor:filterKey).count)
            }
            
            statistic.append(social.statistic)
            print("season-\(currentSeason):\(social.statistic)")
            
            if currentSeason % 10 == 0 {
                var logs:[(String,Double)] = []
                for (methodologyDescriptor, count) in allCreatures.categoryCreatureMethodologys() {
                    social.statistic["Species:"+methodologyDescriptor] = Double(count)
                    logs.append(("Species:"+methodologyDescriptor,Double(count)))
                }
                logs.sorted(by: { (value1, value2) -> Bool in
                    return value1.1 > value2.1
                }).forEach({ (key) in
                    print(key.0+":\t\t\(key.1)")
                })
            }

//            print("season-\(currentSeason):\(social.statistic.filter{$0.key.hasPrefix("Species:") == false && $0.key.hasPrefix("Method:") == false})")
//            print("method-\(currentSeason):\(social.statistic.filter{$0.key.hasPrefix("Method:") == true })")
//            print("species-\(currentSeason):\(social.statistic.filter{$0.key.hasPrefix("Species:") == true })")
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

