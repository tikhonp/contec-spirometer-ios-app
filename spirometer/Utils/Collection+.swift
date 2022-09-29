//
//  Collection+.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 29.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
