//
//  Species.swift
//  Survival
//
//  Created by YANGWEI on 14/12/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

class GenericSpecies : Creature {
    convenience init(familyName:String, givenName:String, methodology:Methodology, age:Int) {
        self.init(familyName: familyName, givenName: givenName, age:age)
        self.method = methodology
    }

    convenience init(familyName:String, givenName:String, methodology:Methodology) {
        self.init(familyName: familyName, givenName: givenName)
        self.method = methodology
    }

    required init(familyName:String, givenName:String) {
        super.init(familyName: familyName, givenName: givenName)
    }

}




