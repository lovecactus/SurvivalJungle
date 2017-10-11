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
    var Total:Int = 0
    var Died:Int = 0
    var OpenBad:Int = 0
    var ConservativeBad:Int = 0
    var StrategyBad:Int = 0
    var Nice:Int = 0
    var Conservative:Int = 0
    var Mean:Int = 0
    var SelfishMean:Int = 0

    var Cheat:Int = 0
    var Cooperate:Int = 0
    var Failure:Int = 0
    var NewBorn:Int = 0
    var Alone:Int = 0
}

class SurvivalJungle {
    var JungleTotalResource:Double
    var SeasonNumber:Int
    var CreatureNumber:Int
    
    var SurviveChallenge:Challenge = Challenge()
    var AllCreatures:[Creature] = []
    var DiedCreatures:[Creature] = []
    var Social = SocialBehavior()
    
    var Statistic:[SurvivalStatistic] = []
    
    init(totalResource:Double, seasonNumber:Int, creatureNumber:Int) {
        JungleTotalResource = totalResource
        SeasonNumber = seasonNumber
        CreatureNumber = creatureNumber
        self.initialCreatureGroup()
    }
    
    func initialCreatureGroup() {
        for index in 1...CreatureNumber {
            AllCreatures.append(OpenBadCreature(familyName: "OpenBad", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...CreatureNumber {
            AllCreatures.append(ConservativeBadCreature(familyName: "ConservativeBad", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...CreatureNumber {
            AllCreatures.append(StrategyBadCreature(familyName: "StrategyBad", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...CreatureNumber {
            AllCreatures.append(ConservativeCreature(familyName: "Conservative", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...CreatureNumber {
            AllCreatures.append(NiceCreature(familyName: "Nice", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...CreatureNumber {
            AllCreatures.append(MeanCreature(familyName: "Mean", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...CreatureNumber {
            AllCreatures.append(SelfishMeanCreature(familyName: "SelfishMean", givenName: String(index), age:Int(arc4random_uniform(50))))
        }

    }
    
    func WorkMatchCooperations(AllCreatures:[Creature]) ->[WorkCooperation]{
        var CandidateCreatures = AllCreatures

        let MatchedCreaturePairs:[WorkCooperation] = CandidateCreatures.map { (Creature) -> WorkCooperation in
            guard let CoWorkRequestAction = Creature.findCoWorker(candidate: &CandidateCreatures) else {
                //Find no other co-worker, stay alone
                return WorkCooperation(RequestWorkAction: WorkAction(Worker:Creature, WorkingPartner:nil, WorkingAttitude: .selfish), ResponseWorkAction: nil)
            }
            let CoWorkResponseAction = CoWorkRequestAction.WorkingPartner?.respondWorkAction(to: Creature)
            return WorkCooperation(RequestWorkAction: CoWorkRequestAction, ResponseWorkAction: CoWorkResponseAction)
        }

        return MatchedCreaturePairs
    }
    
    func Working(_ SeasonStatistic:inout SurvivalStatistic) {
        var AverageResource:Double = Double(Double(JungleTotalResource)/Double(AllCreatures.count))/10
        AverageResource = (AverageResource > 10) ? 10 : AverageResource

        let MatchedWorkCooperations = WorkMatchCooperations(AllCreatures: AllCreatures)

        for Cooperation in MatchedWorkCooperations {
            let CooperationResult = Social.Work(As: Cooperation, AverageResource:AverageResource)
            
            switch CooperationResult.RequestResult {
            case .beenCheated,.exploitation:
                SeasonStatistic.Cheat += 1
                break;
            case .doubleWin:
                SeasonStatistic.Cooperate += 1
                break;
            case .doubleLose:
                SeasonStatistic.Failure += 1
                break;
            case .stayAlone:
                SeasonStatistic.Alone += 1
                break;
            }
            
            Cooperation.RequestWorkAction.Worker.requestWorkResult(of: Cooperation, CooperationResult: CooperationResult)
            Cooperation.ResponseWorkAction?.Worker.responseWorkResult(of: Cooperation, CooperationResult: CooperationResult)
            
            //Conversation after cooperation
            if let RequestPartner = Cooperation.RequestWorkAction.WorkingPartner {
                Cooperation.RequestWorkAction.Worker.talk(to: RequestPartner, after: CooperationResult.RequestResult)
            }

            if let ResponsePartner = Cooperation.ResponseWorkAction?.WorkingPartner,
                let ResponseResult = CooperationResult.ResponseResult{
                Cooperation.ResponseWorkAction?.Worker.talk(to: ResponsePartner, after: ResponseResult)
            }

        }
    }
    

    func Thinking() {
        AllCreatures.forEach { (Creature) in
            Creature.thinking()
        }
    }

    func CreturesSurvival() {
        var FailedCreature:[Creature] = []
        AllCreatures = AllCreatures.filter({ (ChallengingCreature:Creature) -> Bool in
            if ChallengingCreature.surviveChallenge() {
                return true
            }
            FailedCreature.append(ChallengingCreature)
            return false
        })
        
        DiedCreatures.append(contentsOf: FailedCreature)
    }

    func CreturesAging() {
        AllCreatures.forEach { (Creature) in
            Creature.aging()
        }
    }

    func CreturesReproduction(_ SeasonStatistic:inout SurvivalStatistic) {
        var NewBornCreatures:[Creature] = []
        
        AllCreatures.forEach { (Creature) in
            if let NewBornCreature = Creature.selfReproduction(){
                NewBornCreatures.append(NewBornCreature)
                SeasonStatistic.NewBorn += 1
            }
        }
        
        AllCreatures.append(contentsOf: NewBornCreatures)
    }

    func SurviveStart() -> [SurvivalStatistic]{
        //Check if a creature is about to die or reproduction
        for season in 1...SeasonNumber{
            var SeasonStatistic = SurvivalStatistic()
            self.Working(&SeasonStatistic)
            self.CreturesReproduction(&SeasonStatistic)
            self.CreturesSurvival()
            self.CreturesAging()
            self.Thinking()
            self.SurviveCreaturesStatistic(season,SeasonStatistic:&SeasonStatistic)
            Statistic.append(SeasonStatistic)
        }
        return Statistic
    }
    
    func SurviveCreaturesStatistic(_ season:Int, SeasonStatistic:inout SurvivalStatistic){
        let creatureResources:[Double] = AllCreatures.map { (Creature) -> Double in
            return Creature.SurviveResource
        }
        
        let survivedNiceCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is NiceCreature
        }
        
        let survivedConservativeCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is ConservativeCreature
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

        let survivedSelfishMeanCreature = AllCreatures.filter { (Creature) -> Bool in
            return Creature is SelfishMeanCreature
        }

        SeasonStatistic.Total = AllCreatures.count
        SeasonStatistic.Died = DiedCreatures.count
        SeasonStatistic.Nice = survivedNiceCreature.count
        SeasonStatistic.Conservative = survivedConservativeCreature.count
        SeasonStatistic.OpenBad = survivedOpenBadCreature.count
        SeasonStatistic.ConservativeBad = survivedConservativeBadCreature.count
        SeasonStatistic.StrategyBad = survivedStrategyBadCreature.count
        SeasonStatistic.Mean = survivedMeanCreature.count
        SeasonStatistic.SelfishMean = survivedSelfishMeanCreature.count

        print ("round:",season,
               "\t cooperate:",SeasonStatistic.Cooperate,
               "\t cheat:",SeasonStatistic.Cheat,
               "\t failure:",SeasonStatistic.Failure,
               "\t NewBorn:",SeasonStatistic.NewBorn,
               "\t died:",SeasonStatistic.Died);
        
        print ("All creatures:",SeasonStatistic.Total,
               "History died creatures:",SeasonStatistic.Died,
               "\t NiceCreature:",SeasonStatistic.Nice,
               "\t ConservativeCreature:",SeasonStatistic.Conservative,
               "\t OpenBadCreature:",SeasonStatistic.OpenBad,
               "\t ConservativeBadCreature:",SeasonStatistic.ConservativeBad,
               "\t StrategyBadCreature:",SeasonStatistic.StrategyBad,
               "\t MeanCreature:",SeasonStatistic.Mean,
               "\t SelfishMeanCreature:",SeasonStatistic.SelfishMean
               )
        
        print ("group resource:", creatureResources.reduce(0, +), "average resource:",creatureResources.average)
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
    func findCreature(By Name:String) -> Creature? {
        return self.first(where:{ (FindCreature) -> Bool in
            return (FindCreature.identifier.familyName+FindCreature.identifier.givenName == Name)
        })
    }

}

