# CI/CD Pipeline For Budget Buddy App Documentation
This document outlines the Continuous Integration (CI) pipeline set up using GitLab CI/CD for our project "Budget Buddy". The pipeline is designed to ensure code quality, successful builds, and test coverage by automating static analysis, build, and test processes using GitLab Runners.

---

## 🔧 Tools Used

- **GitLab CI/CD**: Automation platform for continuous integration and deployment.
- **Flutter**: Framework for building cross-platform applications.
- **Static Analysis**: `flutter analyze` for Dart code linting and code style enforcement.
- **Build**: `flutter build` for compiling the application for Linux.
- **Testing**: `flutter test` for running unit tests.

---

## 📦 Pipeline Stages and Flow

The pipeline consists of three sequential stages:

### 1. **Static Analysis**
- **Purpose**: Ensure code quality and prevent problematic code from entering main branches.
- **Key Actions**:
  - Install dependencies.
  - Run static analyzer via `flutter analyze --no-pub`.
- **Failure Handling**: Pipeline fails if analysis reports critical issues.

### 2. **Build**
- **Purpose**: Compile the application for Linux targets.
- **Key Actions**:
  - Execute `flutter build linux --release`.
  - Output the compiled bundle as an artifact for traceability and future stages.
- **Artifacts**:
  - Linux release build saved to: `build/linux/x64/release/bundle`.

### 3. **Testing**
- **Purpose**: Run test suite to validate application correctness.
- **Key Actions**:
  - Execute `flutter test --coverage`.
  - This command runs all tests and generates a lcov.info file in the coverage/ directory.
  - Execute `genhtml coverage/lcov.info -o coverage/html`.
  - This command converts the lcov.info into a browsable HTML report in the coverage/html directory.
  - Open the following file in the browser `coverage/html/index.html`.




---

## 🚀 Trigger Conditions

The CI pipeline is configured to automatically run under the following conditions:

- On **merge requests**.
- On **commits to the any branch**.

This ensures code quality and correctness are validated before integration.

---

## 🧪 Running the Pipeline Locally

To mimic CI behavior locally, ensure the following:

1. **Install Flutter and dependencies**:
   ```bash
   flutter doctor
   flutter pub get
   ```

2. **Run static analysis**:
   ```bash
   flutter analyze
   ```

3. **Build the application**:
   ```bash
   flutter build linux --release
   ```

4. **Run tests**:
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

Note: Local environment must match the containerized CI environment as closely as possible for consistent results.

---

## 🛠️ Troubleshooting

| Issue                      | Possible Cause                    | Resolution                                     |
|---------------------------|------------------------------------|------------------------------------------------|
| `flutter analyze` fails   | Code quality violations            | Fix linting issues shown in CI logs.           |
| Build fails               | Missing dependencies or code errors | Verify build locally with `flutter build`.     |
| Tests fail                | Assertion errors or failed expectations | Review test logs, fix failed tests, rerun locally. |


---

