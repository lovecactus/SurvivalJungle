//
//  SocialBehavior.swift
//  Survive
//
//  Created by YANGWEI on 06/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import Foundation

enum WorkAttitude:String{
    case helpOther
    case selfish
    case none
}

struct WorkAction{
    var Worker:Creature
    var WorkingPartner:Creature? // Ceature may work alone, without a partner
    var WorkingAttitude:WorkAttitude
}

struct WorkCooperation{
    var RequestWorkAction:WorkAction
    var ResponseWorkAction:WorkAction?
}

struct WorkCooperationResult{
    let HarvestResource:Double
    var RequestResult:WorkResult
    var ResponseResult:WorkResult?
}

enum WorkResult:String{
    case doubleWin
    case exploitation
    case beenCheated
    case doubleLose
    case stayAlone
}

class SocialBehavior {
    static let workingCost:Double = 2

    init() {
    }
    
    func Work(As Cooperation:WorkCooperation, AverageResource:Double) -> WorkCooperationResult{
        let RequestWorkAction = Cooperation.RequestWorkAction
        let RequestResult:WorkResult
        let ResponseResult:WorkResult?
        
        if let ResponseWorkAction = Cooperation.ResponseWorkAction {
            if RequestWorkAction.WorkingAttitude == .helpOther && ResponseWorkAction.WorkingAttitude == .helpOther {
                RequestResult = .doubleWin
                ResponseResult = .doubleWin
            }else if RequestWorkAction.WorkingAttitude == .helpOther && ResponseWorkAction.WorkingAttitude == .selfish {
                RequestResult = .beenCheated
                ResponseResult = .exploitation
            }else if RequestWorkAction.WorkingAttitude == .selfish && ResponseWorkAction.WorkingAttitude == .helpOther {
                RequestResult = .exploitation
                ResponseResult = .beenCheated
            }else if RequestWorkAction.WorkingAttitude == .selfish && ResponseWorkAction.WorkingAttitude == .selfish {
                RequestResult = .doubleLose
                ResponseResult = .doubleLose
            }else {
                //Work alone
                RequestResult = .stayAlone
                ResponseResult = nil
            }
        }else{
            //Work alone
            RequestResult = .stayAlone
            ResponseResult = nil
        }
        
        return WorkCooperationResult(HarvestResource:AverageResource, RequestResult: RequestResult, ResponseResult: ResponseResult)
    }

    
    public static func WorkReword(of workresult: WorkResult, harvestResource: Double) -> Double{
        var rewardResource:Double
        switch workresult {
        case .doubleWin:
            rewardResource = harvestResource
        case .exploitation:
            rewardResource = harvestResource*1.8
        case .beenCheated:
            rewardResource = -harvestResource*0.5
        case .doubleLose:
            rewardResource = -harvestResource*0
        case .stayAlone:
            rewardResource = harvestResource*0.2
        }
        rewardResource -= workingCost
        return rewardResource
    }
}
