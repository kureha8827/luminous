//
//  ContentView.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//
import SwiftUI

struct MainView: View {
    @EnvironmentObject var main: MainObserver
    @State private var tabItemAnimation: CGFloat = UIScreen.main.bounds.width/2 - 94
    /* UIScreen.main.bounds.width/2 - 36/2 - (36 + 40) */
    let itemWidth: CGFloat = 36
    let itemPadding: CGFloat = 40
    let displayWidth: CGFloat = UIScreen.main.bounds.width
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


                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack(spacing: itemPadding) {
                            ForEach(MainTabBar.allCases, id: \.self) { item in
                                if (photoStatus.isShowFilter == 0 && photoStatus.isShowAdjuster == 0) {
                                    Button {
                                        main.selectedTag = item.rawValue
                                        withAnimation(Animation.easeOut(duration: 0.3)) {
                                            tabItemAnimation = tabItemArrangement(CGFloat(main.selectedTag))
                                        }
                                    } label: {
                                        tabItemView(
                                            tabBarItem: item,
                                            isActive: main.selectedTag == item.rawValue
                                        )
                                    }
                                    .rotationEffect(.degrees(round(-90.0*powl(Double(UIDevice.current.orientation.rawValue)-3.5+1.0/(4.0*Double(UIDevice.current.orientation.rawValue)-14.0), -11))))
                                    .buttonStyle(TapTabBarButtonStyle(isAct: main.selectedTag == item.rawValue))
                                }
                            }
                            .offset(x: tabItemAnimation)
                        }
                    }
                }
                .offset(y: main.isShowTabBar ? 0 : 100)
                .animation(
                    .easeOut(duration: 0.2),
                    value: main.isShowTabBar
                )
                .frame(height: 40)
                .onChange(of: main.selectedTag) {
                    withAnimation(Animation.easeOut(duration: 0.2)) {
                        tabItemAnimation = tabItemArrangement(CGFloat(main.selectedTag))
                    }
                }
            }

            // 調整View
            GeometryReader { geometry in
                ImageAdjusterView(isPhotoView: true)
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*photoStatus.isShowAdjuster)
                    .opacity(photoStatus.isShowAdjuster)
                    .zIndex(2)
            }

            // フィルタView
            GeometryReader { geometry in
                ImageFilterView(isPhotoView: true)
                    .frame(height: 144)
                    .offset(y: geometry.frame(in: .local).maxY - 144*photoStatus.isShowFilter)
                    .opacity(photoStatus.isShowFilter)
                    .zIndex(2)
            }
        }
        .background(.white)
        .frame(maxHeight: .infinity)
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
