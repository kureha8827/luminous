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
    let itemWidth: CGFloat = 36
    let itemPadding: CGFloat = 40
    let displayWidth: CGFloat = UIScreen.main.bounds.width
    @EnvironmentObject var cam: BaseCamView
    @EnvironmentObject var vs: ViewSwitcher

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    if (selectedTag == 0) {
                        EditView()
                    } else if (selectedTag == 1) {
                        PhotoView() // .environmentObject()を使うと再描画された際にカメラが更新されなくなる
                    }
                }

                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack(spacing: itemPadding) {
                            ForEach(MainTabBar.allCases, id: \.self) { item in
                                if vs.isShowFilterView == 0 {
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
                            }
                            .offset(x: tabItemAnimation)
                        }
                    }
                }
                .frame(height: 40)
            }

            GeometryReader { geometry in
                FilterView()
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*vs.isShowFilterView)
                    .opacity(vs.isShowFilterView)
                    .zIndex(2)
            }
        }
        .background(.white)
        .frame(maxHeight: .infinity)
        .animation(
            .easeOut(duration: 0.2),
            value: vs.isShowFilterView
        )
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
            .tint(isActive ? .lightPurple : .gray)
            .contentShape(.interaction, Rectangle().scale(1.2))
    }

    struct TapTabBarButtonStyle: ButtonStyle {
        var isAct: Bool
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isAct ? .lightPurple : .gray)
        }
    }
}
