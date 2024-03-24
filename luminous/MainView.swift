//
//  ContentView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTag = 1
    @State private var tabItemAnimation: CGFloat = UIScreen.main.bounds.width/2 - 94 /*UIScreen.main.bounds.width/2 - 36/2 - (36 + 40)*/
    let itemWidth: CGFloat = 36
    let itemPadding: CGFloat = 40
    let displayWidth: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTag) {
                EditView()
                    .tag(MainTabBar.edit.rawValue)
                
                PhotoView()
                    .tag(MainTabBar.photo.rawValue)
            }

            GeometryReader { geometry in
                HStack(spacing: itemPadding) {
                    ForEach(MainTabBar.allCases, id: \.self) { item in
                        Button {
                            selectedTag = item.rawValue
                            withAnimation(Animation.easeOut(duration: 0.3)) {
                                tabItemAnimation = tabItemArrangement(CGFloat(selectedTag))
                            }
                        } label: {
                            tabItemView(
                                tabBarItem: item,
                                isActive: selectedTag == item.rawValue
                            )
                        }
                        .buttonStyle(TapButtonStyle(isAct: selectedTag == item.rawValue))
                    }
                    .offset(x: tabItemAnimation)
                }
            }.frame(height: 40)
        }
        .background(.white)
        .frame(maxHeight: .infinity)
    }
    
    enum MainTabBar: Int, CaseIterable {    // .rawValueを使った際に0,1,2...と返してもらう為
        case edit
        case photo
        
        var iconName: String {
            switch self {
            case .edit:
                return "slider.horizontal.3"
            case .photo:
                return "camera"
            }
        }
    }
    
    func tabItemArrangement(_ selection: CGFloat) -> CGFloat {
        return displayWidth/2 - itemWidth/2 - (itemWidth + itemPadding)*selection
    }
    
    @ViewBuilder
    func tabItemView(tabBarItem: MainTabBar, isActive: Bool) -> some View {
        Image(systemName: tabBarItem.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: itemWidth)
            .tint(isActive ? .purple2 : .gray)
    }
    
    struct TapButtonStyle: ButtonStyle {
        var isAct: Bool
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isAct ? .purple2 : .gray)
        }
    }
}

struct PhotoView: View {
    @State private var isCameraBack: Bool = true   // 初期状態は背面カメラ
    var body: some View {
        NavigationStack {
            VStack {
                CameraView(isCameraBack: $isCameraBack)
                    .frame(width: 360, height: 640)
                    .background(.white)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            isCameraBack.toggle()
                        },
                        label: {
                            Label("", systemImage: "arrow.triangle.2.circlepath")
                        }
                    ).tint(.black.opacity(0.7))
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct EditView: View {
    var body: some View {
        Text("EditView")
            .onAppear() {
                let _ = print("EditView")
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
