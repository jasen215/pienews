# PieNews

[English](README.md)


PieNews 是一个使用 Flutter 开发的 RSS 阅读器客户端，基于 The Old Reader 服务。它提供了一个现代化、用户友好的界面来阅读和管理你的 RSS 订阅。

## 功能特点

- 支持 The Old Reader 账号登录和同步
- 支持离线阅读和缓存
- 文章分享功能
- 支持多语言本地化
- 支持图片缓存
- 响应式布局设计
- 支持多平台：iOS、Android、macOS、Linux、Windows、Web

## 技术栈

- Flutter SDK (>=3.0.0)
- Provider 状态管理
- SQLite 本地存储
- HTTP 网络请求
- Flutter HTML 渲染
- 图片缓存管理

## 依赖项

主要依赖包括：
- provider: ^6.0.5 (状态管理)
- http: ^1.1.0 (网络请求)
- shared_preferences: ^2.2.1 (本地存储)
- flutter_html: ^3.0.0-beta.2 (HTML 渲染)
- sqflite: ^2.3.0 (SQLite 数据库)
- cached_network_image: ^3.3.0 (图片缓存)
- url_launcher: ^6.1.14 (URL 处理)
- intl: ^0.19.0 (国际化支持)

## 开始使用

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### 安装步骤

1. 克隆项目代码：
```bash
git clone https://github.com/yourusername/pienews.git
cd pienews
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行项目：
```bash
flutter run
```

## 构建发布版本

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop (Windows/macOS/Linux)
```bash
flutter build <platform> --release
```

## 项目结构

```
lib/
  ├── main.dart              # 应用入口
  ├── models/               # 数据模型
  ├── screens/              # 页面UI
  ├── services/             # 服务层
  ├── widgets/              # 可复用组件
  └── utils/               # 工具类
```

## 贡献指南

欢迎提交 Pull Requests 来改进项目。对于重大更改，请先开 issue 讨论您想要更改的内容。

## 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件

## 联系方式

如果您有任何问题或建议，请开启一个 issue 进行讨论。
