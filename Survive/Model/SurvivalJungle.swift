//
//  SurvivalJungle.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import Foundation

struct CreatureSocialGroup {
    var groupMember : [Creature]
}

struct SurvivalStatistic{
    var Cheat:Int = 0
    var Cooperate:Int = 0
    var Failure:Int = 0
    var NewBorn:Int = 0
    var Died:Int = 0
    var Alone:Int = 0
}

struct WorkResultRecord{
    var Creature1:Creature
    var Creature2:Creature
    var Creature1Action:WorkAction
    var Creature2Action:WorkAction
    var Creature1Result:WorkResult
    var Creature2Result:WorkResult
}

class SurvivalJungle {
    let seasonNumber = 1000

    public static let ForestTotalResource = 5000
    public static var CreatureSurviveScore:Double = -50
    public static let CreatureReproductionScore:Double = 100
    
//    var DataBase:DBLayer = DBLayer()
    
    var SurviveChallenge:Challenge = Challenge()
    var AllCreatures:[Creature] = []
    var Social = SocialBehavior()
    
    var Statistic = SurvivalStatistic()
    
    init() {
        self.initialCreatureGroup()
    }
    
    func initialCreatureGroup() {
        for index in 1...20 {
            AllCreatures.append(OpenBadCreature(creatureIdentifier: "OpenBad"+String(index)))
        }
        for index in 1...20 {
           AllCreatures.append(ConservativeBadCreature(creatureIdentifier: "ConservativeBad"+String(index)))
        }
        for index in 1...20 {
            AllCreatures.append(StrategyBadCreature(creatureIdentifier: "StrategyBad"+String(index)))
        }
        for index in 1...50 {
            AllCreatures.append(NiceCreature(creatureIdentifier: "Nice"+String(index)))
        }
        for index in 1...50 {
            AllCreatures.append(MeanCreature(creatureIdentifier: "Mean"+String(index)))
        }
    }
    
    func MatingMatchPairs( ShuffleCreatures:[Creature]) ->[[Creature]]{
        var ShuffledCreatures = ShuffleCreatures
        ShuffledCreatures.shuffle()
        var ShuffledCreaturePairs:[[Creature]] = []
        for index in 1...(ShuffleCreatures.count/2){
            ShuffledCreaturePairs.append([ShuffledCreatures[index*2],ShuffledCreatures[index*2+1]])
        }
        return ShuffledCreaturePairs
    }
        
    func WorkMatchPairs(AllCreatures:[Creature]) ->[[Creature]]{
        var CandidateCreatures = AllCreatures

        let MatchedCreaturePairs:[[Creature]] = CandidateCreatures.map { (Creature) -> [Creature] in
            if let CoWorker = Creature.findCoWorker(candidate: &CandidateCreatures) {
                return [Creature, CoWorker]
            }
            return [Creature]
        }

        return MatchedCreaturePairs
    }
    
    func Working() {
        var AverageResource:Double = Double(SurvivalJungle.ForestTotalResource/AllCreatures.count)/10
        AverageResource = (AverageResource > 10) ? 10 : AverageResource

        let ShuffledCreaturePairs = self.WorkMatchPairs(AllCreatures: AllCreatures)
        var WorkResults:[WorkResultRecord] = []
        for CreaturePair in ShuffledCreaturePairs {
            if (CreaturePair.count == 1){
                let Creature1 = CreaturePair[0]
                Creature1.stayAlone()
                Statistic.Alone += 1
            }else{
                guard CreaturePair.count >= 2 else {
                    continue
                }
                
                let Creature1 = CreaturePair[0]
                let Creature2 = CreaturePair[1]
                var Creature1Result:WorkResult = WorkResult.none
                var Creature2Result:WorkResult = WorkResult.none
                let Creature1Action = Creature1.workAction(ToAnotherCreature: Creature2)
                let Creature2Action = Creature2.workAction(ToAnotherCreature: Creature1)
                Social.Work(Creature1: Creature1,
                            Action1: Creature1Action,
                            Result1: &Creature1Result,
                            Creature2: Creature2,
                            Action2: Creature2Action,
                            Result2: &Creature2Result)
                
                WorkResults.append(WorkResultRecord(Creature1: Creature1,
                                                    Creature2: Creature2,
                                                    Creature1Action: Creature1Action,
                                                    Creature2Action: Creature2Action,
                                                    Creature1Result: Creature1Result,
                                                    Creature2Result: Creature2Result))
            }
        }
        
        for WorkResult in WorkResults {
            
            switch WorkResult.Creature1Result {
            case .beenCheated,.exploitation:
                Statistic.Cheat += 1
                break;
            case .doubleWin:
                Statistic.Cooperate += 1
                break;
            case .doubleLose:
                Statistic.Failure += 1
                break;
            default:
                break;
            }
            
            WorkResult.Creature1.workResult(AnotherCreature: WorkResult.Creature2,
                                            AnotherAction: WorkResult.Creature2Action,
                                            result: WorkResult.Creature1Result,
                                            harvestResource: AverageResource)
            WorkResult.Creature2.workResult(AnotherCreature: WorkResult.Creature1,
                                            AnotherAction: WorkResult.Creature1Action,
                                            result: WorkResult.Creature2Result,
                                            harvestResource: AverageResource)
            
        }
    }
    
    func Thinking() {
        AllCreatures.forEach { (Creature) in
            Creature.thinking()
        }
    }

    func CreturesSurvival() {
        AllCreatures = AllCreatures.filter { (Creature) -> Bool in
            if Creature.SurviveResource >= SurvivalJungle.CreatureSurviveScore {
                return true
            }else{
                Statistic.Died += 1
                return false
            }
        }
    }
    
    func CreturesReproduction() {
        var NewBornCreatures:[Creature] = []
        
        AllCreatures.forEach { (Creature) in
            if Creature.SurviveResource >= SurvivalJungle.CreatureReproductionScore {
                NewBornCreatures.append(Creature.selfReproduction())
                Statistic.NewBorn += 1
            }
        }
        
        AllCreatures.append(contentsOf: NewBornCreatures)
    }

    func SurviveSeason() {
        //Check if a creature is about to die or reproduction
        for index in 1...seasonNumber{
            self.CleanUpStatstic()
            self.Working()
            self.Thinking()
            self.CreturesReproduction()
            self.CreturesSurvival()
            self.SurviveCreaturesStatistic(index)
        }
    }
    
    func CleanUpStatstic(){
        Statistic.Cooperate = 0
        Statistic.Cheat = 0
        Statistic.Failure = 0
        Statistic.NewBorn = 0
        Statistic.Died = 0
        Statistic.Alone = 0
    }
    
    func SurviveCreaturesStatistic(_ round:Int){
        let creatureResources:[Double] = AllCreatures.map { (Creature) -> Double in
            return Creature.SurviveResource
        }
        
        let survivedNiceCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is NiceCreature
        }
        
        let survivedOpenBadCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is OpenBadCreature
        }

        let survivedStrategyBadCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is StrategyBadCreature
        }

        let survivedConservativeBadCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is ConservativeBadCreature
        }
        
        let survivedMeanCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is MeanCreature
        }
        
        print ("round:",round, "\t cooperate:",Statistic.Cooperate, "\t cheat:",Statistic.Cheat, "\t failure:",Statistic.Failure, "\t NewBorn:",Statistic.NewBorn, "\t died:",Statistic.Died);
        print ("All Creatures:",AllCreatures.count,"\t NiceCreature:",survivedNiceCreature.count,"\t OpenBadCreature:",survivedOpenBadCreature.count,"\t ConservativeBadCreature:",survivedConservativeBadCreature.count,"\t StrategyBadCreature:",survivedStrategyBadCreature.count,"\t MeanCreature:",survivedMeanCreature.count)
        print ("group resource:", creatureResources.reduce(0, +), "average resource:",creatureResources.average)

    }
    
}
