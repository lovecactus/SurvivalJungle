//
//  PairWorkSocial.swift
//  Survival
//
//  Created by YANGWEI on 27/11/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

let pairWorkBaseCost:WorkingCostResource = 1

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
