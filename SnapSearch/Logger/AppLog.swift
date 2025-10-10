//
//  AppLog.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/04
//  

import OSLog

let logger = AppLog.self

enum LogCategory: String {
    case app
    case view
    case network
    case system
}

enum AppLog {
    // OSが発信元を識別できるようsubsystemにBundleIDを使う
    private static let subsystem = Bundle.main.bundleIdentifier ?? "app.unknown"

    private static func makeLogger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    #if LOG_DEBUG
    static func debug(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        makeLogger(for: category).debug("🟩 [\(file):\(line)] \(function) - \(message())")
    }
    #else
    @inline(__always) static func debug(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {}
    #endif

    #if LOG_INFO
    static func info(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        makeLogger(for: category).info("🟦 [\(file):\(line)] \(function) - \(message())")
    }
    #else
    @inline(__always) static func info(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {}
    #endif

    #if LOG_WARN
    static func warn(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        makeLogger(for: category).warning("🟨 [\(file):\(line)] \(function) - \(message())")
    }
    #else
    @inline(__always) static func warn(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {}
    #endif

    #if LOG_ERROR
    static func error(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        makeLogger(for: category).error("🟥 [\(file):\(line)] \(function) - \(message())")
    }
    #else
    @inline(__always) static func error(
        _ category: LogCategory = .app,
        _ message: @autoclosure @escaping () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {}
    #endif
}
