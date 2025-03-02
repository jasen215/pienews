# Contributing to PieNews

Thank you for your interest in PieNews! We welcome all forms of contributions, including but not limited to:

- Bug reports
- Feature suggestions
- Code improvements
- Documentation improvements

## Development Process

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Ensure your code passes `flutter analyze`
- Write unit tests (where applicable)

## Pull Request Checklist

- [ ] Code has been formatted
- [ ] All tests pass
- [ ] Documentation has been updated
- [ ] Necessary test cases have been added
- [ ] Code style guidelines have been followed

## Issue Reporting

When creating an issue report, please include:

- Clear description of the problem
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment information:
  - Flutter version
  - Dart version
  - Operating system
  - Device information (if applicable)

## Feature Suggestions

When suggesting new features, please:

- Clearly describe the feature
- Explain why the feature would be valuable
- Consider implementation complexity
- Consider backward compatibility

## Branch Strategy

- `main`: Stable release branch
- `develop`: Development branch
- `feature/*`: New feature branches
- `bugfix/*`: Bug fix branches
- `release/*`: Release preparation branches

## Release Process

1. Create `release` branch from `develop`
2. Update version number
3. Update CHANGELOG.md
4. Perform final testing
5. Merge to `main` branch
6. Tag version
7. Merge back to `develop` branch

## Contact

If you have any questions, please reach out through GitHub Issues.
