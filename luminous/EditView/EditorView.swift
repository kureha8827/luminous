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
    @State private var selectedTag: Int = 1     // 0, 1, 2
    @State private var isDownloaded: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            // ツールバー
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .tint(.gray63)
                }


                Spacer()
                
                Text("\(editor.uiImageNode)")
                
                Spacer()

                Button {
                    // TODO: 保存したときの動作
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDownloaded = true
                    }
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDownloaded = false
                        }
                        editor.download()
                    }
                } label: {
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.system(size: 24))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .tint(.gray63)
                }
            }
            .disabled(isDownloaded) // DL中は無効化

            // 編集する画像
            ZStack {
                Image(uiImage: editor.uiImage[editor.uiImageNode] ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: DisplayInfo.height / 3 * 2)
                DownloadStatusView(isDownloaded: $isDownloaded)
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .onTapGesture {
                editor.currentBeauty[0] = -1
            }

            // 編集メニュー
            if selectedTag == 0 {
                // 顔補正View
                EditorBeautyView()
            } else if selectedTag == 1 {
                // フィルタView
                EditorFilterView()
            } else if selectedTag == 2 {
                // 調整View
                // TODO: キーボードから入力するときの表示を変える
                // 具体的にはoffsetでキーボードの上にViewが来るようにする
                EditorAdjusterView()
            }

            // 編集タイプの選択
            EditTypeSelectView(rotation: $rotation, selectedTag: $selectedTag)
                .offset(y: editor.currentBeauty[0] == -1 ? -20 : 124)
                .animation(
                    .easeOut(duration: 0.2),
                    value: editor.currentBeauty[0]
                )
        }
        .frame(maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .animation(
            .easeOut(duration: 0.2),
            value: selectedTag
        )
        .animation(
            .easeInOut(duration: 0.2),
            value: rotation
        )
        .onAppear() {
            // besutyでのface, skin, makeupの選択状態を解除(->下の円弧状のタブが表示される)
            editor.currentBeauty[0] = -1
        }
        .onDisappear() {
            withAnimation(Animation.easeOut(duration: 0.2)) {
                main.isShowTabBar = true
            }
            editor.isEditing = false
            editor.filterSize = Array(repeating: 0, count: ConstStruct.filterNum)
            editor.adjusterSize = Array(repeating: 0, count: ConstStruct.adjusterNum)
            editor.uiImageNode = 0
            editor.uiImage = []
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


    struct EditTypeSelectView: View {
        @Binding var rotation: Angle
        @Binding var selectedTag: Int
        @State private var lastRotation: Int = 0
        var body: some View {
            let vibration = UISelectionFeedbackGenerator()

            let swipeGesture = DragGesture()
                .onChanged { gesture in
                    let value = Int(gesture.translation.width) + lastRotation
                    if -108 < value && value < 108 {
                        rotation = Angle(radians: CGFloat(value) / 180 * CGFloat.pi)
                        switch value {
                        case -72, 0, 72: vibration.selectionChanged()
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
                Button {
                    rotation = Angle(radians: CGFloat.pi * 0.4)
                    lastRotation = 72
                    selectedTag = 0
                } label: {
                    Text("Kawaii")
                }
                .offset(y: -(DisplayInfo.height)/2)
                .rotationEffect(.radians(-CGFloat.pi * 0.05))

                Button {
                    rotation = Angle.zero
                    lastRotation = 0
                    selectedTag = 1
                } label: {
                    Text("Filter")
                }
                .offset(y: -(DisplayInfo.height)/2)

                Button {
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
            .offset(y: DisplayInfo.height / 2)
        }
    }
}


