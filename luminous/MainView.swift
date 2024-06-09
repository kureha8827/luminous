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
    @EnvironmentObject var cam: BaseCamera
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
                                if vs.isShowImageFilterV == 0 && vs.isShowImageAdjusterV == 0 {
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
                                    .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
                                    .buttonStyle(TapTabBarButtonStyle(isAct: selectedTag == item.rawValue))
                                }
                            }
                            .offset(x: tabItemAnimation)
                        }
                    }
                }
                .frame(height: 40)
            }

            // フィルタView
            GeometryReader { geometry in
                ImageFilterView()
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*vs.isShowImageFilterV)
                    .opacity(vs.isShowImageFilterV)
                    .zIndex(2)
            }

            // 調整View
            GeometryReader { geometry in
                ImageAdjusterView()
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*vs.isShowImageAdjusterV)
                    .opacity(vs.isShowImageAdjusterV)
                    .zIndex(2)
            }
        }
        .background(.white)
        .frame(maxHeight: .infinity)
        .animation(
            .easeOut(duration: 0.2),
            value: vs.isShowImageFilterV
        )
        .animation(
            .easeOut(duration: 0.2),
            value: vs.isShowImageAdjusterV
        )
        .animation(
            .easeOut(duration: 0.2),
            value: UIDevice.current.orientation
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
