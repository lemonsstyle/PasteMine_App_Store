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
            // Background
        if #available(macOS 14, *) {
            Color.clear
                .background(.ultraThinMaterial)
        } else {
            Color(NSColor.windowBackgroundColor)
    }

            ScrollView {
                VStack(spacing: 0) {
                    // Header
        VStack(spacing: 8) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .padding(.top, 32)

            Text(AppText.Onboarding.title)
                .font(.title)
                .fontWeight(.bold)

            Text(L10n.text("一款优雅的剪贴板历史管理工具", "A delightful clipboard history manager"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
                    .padding(.bottom, 32)

                    // Steps
        VStack(spacing: 20) {
                        if currentStep == 0 {
                            // Step 1: notification permission
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
                            // Step 2: accessibility permission
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
                            // Step 3: completion
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

                    // Pager dots
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
        print("🔔 Requesting notification permission...")

        // Ensure app is active so the system sheet can appear
        NSApp.activate(ignoringOtherApps: true)

        // Small delay to ensure activation is done
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Check current status first
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("📊 Notification status: \(settings.authorizationStatus.rawValue)")

                if settings.authorizationStatus == .notDetermined {
                    // First-time request
                    print("🔔 First request, system dialog will appear...")

                    // Ensure activation again (LSUIElement app)
                    NSApp.activate(ignoringOtherApps: true)

                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("❌ Notification permission failed: \(error.localizedDescription)")
                            } else {
                                let result = granted ? "granted" : "denied"
                                print("✅ Notification permission: \(result)")
                            }
                            self.notificationPermissionGranted = granted
                            if granted {
                                // Go next
                                withAnimation {
                                    self.currentStep = 1
                                }
                            }
                        }
                    }
                } else if settings.authorizationStatus == .authorized {
                    // Already granted
                    DispatchQueue.main.async {
                        print("✅ Notification already granted")
                        self.notificationPermissionGranted = true
                        withAnimation {
                            self.currentStep = 1
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    // Denied: guide to system settings
                    DispatchQueue.main.async {
                        print("⚠️ Notification permission denied, enable manually")
                        self.notificationPermissionGranted = false
                        // Open system settings
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
    }

    private func openAccessibilitySettings() {
        // Open system settings accessibility page
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)

        // Start checking permission state
        startCheckingAccessibilityPermission()
    }

    private func startCheckingAccessibilityPermission() {
        // Check every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let granted = NSApplication.shared.isAccessibilityPermissionGranted()

            if granted != accessibilityPermissionGranted {
                DispatchQueue.main.async {
                    accessibilityPermissionGranted = granted

                    if granted {
                        // Granted: go next
                        withAnimation {
                            currentStep = 2
                        }
                        timer.invalidate()
                    }
                }
            }

            // Stop if step changed
            if currentStep != 1 {
                timer.invalidate()
            }
        }
    }

    private func checkPermissions() {
        // Check notification permission
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }

        // Check accessibility
        accessibilityPermissionGranted = NSApplication.shared.isAccessibilityPermissionGranted()
    }

    private func completeOnboarding() {
        print("🎉 Completing onboarding...")

        // Mark as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Refresh notification status
        NotificationService.shared.refreshAuthorizationStatus()

        print("✅ Onboarding done, menu bar icon ready")
        print("💡 Tip: Click the menu bar icon or press ⌘⇧V to open history")

        // Close onboarding window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = NSApp.windows.first(where: { $0.title == AppText.Onboarding.title }) {
                window.close()
                print("✅ Onboarding window closed")
            }

            // Ensure app stays active
            NSApp.activate(ignoringOtherApps: true)

            // Extra safety check
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !NSApp.isActive {
                    print("⚠️ App not active, re-activating")
                    NSApp.activate(ignoringOtherApps: true)
                }
                print("✅ App state check done")
            }
        }
    }
}

// Notification permission step view
struct NotificationPermissionStepView: View {
    @Binding var isGranted: Bool
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    @State private var isDenied = false

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "bell.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }
            .padding(.top, 16)

            // Title
            VStack(spacing: 6) {
                Text(L10n.text("开启通知", "Enable notifications"))
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(L10n.text("接收剪贴板复制和粘贴提醒", "Get alerts for copy and paste"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Description
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(L10n.text("通知将告诉您：", "Notifications will tell you:"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 6) {
                        Text("✓")
                            .foregroundStyle(.green)
                        Text(L10n.text("成功复制内容时的确认提示", "Confirmation when copy succeeds"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("✓")
                            .foregroundStyle(.green)
                        Text(L10n.text("自动粘贴完成后的提醒", "Reminder after auto-paste completes"))
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

            // Status
            if isGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(L10n.text("已授权", "Granted"))
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            } else if isDenied {
                // Denied hint
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                        Text(L10n.text("权限已被拒绝", "Permission denied"))
                            .foregroundStyle(.orange)
                            .fontWeight(.medium)
                    }
                    Text(L10n.text("请在系统设置中手动开启", "Please enable it in System Settings"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }

            Spacer()
                .frame(height: 30)

            // Buttons
            VStack(spacing: 12) {
                if !isGranted {
                    Button(action: {
                        if isDenied {
                            // Denied: open settings
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                                NSWorkspace.shared.open(url)
                            }
                        } else {
                            primaryAction()
                        }
                    }) {
                        Text(isDenied ? L10n.text("打开系统设置", "Open System Settings") : L10n.text("授予权限", "Grant permission"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: secondaryAction) {
                    Text(isGranted ? L10n.text("下一步", "Next") : L10n.text("稍后设置", "Maybe later"))
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
            // Status check
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    isDenied = settings.authorizationStatus == .denied
                    isGranted = settings.authorizationStatus == .authorized
                }
            }
        }
    }
}

// Generic permission step view
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
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 16)

            // Text
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

            // Status
            if isGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(L10n.text("已授权", "Granted"))
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
                .padding(.top, 8)
            }

            Spacer()
                .frame(height: 30)

            // Buttons
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
                    Text(isGranted ? L10n.text("下一步", "Next") : secondaryButtonTitle)
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

// Accessibility permission step
struct AccessibilityPermissionStepView: View {
    @Binding var isGranted: Bool
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }
            .padding(.top, 16)

            // Title
            VStack(spacing: 6) {
                Text(L10n.text("开启辅助功能", "Enable accessibility"))
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(L10n.text("允许 PasteMine 实现自动粘贴功能", "Allow PasteMine to perform auto-paste"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Steps
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.text("操作步骤：", "Steps:"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    StepRow(number: "1", text: L10n.text("点击下方按钮打开「系统设置」", "Click the button below to open System Settings"))
                    StepRow(number: "2", text: L10n.text("进入「隐私与安全性」", "Go to Privacy & Security"))
                    StepRow(number: "3", text: L10n.text("点击「辅助功能」", "Click Accessibility"))
                    StepRow(number: "4", text: L10n.text("点击「+」添加 PasteMine", "Click \"+\" to add PasteMine"))
                    StepRow(number: "5", text: L10n.text("可能需要输入密码确认", "You may need to enter your password"))
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

            // Status
            if isGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(L10n.text("已授权", "Granted"))
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            }

            Spacer()
                .frame(height: 20)

            // Buttons
            VStack(spacing: 12) {
                if !isGranted {
                    Button(action: primaryAction) {
                        Text(L10n.text("打开系统设置", "Open System Settings"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: secondaryAction) {
                    Text(isGranted ? L10n.text("下一步", "Next") : L10n.text("稍后设置", "Maybe later"))
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

// Step row
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

// Completion view
struct CompletionStepView: View {
    let notificationGranted: Bool
    let accessibilityGranted: Bool
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }
            .padding(.top, 16)

            // Title
            VStack(spacing: 6) {
                Text(L10n.text("设置完成！", "Setup complete!"))
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(L10n.text("您已准备好使用 PasteMine", "You're ready to use PasteMine"))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // Permission summary
            VStack(spacing: 10) {
                PermissionStatusRow(
                    icon: "bell.fill",
                    title: L10n.text("通知权限", "Notification"),
                    isGranted: notificationGranted
                )

                PermissionStatusRow(
                    icon: "hand.point.up.left.fill",
                    title: L10n.text("辅助功能权限", "Accessibility"),
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

            // Tips
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(L10n.text("使用提示", "Tips"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(L10n.text("按 ⌘⇧V 或点击菜单栏图标打开历史窗口", "Press ⌘⇧V or click the menu bar icon to open history"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(L10n.text("点击历史记录即可自动粘贴到当前应用", "Click a history item to auto-paste into the front app"))
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
                Text(L10n.text("您可以稍后在系统设置中开启缺失的权限", "You can enable missing permissions later in System Settings"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            Spacer()
                .frame(height: 20)

            // Finish button
            Button(action: onComplete) {
                Text(L10n.text("开始使用", "Start using"))
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

// Permission status row
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

            Text(isGranted ? AppText.PermissionStatus.granted : AppText.PermissionStatus.notGranted)
                .font(.caption)
                .foregroundStyle(isGranted ? .green : .orange)
        }
    }
}

#Preview {
    OnboardingView()
}
