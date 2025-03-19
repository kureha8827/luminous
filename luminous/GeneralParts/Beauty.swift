//
//  Beauty.swift
//  luminous
//
//  Created by kureha8827 on 2024/08/25.
//

import Foundation

struct Beauty {
    static let kinds: [[[String]]] = [           // 顔加工タブの数
        BeautyFace.faceTab,
        BeautySkin.skinTab,
        BeautyMakeup.makeupTab
    ]

    static let faceKinds: [Int] = [           // 顔補正タブ
        9,  // 輪郭
        11, // 目
        7,  // 眉
        7,  // 鼻
        6   // 口
    ]
    static let skinKinds: [Int] = [             // ベースメイクタブ
        5,  // 肌色補正
        1,  // ファンデーション
        3   // コンシーラー
    ]
    static let makeupKinds: [Int] = [          // ポイントメイクタブ
        3,  // アイシャドウ
        2,  // 涙袋
        4,  // マスカラ
        5,  // カラコン
        3,  // 二重まぶた
        2,  // 瞳の光
        2,  // アイブロウ
        8,  // リップ
        4,  // チーク
        2,  // シェーディング
    ]

    static let faceTab: [String] = [
        "Face",
        "Eyes",
        "Eyebrows",
        "Nose",
        "Lips"
    ]

    static let skinTab: [String] = [
        "Tone",
        "Foundation",
        "Concealer"
    ]

    static let makeupTab: [String] = [
        "Eye shadow",
        "Eye smiles",
        "Eyelashes",
        "Contacts",
        "Eyelids",
        "Catchlight",
        "Eyebrows",
        "Lipstick",
        "Blush",
        "Shadow"
    ]
}


/* faceTab */
struct BeautyFace {
    static let faceTab: [[String]] = [
        face,
        eyes,
        eyebrows,
        nose,
        lips
    ]

    static let face: [String] = [
        "Head",
        "Slim",
        "length",
        "Jaw",
        "middle",
        "Philtrum",
        "Chin",
        "Sharp",
        "Forehead"
    ]

    static let eyes: [String] = [
        "Enlarge",
        "Position",
        "Distance",
        "Width",
        "Height",
        "Tilt",
        "Pupils",
        "Inner",
        "Outer",
        "Eye tail",
        "Under"
    ]

    static let eyebrows: [String] = [
        "Thickness",
        "Position",
        "Distance",
        "Angle",
        "Shape",
        "Front",
        "End"
    ]

    static let nose: [String] = [
        "Size",
        "Width",
        "Length",
        "Alar",
        "Bridge",
        "Radix nasi",
        "Nose tip"
    ]

    static let lips: [String] = [
        "Size",
        "Position",
        "Width",
        "Upper lip",
        "Lower lip",
        "Cupid's bow",
        "Smile"
    ]
}


/* SkinTab */
struct BeautySkin {
    static let skinTab: [[String]] = [
        tone
    ]

    static let tone: [String] = [
        "White",
        "Light beige",
        "Beige",
        "Brown",
        "Dark"
    ]
}


/* MakeupTab */
struct BeautyMakeup {
    static let makeupTab: [[String]] = [
        eyeShadow,
        eyeSmiles,
        eyelashes,
        contacts,
        eyelids,
        catchlight,
        eyebrows,
        lipstick,
        blush,
        shadow
    ]
    static let eyeShadow: [String] = [
        "Pink",
        "Orange",
        "Brown"
    ]

    static let eyeSmiles: [String] = [
        "Strong",
        "Dolly"
    ]

    static let eyelashes: [String] = [
        "Natural",
        "Dolly",
        "Young",
        "Girly"
    ]


    static let contacts: [String] = [
        "Brown",
        "Black",
        "Gray",
        "Blue",
        "RGBA"
    ]

    static let eyelids: [String] = [
        "Inout",
        "Out",
        "In"
    ]

    static let catchlight: [String] = [
        "Natural",
        "Point"
    ]

    static let eyebrows: [String] = [
        "Front",
        "End"
    ]

    static let lipstick: [String] = [
        "Peach",
        "Coral",
        "Scarlet",
        "Pink",
        "PinkOrange",
        "Orange",
        "Brown",
        "RGBA"
    ]

    static let blush: [String] = [
        "Pink",
        "Violet",
        "Orange",
        "PinkOrange"
    ]

    static let shadow: [String] = [
        "Sharp",
        "Mild"
    ]
}
