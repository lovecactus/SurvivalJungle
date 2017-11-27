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
    var jungleTotalResource:RewardResource
    var seasonNumber:Int
    var creatureNumber:Int
    
    var surviveChallenge:Challenge = Challenge()
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
            allCreatures.append(OpenBadCreature(familyName: "OpenBad", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...creatureNumber {
            allCreatures.append(ConservativeBadCreature(familyName: "ConservativeBad", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
//        for index in 1...CreatureNumber {
//            AllCreatures.append(StrategyBadCreature(familyName: "StrategyBad", givenName: String(index), age:Int(arc4random_uniform(50))))
//        }
        for index in 1...creatureNumber {
            allCreatures.append(ConservativeCreature(familyName: "Conservative", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...creatureNumber {
            allCreatures.append(NiceCreature(familyName: "Nice", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...creatureNumber {
            allCreatures.append(MeanCreature(familyName: "Mean", givenName: String(index), age:Int(arc4random_uniform(50))))
        }
        for index in 1...creatureNumber {
            allCreatures.append(SelfishMeanCreature(familyName: "SelfishMean", givenName: String(index), age:Int(arc4random_uniform(50))))
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
        let social = SocialBehavior(with: &allCreatures, seasonResource: &jungleTotalResource)

        var AverageResource:Double = Double(Double(jungleTotalResource)/Double(allCreatures.count))/10
        AverageResource = (AverageResource > 10) ? 10 : AverageResource

        let MatchedWorkCooperations = WorkMatchCooperations(AllCreatures: allCreatures)

        for Cooperation in MatchedWorkCooperations {
            let CooperationResult = social.Work(As: Cooperation, AverageResource:AverageResource)
            
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
    

    func CreturesSurvival() {
        var FailedCreature:[Creature] = []
        allCreatures = allCreatures.filter({ (ChallengingCreature:Creature) -> Bool in
            if ChallengingCreature.surviveChallenge() {
                return true
            }
            FailedCreature.append(ChallengingCreature)
            return false
        })
        
        diedCreatures.append(contentsOf: FailedCreature)
    }

    func CreturesAging() {
        allCreatures.forEach { (Creature) in
            Creature.aging()
        }
    }

    func CreturesReproduction(_ SeasonStatistic:inout SurvivalStatistic) {
        var NewBornCreatures:[Creature] = []
        
        allCreatures.forEach { (Creature) in
            if let NewBornCreature = Creature.selfReproduction(){
                NewBornCreatures.append(NewBornCreature)
                SeasonStatistic.NewBorn += 1
            }
        }
        
        allCreatures.append(contentsOf: NewBornCreatures)
    }

    func SurviveStart() -> [SurvivalStatistic]{
        //Check if a creature is about to die or reproduction
        for season in 1...seasonNumber{
            var SeasonStatistic = SurvivalStatistic()
            self.Working(&SeasonStatistic)
            self.CreturesReproduction(&SeasonStatistic)
            self.CreturesSurvival()
            self.CreturesAging()
            self.SurviveCreaturesStatistic(season,SeasonStatistic:&SeasonStatistic)
            statistic.append(SeasonStatistic)
        }
        return statistic
    }
    
    func SurviveCreaturesStatistic(_ season:Int, SeasonStatistic:inout SurvivalStatistic){
        let creatureResources:[Double] = allCreatures.map { (Creature) -> Double in
            return Creature.SurviveResource
        }
        
        let survivedNiceCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is NiceCreature
        }
        
        let survivedConservativeCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is ConservativeCreature
        }
        
        let survivedOpenBadCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is OpenBadCreature
        }

        let survivedStrategyBadCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is StrategyBadCreature
        }

        let survivedConservativeBadCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is ConservativeBadCreature
        }
        
        let survivedMeanCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is MeanCreature
        }

        let survivedSelfishMeanCreature = allCreatures.filter { (Creature) -> Bool in
            return Creature is SelfishMeanCreature
        }

        SeasonStatistic.Total = allCreatures.count
        SeasonStatistic.Died = diedCreatures.count
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
    
    func SandboxStart(){
        allCreatures = []
        for index in 1...creatureNumber {
            allCreatures.append(Creature(familyName: "Test", givenName: String(index), age: Int(arc4random_uniform(50))))
        }
        
        for _ in 1...seasonNumber{
            var SeasonStatistic = SurvivalStatistic()
            var seasonResource = jungleTotalResource
            let social = SocialBehavior(with: &allCreatures, seasonResource:&seasonResource)
            social.TeamWork()
            self.CreturesReproduction(&SeasonStatistic)
            self.CreturesSurvival()
            self.CreturesAging()
            statistic.append(SeasonStatistic)
        }
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

