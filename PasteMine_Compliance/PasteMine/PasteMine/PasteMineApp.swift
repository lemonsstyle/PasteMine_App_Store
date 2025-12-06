//
//  PasteMineApp.swift
//  PasteMine
//
//  Created by lagrange on 2025/11/22.
//

import SwiftUI

@main
struct PasteMineApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // ⚠️ 关键修复：添加隐藏的 Window 场景来维持应用生命周期
        // 对于 LSUIElement=true 的应用，SwiftUI 需要至少一个 Window 场景
        // 参考：https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items
        Window("_Hidden", id: "hidden-window") {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1, height: 1)
        .defaultPosition(.topLeading)

        Settings {
            EmptyView() // 不使用默认窗口，由 WindowManager 管理
        }
    }
}
