//
//  AsyncQueue.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 06.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


/// Queue data structure implements queue methods and can be used in different threads
struct AsyncQueue<T> {
    private let queue = DispatchQueue(label: "queue.operations", attributes: .concurrent)
    private var elements: [T] = []
    
    mutating func enqueue(_ value: T) {
        queue.sync(flags: .barrier) {
            self.elements.append(value)
        }
    }
    
    mutating func dequeue() -> T? {
        return queue.sync(flags: .barrier) {
            guard !self.elements.isEmpty else {
                return nil
            }
            return self.elements.removeFirst()
        }
    }
    
    mutating func clear() {
        queue.sync(flags: .barrier) {
            self.elements = []
        }
    }
    
    var head: T? {
        return queue.sync {
            return elements.first
        }
    }
    
    var tail: T? {
        return queue.sync {
            return elements.last
        }
    }
    
    var length: Int {
        return queue.sync {
            return elements.count
        }
    }
    
    var isEmpty: Bool {
        return queue.sync(flags: .barrier) {
            return elements.isEmpty
        }
    }
    
    var getElements: [T] {
        return queue.sync {
            return elements
        }
    }
}
