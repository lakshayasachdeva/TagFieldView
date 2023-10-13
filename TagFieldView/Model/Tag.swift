//
//  Tag.swift
//  TagFieldView
//
//  Created by Lakshaya Sachdeva on 13/10/23.
//

import Foundation

struct Tag: Identifiable, Hashable {
    var id: UUID = .init()
    var value: String
    var isInitial = false
}
