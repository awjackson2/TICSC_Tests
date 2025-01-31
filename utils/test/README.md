# CI/CD Pipeline Documentation

This repository uses **CircleCI** for continuous integration and continuous delivery (CI/CD). The system automates building and testing the code, ensuring that every commit and pull request is validated before merging.

---

## Table of Contents
1. [Overview](#overview)  
2. [Pipeline Stages](#pipeline-stages)   
3. [Docker Image](#docker-image)  
4. [Running Locally](#running-locally)  
---

## Overview

- **Purpose**: Provide automated checks (build, tests, cleanup) to maintain code quality.  
- **Tool**: [CircleCI](https://circleci.com/) for orchestration.  
- **Triggers**:
  - Pull requests targeting `main` or feature branches.
  - Commits to specific branches (e.g., `main`, `feature/...`).

- **Key Components**:
  - **`.circleci/config.yml`**: Main pipeline definition.
  - **`Dockerfile`**: Defines the testing environment.
  - **Scripts** (e.g., `free_disk_space.sh`): Utilities to manage disk usage in CI.

---

## Pipeline Stages

1. **Checkout**  
   Pulls the latest code from the repository.

2. **Environment Setup**  
   Uses a **machine** executor (full VM) to run Docker and verifies Docker is running.

3. **Build Docker Image**  
   Builds the testing Docker image (`ticsctests:latest`) from the project’s `Dockerfile`.

4. **Run Tests**  
   - Executes unit tests (e.g., Python, Bash tests).
   - Executes integration tests that might require MATLAB Runtime or SimNIBS.

5. **Cleanup**  
   - Frees disk space with `free_disk_space.sh`.
   - Prunes Docker images to save space if necessary.

You can review the detailed steps in **`.circleci/config.yml`**.


---

## Docker Image

- The **Dockerfile** (in `utils/test/docker/Dockerfile`) installs dependencies needed for the tests:
  - Python & libraries (Pytest, BATS, etc.)
  - MATLAB Runtime
  - SimNIBS
  - Other required system packages
- **Tagged** as `ticsctests:latest` during the build step in CircleCI.

---

### Local Build

If you want to build the image locally:

```bash
# From the repository root
docker build -f utils/test/docker/Dockerfile -t ticsctests:local .