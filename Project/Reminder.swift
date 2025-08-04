//
//  Reminder.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//


import Foundation
import CoreData

@objc(Reminder)
public class Reminder: NSManagedObject {}

extension Reminder: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }
    @NSManaged public var id: UUID
    @NSManaged public var summary: String
    @NSManaged public var notes: String
    @NSManaged public var status: String
    @NSManaged public var updatedAt: Date
    
    enum Status: String {
        case done, notReady
    }
    
    func update(summary: String, notes: String, status: Status) {
        self.summary = summary
        self.notes = notes
        self.reminderStatus = status
        self.updatedAt = Date()
    }
    
    var reminderStatus: Status {
        get {
            Status(rawValue: status) ?? .notReady
        }
        set {
            status = newValue.rawValue
        }
    }

    var isDone: Bool {
        reminderStatus == .done
    }
    
    func toggleReminderStatus() {
        switch reminderStatus {
        case .done: reminderStatus = .notReady
        case .notReady: reminderStatus = .done
        }
    }
}


