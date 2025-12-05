# PasteMine App Store 审核检查报告

## ✅ 已符合的要求

### 1. 隐私信息声明 (PrivacyInfo.xcprivacy)
- ✅ 已正确声明剪贴板数据收集 (`NSPrivacyCollectedDataTypeUserContent`)
- ✅ 已正确声明使用数据收集 (`NSPrivacyCollectedDataTypeUsageDataProductInteraction`)
- ✅ 已正确声明剪贴板 API 使用原因 (`C617.1`)
- ✅ 已正确声明 Apple Events API 使用原因 (`7B41.1`)
- ✅ 所有数据标记为不追踪 (`Tracking: false`)
- ✅ 所有数据标记为不关联 (`Linked: false`)

### 2. 权限使用说明 (Info.plist)
- ✅ `NSUserNotificationUsageDescription` - 通知权限说明已配置
- ✅ `NSAppleEventsUsageDescription` - Apple Events 权限说明已配置
- ✅ 说明文字清晰，说明了权限用途

### 3. 沙盒配置 (Entitlements)
- ✅ 已启用应用沙盒 (`com.apple.security.app-sandbox`)
- ✅ 已声明 Apple Events 权限 (`com.apple.security.automation.apple-events`)
- ✅ 已声明用户选择文件读取权限 (`com.apple.security.files.user-selected.read-only`)

### 4. 数据隐私
- ✅ 所有数据仅存储在本地沙盒目录
- ✅ 没有网络请求或数据传输
- ✅ 没有第三方 SDK 或分析工具
- ✅ 没有广告或追踪代码

### 5. 功能实现
- ✅ 辅助功能权限使用合理（仅用于自动粘贴）
- ✅ 剪贴板访问有明确的用户控制（可关闭）
- ✅ 开机自启动使用官方 API (SMAppService)
- ✅ 没有内购或订阅功能

---

## ⚠️ 需要修复的问题

### 🔴 严重问题

#### 1. 项目配置中沙盒设置不一致
**问题位置：** `PasteMine.xcodeproj/project.pbxproj`

**问题描述：**
```pbxproj
ENABLE_APP_SANDBOX = NO;  // ❌ 这里设置为 NO
```

但 `PasteMine.entitlements` 文件中启用了沙盒：
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
```

**影响：** 这会导致构建配置不一致，可能无法通过 App Store 审核。

**修复方法：**
在 Xcode 项目设置中：
1. 选择项目 Target
2. 进入 "Signing & Capabilities" 标签
3. 确保 "App Sandbox" 已启用
4. 或者在 `project.pbxproj` 中将 `ENABLE_APP_SANDBOX` 改为 `YES`

---

### 🟡 建议改进

#### 2. 辅助功能权限在 PrivacyInfo.xcprivacy 中未声明
**问题：** 虽然辅助功能权限不需要在 Privacy Manifest 中声明，但为了更好的透明度，建议添加说明。

**建议：** 在 `PrivacyInfo.xcprivacy` 中添加辅助功能 API 的声明（可选）：
```xml
<dict>
    <key>NSPrivacyAccessedAPIType</key>
    <string>NSPrivacyAccessedAPICategoryAccessibility</string>
    <key>NSPrivacyAccessedAPITypeReasons</key>
    <array>
        <string>E174.1</string>  <!-- 仅用于辅助功能，实现自动粘贴 -->
    </array>
</dict>
```

**注意：** 这不是强制要求，但可以提高审核通过率。

#### 3. 文件访问权限可能需要扩展
**当前配置：**
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

**检查：** 应用需要写入图片文件到 Application Support 目录，当前沙盒应该已经允许，但建议确认。

**建议：** 如果应用需要导出功能，可能需要添加：
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

---

### 🟢 可选优化

#### 4. 权限请求时机
**当前实现：** 在引导流程中请求权限 ✅

**建议：** 确保在用户真正需要使用功能时才请求权限，当前实现已经很好。

#### 5. 错误处理
**检查：** 代码中有适当的错误处理 ✅

**建议：** 确保所有用户可见的错误都有友好的提示信息。

---

## 📋 App Store Connect 提交检查清单

### 必须填写的信息

1. **应用描述**
   - ✅ 清楚说明应用功能
   - ✅ 说明需要辅助功能权限的原因
   - ✅ 说明数据存储位置（仅本地）

2. **隐私政策链接**
   - ⚠️ 需要提供有效的隐私政策 URL
   - 建议：`https://lemonsstyle.com/pastemine/privacy`

3. **权限使用说明**
   - ✅ 在 App Store Connect 中填写与 Info.plist 一致的说明

4. **应用截图**
   - ⚠️ 需要提供符合要求的截图
   - 建议包含：主界面、设置页面、引导流程

5. **应用分类**
   - 建议：生产力工具 (Productivity)

---

## 🔍 审核重点检查项

### 1. 剪贴板访问 (Guideline 5.1.1)
- ✅ 有明确的用户控制（可关闭）
- ✅ 有隐私过滤机制（忽略敏感应用）
- ✅ 数据仅存储在本地
- ✅ 在 Privacy Manifest 中正确声明

### 2. 辅助功能权限 (Guideline 2.5.9)
- ✅ 仅用于实现自动粘贴功能
- ✅ 有清晰的权限说明
- ✅ 权限缺失时有降级处理

### 3. 数据收集 (Guideline 5.1.2)
- ✅ 所有数据仅用于应用功能
- ✅ 数据不离开设备
- ✅ 在 Privacy Manifest 中正确声明

### 4. 沙盒要求 (Guideline 2.5.2)
- ⚠️ 需要修复项目配置中的沙盒设置

---

## 🚀 修复步骤

### 步骤 1: 修复沙盒配置
```bash
# 在 Xcode 中：
1. 打开项目
2. 选择 PasteMine Target
3. Signing & Capabilities > App Sandbox (确保已启用)
4. 重新构建项目
```

### 步骤 2: 验证构建
```bash
# 使用 Release 配置构建
xcodebuild -project PasteMine.xcodeproj \
  -scheme PasteMine \
  -configuration Release \
  -derivedDataPath build
```

### 步骤 3: 验证沙盒
```bash
# 检查 entitlements
codesign -d --entitlements - PasteMine.app
```

### 步骤 4: 准备提交
1. 创建 App Store Connect 记录
2. 上传构建版本
3. 填写应用信息
4. 提交审核

---

## 📝 审核说明模板

在 App Store Connect 的"审核信息"中，可以使用以下说明：

```
应用功能说明：
PasteMine 是一款剪贴板历史管理工具，帮助用户快速访问之前复制的内容。

权限使用说明：
1. 通知权限：用于在用户复制内容时显示通知提醒
2. 辅助功能权限：仅在用户主动选择历史记录并点击粘贴时，模拟 Cmd+V 按键实现自动粘贴
3. 剪贴板访问：仅在用户启用"剪贴板历史记录"功能后，才会记录复制的内容

隐私保护：
- 所有数据仅存储在本地设备，不会上传或分享
- 默认忽略密码管理器等敏感应用
- 用户可随时关闭功能或清空数据
- 支持忽略特定应用和剪贴板类型

测试账号：无需测试账号
```

---

## ✅ 总结

### 符合要求 ✅
- 隐私信息声明完整
- 权限使用说明清晰
- 数据存储安全（仅本地）
- 没有网络请求或第三方 SDK

### 需要修复 ⚠️
- **必须修复：** 项目配置中的沙盒设置不一致
- **建议改进：** 考虑添加辅助功能 API 声明（可选）

### 预计审核结果
修复沙盒配置后，**通过审核的概率很高**。应用遵循了 Apple 的隐私和安全最佳实践。

---

生成时间：2025-12-05
检查版本：PasteMine_Compliance v1.1

