//
//  ReminderView.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import SwiftUI

struct ReminderView: View {
    @ObservedObject var viewModel: ReminderViewModel
    
    var body: some View {
        VStack {
            ReminderDetailView(reminder: viewModel.reminder)
            .toolbar {
                ToolbarItem (placement: .topBarLeading) {
                    Button {
                        withAnimation{
                            viewModel.env.save()
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.yellow)
                        Text("Назад")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG

private func previewContent() -> some View {
    let context = DataController.shared.container.viewContext
    let reminder = Reminder.sample1(in: context)
    return  NavigationStack {
        ReminderView(viewModel: ReminderViewModel(reminder: reminder, env: .init(save: {
            print("changes")
        })
        )
        )
    }

}

#Preview("Dark Mode") {
    previewContent()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    previewContent()
        .preferredColorScheme(.light)
}

#endif
