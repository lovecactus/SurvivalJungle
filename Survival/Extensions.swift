//
//  Extensions.swift
//  Survive
//
//  Created by YANGWEI on 07/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import Foundation

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Collection where Iterator.Element == Double, Index == Int {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(reduce(0, +)) / Double(endIndex-startIndex)
    }
    
}

extension Array {
    func randomPick() -> Element? {
        guard !isEmpty else {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    func randomPick(some PickNumber:Int) -> [Element]? {
        guard !isEmpty, PickNumber > 0 else {
            return nil
        }
        
        let randomPickNumber = (PickNumber<count) ? PickNumber : count
        return Array(self.shuffled()[0..<randomPickNumber])
    }
}

extension Dictionary where Value:Creature {
    func randomPick() -> Value? {
        guard !isEmpty else {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[Array(self.keys)[index]]
    }
    
    func randomPick(some PickNumber:Int) -> [Value] {
        guard !isEmpty, PickNumber > 0 else {
            return []
        }
        
        let randomPickNumber = (PickNumber<count) ? PickNumber : count
        return Array(self.keys).shuffled()[0..<randomPickNumber].flatMap({self[$0]})
    }
    
//    func randomPick(some PickNumber:Int) -> [Value] {
//        guard !isEmpty, PickNumber > 0 else {
//            return []
//        }
//
//        let randomPickNumber = (PickNumber<count) ? PickNumber : count
//        var randomKeys:[Key] = []
//        var randomIndexs:[Int] = Array(0..<count)
//        let allKeys = Array(self.keys)
//        for _ in 1...randomPickNumber {
//            let randomIndex = Int(arc4random_uniform(UInt32(randomIndexs.count)))
//            let randomKeyIndex = randomIndexs[randomIndex]
//            randomKeys.append(allKeys[randomKeyIndex])
//            randomIndexs.remove(at: randomIndex)
//        }
//
//        return randomKeys.flatMap({self[$0]})
//
//    }
//
//    func randomPick(some PickNumber:Int) -> [Value] {
//        guard !isEmpty, PickNumber > 0 else {
//            return []
//        }
//
//        let randomPickNumber = (PickNumber<count) ? PickNumber : count
//        var randomKeyIndex = Int(arc4random_uniform(UInt32(count)))
//        let randomIncreaseRange = count/randomPickNumber
//        var randomKeys:[Key] = []
//        for _ in 1...randomPickNumber {
//            let keyIndex = self.keys[index(startIndex, offsetBy: randomKeyIndex)]
//            randomKeys.append(keyIndex)
//
//            randomKeyIndex += Int(arc4random_uniform(UInt32(randomIncreaseRange-1)))+1
//            randomKeyIndex = (randomKeyIndex >= count) ? randomKeyIndex-count : randomKeyIndex
//        }
//        return randomKeys.flatMap({self[$0]})
//
//    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

protocol OptionalType {
    associatedtype Wrapped
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
}

extension Optional: OptionalType {}

extension Sequence where Iterator.Element: OptionalType {
    func removeNils() -> [Iterator.Element.Wrapped] {
        var result: [Iterator.Element.Wrapped] = []
        for element in self {
            if let element = element.map({ $0 }) {
                result.append(element)
            }
        }
        return result
    }
}

extension Array where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

extension Array where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}

extension Array where Element: FloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

protocol Loopable {
    func allProperties() throws -> [String: Any]
}

extension Loopable {
    func allProperties() throws -> [String: Any] {
        
        var result: [String: Any] = [:]
        
        let mirror = Mirror(reflecting: self)
        
        // Optional check to make sure we're iterating over a struct or class
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
        }
        
        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }
            
            result[property] = value
        }
        
        return result
    }
}

