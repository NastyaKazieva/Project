//
//  DateConvert.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import Foundation

enum DateConvert {
    private static let formatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "dd/MM/yy"
           return formatter
       }()
    
    static func dateToString(date: Date?) -> String {
        if let date = date {
            return formatter.string(from: date)
        }
        return ""
    }
}
