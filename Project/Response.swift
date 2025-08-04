//
//  Response.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import Foundation

struct Response: Codable {
    var todos =  [Todos()]
    var total: Int = 0
    var skip: Int = 0
    var limit: Int = 0
}

struct Todos: Codable {
    var id: Int = 0
    var todo: String = ""
    var completed: Bool = false
    var userId: Int = 0
}
