//
//  File.swift
//
//
//  Created by Andrew Wang on 2022/10/3.
//

import Foundation
import Vapor

public func loadCustomEnv(_ env: Environment) throws {
    let envFileName: String
    switch env.name {
    case Environment.production.name:
        envFileName = ".env"
    case Environment.development.name:
        envFileName = ".env.emulator"
    case Environment.testing.name:
        envFileName = ".env.testnet"
    default:
        fatalError("name of env should be development, testing, production")
    }
    guard let contractEnv = contractEnvFileURL(envFileName: envFileName) else {
        fatalError("\(envFileName) not found")
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
