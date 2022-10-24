//
//  File.swift
//
//
//  Created by Andrew Wang on 2022/10/3.
//

import Foundation

func urlForContractRoot() -> URL? {
    let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
    let paths = currentFileURL.absoluteString.split(separator: "/")
    return URL(string: String(paths.dropLast(5).joined(separator: "/")) + "/packages/contract/")
}

public func contractEnvFileURL() -> URL? {
    guard let contractRoot = urlForContractRoot() else {
        return nil
    }
    return enumerateFileURL(
        root: contractRoot,
        includingPropertiesForKeys: [.isHiddenKey],
        options: [.skipsSubdirectoryDescendants],
        keyword: ".env"
    )
}

public func cadenceRootPath() -> URL? {
    guard let contractRoot = urlForContractRoot() else {
        return nil
    }
    return contractRoot
        .appendingPathComponent("src")
        .appendingPathComponent("cadence")
}

public func scriptsFileContent(name: String) -> String? {
    guard let contractRoot = cadenceRootPath() else {
        return nil
    }
    let scriptRoot = contractRoot
        .appendingPathComponent("scripts")
    guard let url = enumerateFileURL(root: scriptRoot, keyword: name) else {
        return nil
    }
    return try? String(contentsOf: url, encoding: .utf8)
}

public func transactionsFileContent(name: String) -> String? {
    guard let contractRoot = urlForContractRoot() else {
        return nil
    }
    let transactionRoot = contractRoot
        .appendingPathComponent("transactions")
    guard let url = enumerateFileURL(root: transactionRoot, keyword: name) else {
        return nil
    }
    return try? String(contentsOf: url, encoding: .utf8)
}

private func enumerateFileURL(
    root: URL,
    includingPropertiesForKeys: [URLResourceKey]? = nil,
    options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsHiddenFiles],
    keyword: String
) -> URL? {
    guard let enumerator = FileManager.default.enumerator(
        at: root,
        includingPropertiesForKeys: includingPropertiesForKeys,
        options: options,
        errorHandler: nil
    ) else {
        fatalError("Could not enumerate \(root)")
    }
    for case let url as URL in enumerator where url.isFileURL && url.absoluteString.contains(keyword) {
        return url
    }
    return nil
}
