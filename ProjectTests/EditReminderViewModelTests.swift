//
//  EditReminderViewModelTests.swift
//  ProjectTests
//
//  Created by Nastya Shlepakova on 04/08/2025.
//

import XCTest
import CoreData
@testable import Project

final class EditReminderViewModelTests: XCTestCase {
    
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = setUpInMemoryManagedObjectContext()
    }

    override func tearDown() {
        context = nil
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

    func testSaveNewReminder() {
        var didSave = false
        var didCancel = false
        let env = EditReminderViewModel.Environment(
            save: { didSave = true },
            cancel: { didCancel = true }
        )
        let viewModel = EditReminderViewModel(reminder: nil, env: env, context: context)
        
        viewModel.draft.summary = "Test Summary"
        viewModel.draft.notes = "Test Notes"
        
        XCTAssertNoThrow(try viewModel.save())
        XCTAssertTrue(didSave)
        XCTAssertFalse(didCancel)
        
        let request = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "summary == %@", "Test Summary")
        
        do {
            let results = try context.fetch(request)
            XCTAssertEqual(results.count, 1)
            let savedReminder = results.first
            XCTAssertEqual(savedReminder?.summary, "Test Summary")
            XCTAssertEqual(savedReminder?.notes, "Test Notes")
        } catch {
            XCTFail("Failed to fetch reminder: \(error)")
        }
    }

    func testSaveExistingReminder() {
        let reminder = Reminder(context: context)
        reminder.id = UUID()
        reminder.summary = "Initial Summary"
        reminder.notes = "Initial Notes"
        reminder.reminderStatus = .notReady
        try! context.save()

        var didSave = false
        var didCancel = false
        let env = EditReminderViewModel.Environment(
            save: { didSave = true },
            cancel: { didCancel = true }
        )
        let viewModel = EditReminderViewModel(reminder: reminder, env: env, context: context)
        
        viewModel.draft.summary = "Updated Summary"
        viewModel.draft.notes = "Updated Notes"
        
        XCTAssertNoThrow(try viewModel.save())
        XCTAssertTrue(didSave)
        XCTAssertFalse(didCancel)
        
        XCTAssertEqual(reminder.summary, "Updated Summary")
        XCTAssertEqual(reminder.notes, "Updated Notes")
    }

    func testSaveWithEmptySummary() {
        var didSave = false
        var didCancel = false
        let env = EditReminderViewModel.Environment(
            save: { didSave = true },
            cancel: { didCancel = true }
        )
        let viewModel = EditReminderViewModel(reminder: nil, env: env, context: context)
        
        viewModel.draft.summary = ""
        
        XCTAssertThrowsError(try viewModel.save()) { error in
            XCTAssertEqual(error as? SaveError, .invalid("Summary cannot be empty."))
        }
        
        XCTAssertFalse(didSave)
        XCTAssertFalse(didCancel)
    }
    
    func testCancel() {
        var didSave = false
        var didCancel = false
        let env = EditReminderViewModel.Environment(
            save: { didSave = true },
            cancel: { didCancel = true }
        )
        let viewModel = EditReminderViewModel(reminder: nil, env: env, context: context)
        
        viewModel.cancel()
        
        XCTAssertFalse(didSave)
        XCTAssertTrue(didCancel)
    }
}
