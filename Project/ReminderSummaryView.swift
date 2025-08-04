//
//  ReminderSummaryView.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import SwiftUI

struct ReminderSummaryView: View {
    @ObservedObject var viewModel: ReminderSummaryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 3)  {
            // summary
            Text(viewModel.reminder.summary)
                .font(.headline)
                .padding(.bottom, 2)
                .foregroundStyle(viewModel.reminder.isDone ? Color.secondary : Color.primary)
                .strikethrough(viewModel.reminder.isDone)
                .fixedSize(horizontal: false, vertical: true)
            
            // notes
            Text(viewModel.reminder.notes)
                .font(.caption)
                .lineLimit(2)
                .foregroundStyle(viewModel.reminder.isDone ? Color.secondary : Color.primary)
                .padding(.bottom, 2)
                .fixedSize(horizontal: false, vertical: true)
            
            // date
            Text(DateConvert.dateToString(date: viewModel.reminder.updatedAt))
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }        
    }
}

#if DEBUG

var previewList: some View {
    let context = DataController.shared.container.viewContext
    let sampleReminder1 = Reminder.sample1(in: context)
    let sampleReminder2 = Reminder.sample2(in: context)

    return List {
        ReminderSummaryView(viewModel: ReminderSummaryViewModel( reminder: sampleReminder1))
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(.secondary)

        ReminderSummaryView(viewModel: ReminderSummaryViewModel( reminder: sampleReminder2))
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(.secondary)
    }
    .environment(\.managedObjectContext, context)
}

#Preview("Dark Mode") {
    previewList
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    previewList
        .preferredColorScheme(.light)
}

#endif
