---
description: Token Optimization Workflow & Automatic Prompt Refinement
---

# Token & Prompt Optimization Workflow

This workflow dictates how the Antigravity Agent should handle initial, vague, or conversational user requests to maximize token efficiency and execute tasks precisely.

## 1. Internal Prompt Refinement Protocol

When the User provides a vague or conversational request (e.g., "build me a login screen", "optimise my code"):

1. **Analyze:** Do not immediately generate long code files.
2. **Optimize Internally:** The Agent must mentally convert the request into a strict requirement set structure before executing. The agent _may_ use the `bubobot-optimizer` to generate an execution plan for complex tasks, rather than outputting massive, unrefined code blobs.
3. **Execute Concisely:** Only output the absolute necessary diffs or file creations. Do not output entire unmodified files or massive explanation blocks. The goal is saving output tokens.

## 2. Recommended User Templates (Token Efficient)

To get the best performance with fewer tokens consumed, Users should format their requests to the Agent bypassing conversational structure entirely:

### Code Generation Template

```text
Task: [Create Widget X]
Reqs:
- Lang: [Dart/Flutter]
- Constraints: [No stateful widgets, use AppTheme]
- Output: Exact file changes only.
```

### Debugging Template

```text
Error: [Pasted Log Snippet]
File Location: [lib/screens/x.dart:25]
Goal: Identify exact crash root cause and provide only the diff fix.
```

### Refactoring Template

```text
Task: Refactor [File X]
Goal: Extract modular widgets from monolithic build method. Ensure strict `const` usage.
Output: Diffs only. No explanations.
```
