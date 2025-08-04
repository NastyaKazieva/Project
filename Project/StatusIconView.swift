//
//  StatusIconView.swift
//  Project
//
//  Created by Nastya Shlepakova on 04/08/2025.
//

import SwiftUI

struct StatusIconView: View {
    let completed: Bool
    
    var body: some View {
        Image(systemName: completed ?  "checkmark.circle" : "circle")
            .resizable()
            .font(.system(size: 16, weight: .thin))
            .scaledToFit()
            .frame(width: 25, height: 25)
            .foregroundColor(completed ? .yellow : .gray)
    }
}

#Preview("Done") {
    StatusIconView(completed: true)
}

#Preview("Not ready") {
    StatusIconView(completed: false)
}
