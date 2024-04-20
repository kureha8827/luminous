//
//  EditView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/25.
//

import SwiftUI

struct EditView: View {
    var body: some View {
        VStack {
            Text("EditView")
                .onAppear() {
                    let _ = print("EditView")
                }
            ZStack {
                Circle()
                    .frame(width: 64)
                    .foregroundStyle(.purple2)
                Circle()
                    .frame(width: 58)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
    }
}

#Preview {
    EditView()
}
