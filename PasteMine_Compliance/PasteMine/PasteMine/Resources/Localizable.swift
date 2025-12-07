//
//  Localizable.swift
//  PasteMine
//
//  统一管理应用内所有显示文字
//  便于后续字体、字号调整和多语言翻译
//

import Foundation

enum AppLanguage {
    case zhHans
    case en

    static var current: AppLanguage {
        if let code = Locale.preferredLanguages.first?.lowercased(),
           code.hasPrefix("zh") {
            return .zhHans
        }
        return .en
    }
}

enum L10n {
    static func text(_ zh: String, _ en: String) -> String {
        AppLanguage.current == .zhHans ? zh : en
    }
}

enum AppText {
    private static let lang = AppLanguage.current
    private static func t(_ zh: String, _ en: String) -> String { lang == .zhHans ? zh : en }
    
    // MARK: - 设置页面
    enum Settings {
        static var title: String { t("设置", "Settings") }
        static var doneButton: String { t("完成", "Done") }
        
        // 分组标题
        enum Groups {
            static var general: String { t("通用", "General") }
            static var storage: String { t("存储", "Storage") }
            static var privacy: String { t("隐私", "Privacy") }
        }
        
        // 通用设置
        enum General {
            static var clipboardHistory: String { t("启用剪贴板历史记录", "Enable clipboard history") }
            static var clipboardHistoryDesc: String { t("开启后才会在本机保存最近的剪贴板内容，可随时关闭", "Only after enabling will recent clipboard content be saved locally; you can turn it off anytime.") }
            static var notification: String { t("通知", "Notifications") }
            static var notificationDesc: String { t("复制时显示通知", "Show notification when copying") }
            
            static var sound: String { t("音效", "Sound") }
            static var soundDesc: String { t("播放提示音效", "Play sound on actions") }
            
            static var globalShortcut: String { t("全局快捷键", "Global shortcut") }
            static var globalShortcutDesc: String { t("显示/隐藏窗口", "Show / hide window") }
            
            static var launchAtLogin: String { t("开机自启动", "Launch at login") }
            static var launchAtLoginDesc: String { t("自动启动应用", "Start automatically on login") }
            static var launchAtLoginUnsupported: String { t("该功能仅支持 macOS 13 及以上系统", "Available on macOS 13+") }
        }
        
        // 存储设置
        enum Storage {
            static var historyLimit: String { t("历史记录上限", "History limit") }
            static var historyLimitDesc: String { t("超出自动删除", "Auto-delete when exceeding limit") }
            static var historyPermanent: String { t("永久", "Unlimited") }
            static func historyCount(_ count: Int) -> String { t("\(count) 条", "\(count) items") }
            
            static var ignoreLargeImages: String { t("忽略大图片以节省磁盘空间", "Ignore large images to save disk space") }
            static var ignoreLargeImagesDesc: String { t("超过 20MB 的图片将不会被保存到历史中", "Images over 20MB will not be saved") }
        }
        
        // 隐私设置
        enum Privacy {
            static var ignoreApps: String { t("忽略应用", "Ignored apps") }
            static var ignoreTypes: String { t("忽略类型", "Ignored types") }
            
            static var selectApp: String { t("选择应用", "Select app") }
            static var ignoreAppsDesc: String { t("这些应用中的复制操作不会被记录", "Copies from these apps will be ignored") }
            static var defaultIgnoredAppsDesc: String { t("PasteMine 默认已忽略常见密码管理器和自动填充工具，您可在此增删。", "Common password managers and autofill tools are ignored by default; adjust as needed.") }
            
            static var addType: String { t("添加", "Add") }
            static var typeListTitle: String { t("类型列表", "Type list") }
            static var typePlaceholder: String { t("输入 pasteboard type", "Enter pasteboard type") }
            static var ignoreTypesDesc: String { t("这些类型的隐私内容不会被记录", "These sensitive types will not be recorded") }
            static var defaultIgnoredTypesDesc: String { t("已预置密码字段等敏感剪贴板类型，可根据需要调整。", "Sensitive pasteboard types (password/OTP) are preset; adjust as needed.") }
            static var ignoreTypesToggleLabel: String { t("启用忽略类型", "Enable ignored types") }
            
            static var clearOnQuit: String { t("退出时清空剪贴板", "Clear history on quit") }
            static var clearOnQuitDesc: String { t("退出应用时自动清除所有历史记录", "Automatically remove all history when quitting") }
            
            static var emptyList: String { t("列表为空", "Empty list") }
        }
    }
    
    // MARK: - 主窗口
    enum MainWindow {
        static var windowTitle: String { "PasteMine" }
        static var searchPlaceholder: String { t("搜索...", "Search...") }
        static var emptyStateTitle: String { t("暂无剪贴板记录", "No clipboard items yet") }
        static var emptyStateMessage: String { t("开始复制内容，它们会出现在这里", "Start copying and items will show here") }
        static var clearAll: String { t("清空", "Clear all") }
        static var settings: String { t("设置", "Settings") }
        
        // 筛选相关
        static var filterAll: String { t("全部", "All") }
        static var filterMore: String { "..." }
    }
    
    // MARK: - 引导页面
    enum Onboarding {
        static var title: String { t("欢迎使用 PasteMine", "Welcome to PasteMine") }
        static var step1Title: String { t("📋 自动记录", "📋 Auto capture") }
        static var step1Desc: String { t("自动记录你的复制内容\n支持文本和图片", "Automatically record your copies\nSupports text & images") }
        
        static var step2Title: String { t("⌨️ 快捷访问", "⌨️ Quick access") }
        static var step2Desc: String { t("使用快捷键快速调出历史\n默认：⌘⇧V", "Use shortcut to open history\nDefault: ⌘⇧V") }
        
        static var step3Title: String { t("🔒 隐私保护", "🔒 Privacy") }
        static var step3Desc: String { t("可设置忽略特定应用\n保护敏感信息", "Ignore specific apps to protect sensitive info") }
        
        static var getStarted: String { t("开始使用", "Get started") }
        static var permissionTitle: String { t("需要授予权限", "Permission required") }
        static var permissionMessage: String { t("为了正常工作，请在系统设置中授予通知权限", "Grant notification permission in System Settings to proceed.") }
    }
    
    // MARK: - 通知
    enum Notifications {
        static var copyTitle: String { t("📋 剪贴板已更新", "📋 Clipboard updated") }
        static var copyImageTitle: String { t("📸 复制了图片", "📸 Image copied") }
        static var pasteTitle: String { t("📋 粘贴成功", "📋 Pasted") }
    }
    
    // MARK: - 右键菜单
    enum Menu {
        static var showWindow: String { t("显示窗口", "Show window") }
        static var quit: String { t("退出", "Quit") }
    }
    
    // MARK: - 通用
    enum Common {
        static var delete: String { t("删除", "Delete") }
        static var cancel: String { t("取消", "Cancel") }
        static var confirm: String { t("确认", "Confirm") }
        static var copy: String { t("复制", "Copy") }
        static var paste: String { t("粘贴", "Paste") }
    }
}
