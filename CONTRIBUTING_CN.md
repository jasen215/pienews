# Contributing to PieNews

感谢您对 PieNews 项目的关注！我们欢迎任何形式的贡献，包括但不限于：

- 报告问题
- 提交功能建议
- 提交代码改进
- 改进文档

## 开发流程

1. Fork 项目仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的改动 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建一个 Pull Request

## 代码风格

- 遵循 [Dart 风格指南](https://dart.dev/guides/language/effective-dart/style)
- 使用 `dart format` 格式化代码
- 确保代码通过 `flutter analyze` 检查
- 编写单元测试（如适用）

## 提交 Pull Request 前的检查清单

- [ ] 代码已经过格式化
- [ ] 所有测试都通过
- [ ] 更新了相关文档
- [ ] 添加了必要的测试用例
- [ ] 遵循了项目的代码风格指南

## 问题报告

创建问题报告时，请包含以下信息：

- 清晰的问题描述
- 复现步骤
- 预期行为
- 实际行为
- 截图（如适用）
- 运行环境信息：
  - Flutter 版本
  - Dart 版本
  - 操作系统
  - 设备信息（如适用）

## 功能建议

提出新功能建议时，请：

- 清晰描述新功能
- 解释为什么这个功能对项目有价值
- 考虑实现复杂度
- 考虑向后兼容性

## 分支策略

- `main`: 稳定版本分支
- `develop`: 开发分支
- `feature/*`: 新功能分支
- `bugfix/*`: 错误修复分支
- `release/*`: 发布准备分支

## 版本发布流程

1. 从 `develop` 创建 `release` 分支
2. 更新版本号
3. 更新 CHANGELOG.md
4. 进行最终测试
5. 合并到 `main` 分支
6. 标记版本号
7. 合并回 `develop` 分支

## 联系方式

如有任何问题，请通过 GitHub Issues 与我们联系。
