# Day 5 — GitHub Actions CI Pipeline

## Project Overview

This lab demonstrates how to build a continuous integration (CI) workflow using GitHub Actions and Bash.

The pipeline automatically validates and executes a Linux system health-check script and runs automated tests to verify expected output.

## Technologies Used

- Linux (Ubuntu)
- Bash scripting
- Git and GitHub
- YAML
- GitHub Actions
- Git branching and pull requests

## Project Structure

```text
.github/workflows/day5-ci.yaml
day5-cicd/
├── README.md
├── config.yaml
├── health-check.sh
└── tests/
    └── test-health-check.sh
```

The workflow YAML file is stored at the repository root under `.github/workflows/`.

`config.yaml` was created for YAML syntax practice and is not currently consumed by the pipeline.

## CI Workflow

The GitHub Actions workflow is triggered by:

- Pushes to the `main` branch
- Pull requests targeting `main`
- Manual execution using `workflow_dispatch`

The workflow performs the following steps:

1. Check out repository source code.
2. Validate the health-check script's Bash syntax.
3. Validate the test script's Bash syntax.
4. Execute the health-check script.
5. Run automated tests.

## System Health-Check Script

The `health-check.sh` script displays:

- Hostname
- Current Linux user
- Kernel version
- Root filesystem disk usage
- System memory usage

This script collects system information; it does not yet implement threshold-based health monitoring.

## Automated Testing

The test script checks whether the health-check output contains:

1. The expected heading.
2. The hostname section.
3. The memory usage section.
4. The expected completion message.

The tests return a nonzero exit status when a required output check fails, causing the GitHub Actions testing step to fail.

## Running Locally

Run the following commands from the repository root:

```bash
bash -n day5-cicd/health-check.sh
bash -n day5-cicd/tests/test-health-check.sh
bash day5-cicd/health-check.sh
bash day5-cicd/tests/test-health-check.sh
```

## Troubleshooting Exercise

A deliberate regression was introduced on the `lab5/broken-health-check` branch by changing the expected completion message.

The script retained valid Bash syntax, but the automated test detected the missing expected output and returned exit code `1`.

The resulting pull-request CI run failed during the automated testing step.

The original message was restored, the correction was pushed, and the next GitHub Actions run succeeded.

The training pull request was subsequently closed without merging into `main`.

### CI Evidence

- [Failed CI run — regression detected](https://github.com/Prinstonn/devops-lockin-labs/actions/runs/42261924896)
- [Successful CI run — regression fixed](https://github.com/Prinstonn/devops-lockin-labs/actions/runs/42263340343)
- [Troubleshooting pull request #2](https://github.com/Prinstonn/devops-lockin-labs/pull/2)

## Key Lessons Learned

- How GitHub Actions workflows are triggered
- How runners execute CI jobs
- How YAML defines workflow jobs and steps
- The difference between syntax checks and behavioural tests
- How Bash exit codes influence CI results
- How to investigate failed GitHub Actions workflows
- How Git branches and pull requests support safe testing

## Future Improvements

- Add ShellCheck static analysis.
- Add stronger tests for health-check output and command failures.
- Introduce disk and memory thresholds.
- Configure branch protection with required CI checks.
- Review and update third-party GitHub Actions versions.
