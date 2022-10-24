//
//  File.swift
//
//
//  Created by Andrew Wang on 2022/10/3.
//

import Foundation

public func loadCustomEnv() throws {
    guard let contractEnv = contractEnvFileURL() else {
        fatalError("contractEnv not found")
    }

    let content = try String(contentsOf: contractEnv, encoding: .utf8)
    content
        .split(separator: "\n")
        .forEach { keyValuePair in
            let elements = keyValuePair.split(separator: "=")
            if elements.count == 2 {
                setenv(String(elements[0]), String(elements[1]), 1)
            }
        }
}
