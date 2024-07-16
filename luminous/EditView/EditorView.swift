//
//  EditorView.swift
//  luminous
//
//  Created by kureha8827 on 2024/07/03.
//

import SwiftUI
import AudioToolbox

struct EditorView: View {
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var editor: Editor
    @EnvironmentObject var main: MainObserver
    @State private var rotation = Angle.zero
    @State private var lastRotation: Int = 0
    @State private var selectedTag: Int = 1     // 0, 1, 2
    @State private var isDownloaded: Bool = false

    var body: some View {
        let UISFGenerator = UISelectionFeedbackGenerator()

        let swipeGesture = DragGesture()
            .onChanged { gesture in
                let value = Int(gesture.translation.width) + lastRotation
                if -108 < value && value < 108 {
                    rotation = Angle(radians: CGFloat(value) / 180 * CGFloat.pi)
                    switch value {
                    case -72, 0, 72: UISFGenerator.selectionChanged()
                    default: return
                    }
                } else if value <= -108 {
                    rotation = Angle(radians: CGFloat.pi * -0.6)
                } else if 108 <= value {
                    rotation = Angle(radians: CGFloat.pi * 0.6)
                }
            }
            .onEnded { gesture in
                // rotationを3つの数値に分類
                if rotation <= Angle(radians: CGFloat.pi * -0.2) {
                    // 調整選択中
                    rotation = Angle(radians: CGFloat.pi * -0.4)
                    lastRotation = -72
                    selectedTag = 2
                } else if Angle(radians: CGFloat.pi * -0.2) <= rotation && rotation <= Angle(radians: CGFloat.pi * 0.2) {
                    // フィルタ選択中
                    rotation = Angle.zero
                    lastRotation = 0
                    selectedTag = 1
                } else if Angle(radians: CGFloat.pi * 0.2) <= rotation {
                    // 顔補正選択中
                    rotation = Angle(radians: CGFloat.pi * 0.4)
                    lastRotation = 72
                    selectedTag = 0
                }
            }

        ZStack {
            VStack {
                Image(uiImage: editor.uiImage ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: DisplayInfo.height - 300)

                Spacer()

                if selectedTag == 0 {

                } else if selectedTag == 1 {
                    // フィルタView
                    GeometryReader { geometry in
                        EditorFilterView()
                            .frame(height: 144)
                            .offset(y: selectedTag == 1 ? geometry.frame(in: .local).maxY - 144 : geometry.frame(in: .local).maxY)
                            .zIndex(2)
                    }
                } else if selectedTag == 2 {
                    // 調整View
                    GeometryReader { geometry in
                        EditorAdjusterView()
                            .frame(height: 144)
                            .offset(y: selectedTag == 2 ? geometry.frame(in: .local).maxY - 144 : geometry.frame(in: .local).maxY)
                            .zIndex(2)
                    }
                }

                ZStack {
                    Button() {
                        rotation = Angle(radians: CGFloat.pi * 0.4)
                        lastRotation = 72
                        selectedTag = 0
                    } label: {
                        Text("Kawaii")
                    }
                    .offset(y: -(DisplayInfo.height)/2)
                    .rotationEffect(.radians(-CGFloat.pi * 0.05))

                    Button() {
                        rotation = Angle.zero
                        lastRotation = 0
                        selectedTag = 1
                    } label: {
                        Text("Filter")
                    }
                    .offset(y: -(DisplayInfo.height)/2)

                    Button() {
                        rotation = Angle(radians: CGFloat.pi * -0.4)
                        lastRotation = -72
                        selectedTag = 2
                    } label: {
                        Text("Adjuster")
                    }
                    .offset(y: -(DisplayInfo.height)/2)
                    .rotationEffect(.radians(CGFloat.pi * 0.05))
                }
                .foregroundStyle(.gray63)
                .font(.system(size: 16, weight: .thin))
                .lineSpacing(1)
                .rotationEffect(rotation/8)
                .highPriorityGesture(swipeGesture)
                .offset(y: DisplayInfo.height / 2 - 40)
            }

            DownloadStatusView(isDownloaded: $isDownloaded)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .tint(.gray63)
                    }
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    // TODO: 保存したときの動作
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDownloaded = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDownloaded = false
                        }
                        editor.download()
                    }
                } label: {
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.system(size: 20))
                        .tint(.gray63)
                        .padding(.bottom, 4)
                }
            }
        }
        .animation(
            .easeOut(duration: 0.2),
            value: selectedTag
        )
        .animation(
            .easeInOut(duration: 0.2),
            value: rotation
        )
        .onAppear() {
            main.isShowTabBar = false
            editor.isEditing = true
        }
        .onDisappear() {
            main.isShowTabBar = true
            editor.isEditing = false
        }
    }
}


struct DownloadStatusView: View {
    @Binding var isDownloaded: Bool
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.gray)
                .opacity(0.5)
            Circle()
                .stroke(.white, lineWidth: 1)
            VStack {
                Image(systemName: "checkmark")
                    .tint(.white)
                    .font(.system(size: 30))
                Text("保存完了")
                    .font(.system(size: 18))
            }
        }
        .frame(width: 100, height: 100)
        .opacity(isDownloaded ? 1 : 0)
    }
}
