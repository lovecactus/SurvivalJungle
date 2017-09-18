//
//  SurviveTests.swift
//  SurviveTests
//
//  Created by YANGWEI on 05/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import XCTest
@testable import Survive

class SurviveTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        /*
        var AllCreatures:[Creature] = []
        var AllCreaturesDict:[String:Creature] = [:]
        for index in 1...20000 {
            let NewBorn = Creature(creatureIdentifier: String(index))
            AllCreatures.append(NewBorn)
            AllCreaturesDict[String(index)] = NewBorn
        }

        self.measure {
            for _ in 1...AllCreatures.count {
                _ = AllCreatures[0]
//                _ = AllCreaturesDict[String(1999)]
            }
        }
        */
        
         let NewJungle = SurvivalJungle()
         self.measure {
            NewJungle.CleanUpStatstic()
            NewJungle.Working()
            NewJungle.Thinking()
            NewJungle.SurviveCreaturesStatistic(1)
         }

        /*
        var AllNumbersArray:[Int] = []
        AllNumbersArray.reserveCapacity(20)
        for index in 1...20 {
            AllNumbersArray.append(index)
        }
 
        self.measure {
            for _ in 1...AllNumbersArray.count {
                _ = AllNumbersArray[0]
            }
        }
         */
        
    }

    
}
