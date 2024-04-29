//
//  ContentView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//
import SwiftUI

struct MainView: View {
    @State private var selectedTag = 1
    @State private var tabItemAnimation: CGFloat = UIScreen.main.bounds.width/2 - 94 
    /* UIScreen.main.bounds.width/2 - 36/2 - (36 + 40) */
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    let itemWidth: CGFloat = 36
    let itemPadding: CGFloat = 40
    let displayWidth: CGFloat = UIScreen.main.bounds.width
    @EnvironmentObject var cam: BaseCamView

    var body: some View {
        ZStack {

//            if viewSwitcher.isShowMainView {
//                let _ = print("code1")
//                FromBeginToMain()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .zIndex(10) // FIXME: 後で変える
//            } else {
//            }

            VStack(spacing: 0) {
                if (selectedTag == 0) {
                    EditView()
                } else if (selectedTag == 1) {
                    PhotoView() // .environmentObject()を使うと再描画された際にカメラが更新されなくなる
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
                            .buttonStyle(TapTabBarButtonStyle(isAct: selectedTag == item.rawValue))
                        }
                        .offset(x: tabItemAnimation)
                    }
                    .padding(.top, 10)
                }
                .frame(height: 40)
            }
            .background(.white)
            .frame(maxHeight: .infinity)
        }
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
            .contentShape(.interaction, Rectangle().scale(1.2))
    }

    struct TapTabBarButtonStyle: ButtonStyle {
        var isAct: Bool
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isAct ? .purple2 : .gray)
        }
    }
}
