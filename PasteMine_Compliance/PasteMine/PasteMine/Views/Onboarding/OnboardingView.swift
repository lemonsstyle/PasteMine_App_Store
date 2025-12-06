//
//  OnboardingView.swift
//  PasteMine
//
//  Created by lagrange on 2025/11/30.
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var notificationPermissionGranted = false
    @State private var accessibilityPermissionGranted = false

    var body: some View {
        ZStack {
            // 背景
        if #available(macOS 14, *) {
            Color.clear
                .background(.ultraThinMaterial)
        } else {
            Color(NSColor.windowBackgroundColor)
    }

            ScrollView {
                VStack(spacing: 0) {
                    // 标题区域
        VStack(spacing: 8) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .padding(.top, 32)

            Text("欢迎使用 PasteMine")
                .font(.title)
                .fontWeight(.bold)

            Text("一款优雅的剪贴板历史管理工具")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
                    .padding(.bottom, 32)

                    // 步骤内容
        VStack(spacing: 20) {
                        if currentStep == 0 {
                            // 步骤 1: 通知权限
                            NotificationPermissionStepView(
                    isGranted: $notificationPermissionGranted,
                                primaryAction: {
                                    requestNotificationPermission()
                                },
                                secondaryAction: {
                                    currentStep = 1
                                }
                )
                        } else if currentStep == 1 {
                            // 步骤 2: 辅助功能权限
                            AccessibilityPermissionStepView(
                    isGranted: $accessibilityPermissionGranted,
                                primaryAction: {
                                    openAccessibilitySettings()
                                },
                                secondaryAction: {
                                    currentStep = 2
                                }
                )
                        } else {
                            // 步骤 3: 完成
                CompletionStepView(
                    notificationGranted: notificationPermissionGranted,
                    accessibilityGranted: accessibilityPermissionGranted,
                                onComplete: {
                                    completeOnboarding()
                                }
                )
            }
        }
                    .frame(minHeight: 480)
        .animation(.easeInOut, value: currentStep)

                    // 底部指示器
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(currentStep == index ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: 540)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: 540, height: 680)
        .onAppear {
            checkPermissions()
        }
    }

    private func requestNotificationPermission() {
        print("🔔 正在请求通知权限...")

        // ⚠️ 关键修改：确保应用处于激活状态，这样系统弹窗才能正常显示
        NSApp.activate(ignoringOtherApps: true)

        // 短暂延迟，确保应用激活完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 先检查当前权限状态
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("📊 当前通知权限状态: \(settings.authorizationStatus.rawValue)")

                if settings.authorizationStatus == .notDetermined {
                    // 首次请求权限，会弹出系统对话框
                    print("🔔 首次请求，将弹出系统对话框...")

                    // ⚠️ 再次确保应用激活（关键：LSUIElement=true 应用需要）
                    NSApp.activate(ignoringOtherApps: true)

                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("❌ 请求通知权限失败: \(error.localizedDescription)")
                            } else {
                                print("✅ 通知权限请求结果: \(granted ? "已授权" : "已拒绝")")
                            }
                            self.notificationPermissionGranted = granted
                            if granted {
                                // 自动进入下一步
                                withAnimation {
                                    self.currentStep = 1
                                }
                            }
                        }
                    }
                } else if settings.authorizationStatus == .authorized {
                    // 已经授权
                    DispatchQueue.main.async {
                        print("✅ 通知权限已经授权")
                        self.notificationPermissionGranted = true
                        withAnimation {
                            self.currentStep = 1
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    // 已经拒绝，引导用户去系统设置开启
                    DispatchQueue.main.async {
                        print("⚠️ 通知权限已被拒绝，需要手动开启")
                        self.notificationPermissionGranted = false
                        // 打开系统通知设置
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
    }

    private func openAccessibilitySettings() {
        // 打开系统设置的辅助功能页面
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)

        // 开始检查权限状态
        startCheckingAccessibilityPermission()
    }

    private func startCheckingAccessibilityPermission() {
        // 每秒检查一次权限状态
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let granted = NSApplication.shared.isAccessibilityPermissionGranted()

            if granted != accessibilityPermissionGranted {
                DispatchQueue.main.async {
                    accessibilityPermissionGranted = granted

                    if granted {
                        // 权限已授予，自动进入下一步
                        withAnimation {
                            currentStep = 2
                        }
                        timer.invalidate()
                    }
                }
            }

            // 如果已经离开这个步骤，停止检查
            if currentStep != 1 {
                timer.invalidate()
            }
        }
    }

    private func checkPermissions() {
        // 检查通知权限
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }

        // 检查辅助功能权限
        accessibilityPermissionGranted = NSApplication.shared.isAccessibilityPermissionGranted()
    }

    private func completeOnboarding() {
        print("🎉 正在完成引导...")

        // 标记已完成引导
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // 确保 NotificationService 已初始化（刷新权限状态）
        NotificationService.shared.refreshAuthorizationStatus()

        // ⚠️ 重要改进：不立即显示主窗口，避免自动隐藏导致的问题
        // 用户可以通过托盘图标或快捷键（⌘⇧V）打开主窗口

        print("✅ 引导完成，托盘图标已可用")
        print("💡 提示：点击右上角托盘图标或按 ⌘⇧V 打开剪贴板历史")

        // 延迟后关闭引导窗口，确保应用有足够时间稳定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = NSApp.windows.first(where: { $0.title == "欢迎使用 PasteMine" }) {
                window.close()
                print("✅ 引导窗口已关闭")
            }

            // 确保应用保持激活状态，避免立即被自动终止
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

// 通知权限步骤视图
struct NotificationPermissionStepView: View {
    @Binding var isGranted: Bool
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    @State private var isDenied = false

    var body: some View {
        VStack(spacing: 20) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "bell.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }
            .padding(.top, 16)

            // 标题
            VStack(spacing: 6) {
                Text("开启通知")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("接收剪贴板复制和粘贴提醒")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // 功能说明
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("通知将告诉您：")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 6) {
                        Text("✓")
                            .foregroundStyle(.green)
                        Text("成功复制内容时的确认提示")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("✓")
                            .foregroundStyle(.green)
                        Text("自动粘贴完成后的提醒")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if #available(macOS 14, *) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.05))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 24)

            // 状态指示
            if isGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("已授权")
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            } else if isDenied {
                // 已拒绝提示
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                        Text("权限已被拒绝")
                            .foregroundStyle(.orange)
                            .fontWeight(.medium)
                    }
                    Text("请在系统设置中手动开启")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }

            Spacer()
                .frame(height: 30)

            // 按钮
            VStack(spacing: 12) {
                if !isGranted {
                    Button(action: {
                        if isDenied {
                            // 已拒绝，打开系统设置
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                                NSWorkspace.shared.open(url)
                            }
                        } else {
                            primaryAction()
                        }
                    }) {
                        Text(isDenied ? "打开系统设置" : "授予权限")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: secondaryAction) {
                    Text(isGranted ? "下一步" : "稍后设置")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isGranted ? Color.accentColor : Color.clear)
                        .foregroundColor(isGranted ? .white : .primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // 检查权限状态
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    isDenied = settings.authorizationStatus == .denied
                    isGranted = settings.authorizationStatus == .authorized
                }
            }
        }
    }
}

// 权限步骤视图（通用）
struct PermissionStepView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    @Binding var isGranted: Bool
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    let secondaryButtonTitle: String
    let secondaryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // 图标
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 16)

            // 文本
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // 状态指示
            if isGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("已授权")
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
                .padding(.top, 8)
            }

            Spacer()
                .frame(height: 30)

            // 按钮
            VStack(spacing: 12) {
                if !isGranted {
                    Button(action: primaryAction) {
                        Text(primaryButtonTitle)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: secondaryAction) {
                    Text(isGranted ? "下一步" : secondaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isGranted ? Color.accentColor : Color.clear)
                        .foregroundColor(isGranted ? .white : .primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

// 辅助功能权限步骤视图（带详细指引）
struct AccessibilityPermissionStepView: View {
    @Binding var isGranted: Bool
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }
            .padding(.top, 16)

            // 标题
            VStack(spacing: 6) {
                Text("开启辅助功能")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("允许 PasteMine 实现自动粘贴功能")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // 详细操作步骤
            VStack(alignment: .leading, spacing: 10) {
                Text("操作步骤：")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    StepRow(number: "1", text: "点击下方按钮打开「系统设置」")
                    StepRow(number: "2", text: "进入「隐私与安全性」")
                    StepRow(number: "3", text: "点击「辅助功能」")
                    StepRow(number: "4", text: "点击「+」添加 PasteMine")
                    StepRow(number: "5", text: "可能需要输入密码确认")
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if #available(macOS 14, *) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                }
            }
            .padding(.horizontal, 24)

            // 状态指示
            if isGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("已授权")
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            }

            Spacer()
                .frame(height: 20)

            // 按钮
            VStack(spacing: 12) {
                if !isGranted {
                    Button(action: primaryAction) {
                        Text("打开系统设置")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: secondaryAction) {
                    Text(isGranted ? "下一步" : "稍后设置")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isGranted ? Color.accentColor : Color.clear)
                        .foregroundColor(isGranted ? .white : .primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

// 步骤行组件
struct StepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.accentColor))
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// 完成步骤视图
struct CompletionStepView: View {
    let notificationGranted: Bool
    let accessibilityGranted: Bool
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // 成功图标
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }
            .padding(.top, 16)

            // 标题
            VStack(spacing: 6) {
                Text("设置完成！")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("您已准备好使用 PasteMine")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // 权限状态总结
            VStack(spacing: 10) {
                PermissionStatusRow(
                    icon: "bell.fill",
                    title: "通知权限",
                    isGranted: notificationGranted
                )

                PermissionStatusRow(
                    icon: "hand.point.up.left.fill",
                    title: "辅助功能权限",
                    isGranted: accessibilityGranted
                )
            }
            .padding(14)
            .background {
                if #available(macOS 14, *) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            // 提示信息
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("使用提示")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("按 ⌘⇧V 或点击菜单栏图标打开历史窗口")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("点击历史记录即可自动粘贴到当前应用")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if #available(macOS 14, *) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.05))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 24)

            if !notificationGranted || !accessibilityGranted {
                Text("您可以稍后在系统设置中开启缺失的权限")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            Spacer()
                .frame(height: 20)

            // 完成按钮
            Button(action: onComplete) {
                Text("开始使用")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

// 权限状态行
struct PermissionStatusRow: View {
    let icon: String
    let title: String
    let isGranted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isGranted ? .green : .orange)
                .frame(width: 28)

            Text(title)
                .font(.body)

            Spacer()

            Image(systemName: isGranted ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .orange)

            Text(isGranted ? "已授权" : "未授权")
                .font(.caption)
                .foregroundStyle(isGranted ? .green : .orange)
        }
    }
}

#Preview {
    OnboardingView()
}
