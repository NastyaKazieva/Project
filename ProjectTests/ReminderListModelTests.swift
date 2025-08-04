//
//  ReminderListModelTests.swift
//  ProjectTests
//
//  Created by Nastya Shlepakova on 04/08/2025.
//

import XCTest
import CoreData
@testable import Project

final class ReminderListModelTests: XCTestCase {

    var context: NSManagedObjectContext!
    var reminder1: Reminder!
    var reminder2: Reminder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = setUpInMemoryManagedObjectContext()

        reminder1 = Reminder(context: context)
        reminder1.id = UUID()
        reminder1.summary = "First Reminder"
        reminder1.notes = "Some notes"
        reminder1.updatedAt = Date()
        reminder1.reminderStatus = .notReady

        reminder2 = Reminder(context: context)
        reminder2.id = UUID()
        reminder2.summary = "Second Task"
        reminder2.notes = "More notes"
        reminder2.updatedAt = Date()
        reminder2.reminderStatus = .done
        
        try context.save()
    }

    override func tearDown() {
        context = nil
        reminder1 = nil
        reminder2 = nil
        super.tearDown()
    }

    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            fatalError("Failed to set up in-memory store: \(error)")
        }

        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }

    func testInitializationWithReminders() {
        let model = ReminderListModel(reminders: [reminder1, reminder2], context: context)
        XCTAssertEqual(model.allReminders.count, 2)
        XCTAssertEqual(model.filteredReminders.count, 2)
    }

    @MainActor
    func testSearchTextFiltering() {
        let model = ReminderListModel(reminders: [reminder1, reminder2], context: context)
        
        model.searchText = "First"
        XCTAssertEqual(model.filteredReminders.count, 1)
        XCTAssertEqual(model.filteredReminders.first?.summary, "First Reminder")

        model.searchText = "Task"
        XCTAssertEqual(model.filteredReminders.count, 1)
        XCTAssertEqual(model.filteredReminders.first?.summary, "Second Task")

        model.searchText = "Reminder"
        XCTAssertEqual(model.filteredReminders.count, 1)
        
        model.searchText = ""
        XCTAssertEqual(model.filteredReminders.count, 2)
    }

     func testCompletedChange() {
         let model = ReminderListModel(reminders: [reminder1], context: context)
        let initialStatus = reminder1.reminderStatus
        
        model.completedChange(reminder: reminder1)
        
        let expectation = XCTestExpectation(description: "Wait for context to save")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotEqual(self.reminder1.reminderStatus, initialStatus)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

     func testDeleteItem() {
         let model = ReminderListModel(context: context)
        
        let expectation = XCTestExpectation(description: "Wait for initial data load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(model.allReminders.count, 2)
        let initialCount = model.allReminders.count
        
        let idToDelete = model.allReminders[0].objectID
        model.deleteItem(by: idToDelete)
        
        let deleteExpectation = XCTestExpectation(description: "Wait for item deletion and refetch")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            deleteExpectation.fulfill()
        }
        wait(for: [deleteExpectation], timeout: 1.0)

        XCTAssertEqual(model.allReminders.count, initialCount - 1)
    }

    func testNavigationPath() {
        let model = ReminderListModel(reminders: [reminder1], context: context)
        
        model.selectShow(reminder: reminder1)
        XCTAssertEqual(model.path.count, 1)
        
        model.selectEdit(reminder: reminder1)
        XCTAssertEqual(model.path.count, 2)
        
        model.clearSelection()
        XCTAssertEqual(model.path.count, 1)
    }
}
