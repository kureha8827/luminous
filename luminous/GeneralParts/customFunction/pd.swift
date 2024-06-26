//
//  pd.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/23.
//

import Foundation

public func pd(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // ここにカスタムロジックを追加
    let output = items.map { ": \($0)" }.joined(separator: separator)
    Swift.print(outputString)
    Swift.print(output, terminator: terminator)
}
