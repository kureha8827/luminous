//
//  GenericParts.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/16.
//

import SwiftUI

struct TitleView: View {
    var scale: CGFloat = 1
    var body: some View {
        HStack {
            Text("LUMIN").offset(x: 10)
            Image(systemName: "scope").font(.system(size: 36 * scale))
            Text("US").offset(x: -7)
        }
        .font(.system(size: 40 * scale))
            .italic()
            .foregroundColor(.purple2)
            .tracking(6)
    }
}

struct OpacityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(1)
    }
}

extension UIImage {
    convenience init?(path: URL) {
        guard let data = try? Data(contentsOf: path) else { return nil }
        self.init(data: data)
    }
}

#Preview {
    TitleView()
}
