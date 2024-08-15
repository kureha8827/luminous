//
//  ContentView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//
import SwiftUI

struct MainView: View {
    @EnvironmentObject var main: MainObserver
    @State private var tabItemAnimation: CGFloat = -38
    /* (36 + 40)/2 */
    let itemWidth: CGFloat = 36
    let itemPadding: CGFloat = 40
    let displayWidth: CGFloat = DisplayInfo.width
    @EnvironmentObject var cam: BaseCamera
    @EnvironmentObject var vs: ViewSwitcher
    @EnvironmentObject var photoStatus: PhotoObservableClass

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if (main.selectedTag == 0) {
                    EditView()
                } else if (main.selectedTag == 1) {
                    PhotoView()
                }
                Spacer()
            }

            if main.isShowTabBar {
                HStack(spacing: itemPadding) {
                    ForEach(MainTabBar.allCases, id: \.self) { item in
                        if (photoStatus.isShowFilter == 0 && photoStatus.isShowAdjuster == 0) {
                            Button {
                                main.selectedTag = item.rawValue
                                withAnimation(Animation.easeOut(duration: 0.3)) {
                                    tabItemAnimation = tabItemArrangement(CGFloat(main.selectedTag))
                                }
                            } label: {
                                TabItemView(item: item, isActive: main.selectedTag == item.rawValue)
                            }
                            .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
                            .buttonStyle(TabBarButtonStyle(isAct: main.selectedTag == item.rawValue))
                        }
                    }
                    //                            .offset(x: tabItemAnimation)
                    .offset(x: tabItemAnimation)
                    //                    .opacity(main.isShowTabBar ? 1 : 0)
                    .onChange(of: main.selectedTag) {
                        withAnimation(Animation.easeOut(duration: 0.2)) {
                            tabItemAnimation = tabItemArrangement(CGFloat(main.selectedTag))
                        }
                    }
                    .transition(.opacity)
                }
                .frame(height: 40)
                .padding(.vertical, 10)
                .background(.yellow)
                .offset(y: DisplayInfo.height / 2 - 60)
                .ignoresSafeArea()
            }

            // 調整View
            GeometryReader { geometry in
                ImageAdjusterView(is16x9: cam.optionSelect[1] == 0)
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*photoStatus.isShowAdjuster)
                    .opacity(photoStatus.isShowAdjuster)
                    .zIndex(2)
            }

            // フィルタView
            GeometryReader { geometry in
                ImageFilterView(is16x9: cam.optionSelect[1] == 0)
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*photoStatus.isShowFilter)
                    .opacity(photoStatus.isShowFilter)
                    .zIndex(2)
            }
        }
        .frame(maxHeight: .infinity)
        .background(.red)
        .animation(
            .easeOut(duration: 0.2),
            value: photoStatus.isShowFilter
        )
        .animation(
            .easeOut(duration: 0.2),
            value: photoStatus.isShowAdjuster
        )
        .animation(
            .easeOut(duration: 0.2),
            value: UIDevice.current.orientation
        )
        .onDisappear() {
            print("main disappear")
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
        return (itemWidth + itemPadding)*(1/2 - selection)
    }


    struct TabItemView: View {
        var item: MainTabBar
        var isActive: Bool
        var body: some View {
            Image(systemName: item.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: MainView().itemWidth)
                .tint(isActive ? .lightPurple : .gray)
                .contentShape(.interaction, Rectangle().scale(1.2))
        }
    }

    struct TabBarButtonStyle: ButtonStyle {
        var isAct: Bool
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isAct ? .lightPurple : .gray)
        }
    }
}
