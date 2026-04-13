---
name: analyze:problem
description: Analyze a complex problem — decompose it, apply first-principles thinking, trace root causes, and build a visual model
argument-hint: "<problem description>"
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
---

<objective>
Apply a structured, first-principles-driven analysis to the problem described in `$ARGUMENTS`. Produce a clear, actionable report that goes from raw problem statement to precise understanding to concrete paths forward — with a visual diagram anchoring the analysis.

The core principle: **find the essence, not just the surface**. Strip away analogies, conventions, and inherited assumptions. Rebuild understanding from what is fundamentally and provably true.
</objective>

<process>

## Step 1: Restate the Problem

Rewrite the problem in one precise sentence. Eliminate ambiguity by making the following explicit:
- **Who** is affected
- **What** is actually broken or unclear (symptom vs. problem)
- **Where** (system, context, scope)
- **When** (always, intermittently, since when)
- **What is NOT the problem** (boundary)

If the problem statement is too vague to restate precisely, ask one focused clarifying question and stop. Do not ask multiple questions at once.

## Step 2: First Principles Analysis

Strip away all analogies, conventions, and inherited thinking. Identify what is **fundamentally and provably true** about this problem.

For each assumption embedded in the problem statement, ask: *"Do I know this is true, or am I just accepting it because it seems obvious?"*

Produce:
- **Verified facts** — things that can be directly observed or measured
- **Challenged assumptions** — things that seemed true but, on inspection, might not be
- **Fundamental constraints** — physical, logical, or system-level limits that cannot be changed

## Step 3: Decompose

Break the problem into independent sub-problems. For each:
- Give it a short name
- State what it specifically is
- Note its scope (contained or cross-cutting)

Use this structure:
```
Sub-problem A: <name>
  What: <description>
  Scope: contained | cross-cutting

Sub-problem B: <name>
  ...
```

Analyze each sub-problem independently before looking at interactions.

## Step 4: Root Cause Tracing

For each sub-problem, trace causality using up to 5 levels of "Why":

```
Symptom: <observable effect>
Why 1: <immediate cause>
Why 2: <cause of that cause>
Why 3: ...
Root cause: <the underlying reason that, if fixed, prevents the symptom>
```

Distinguish:
- **Symptoms** — visible effects (what you see)
- **Proximate causes** — direct triggers (what caused it)
- **Root causes** — underlying conditions (why it was possible)

## Step 5: Build a Visual Model

Choose the diagram type based on the problem:
- **Causal chain** → `graph LR` (cause → effect flows)
- **Concept breakdown** → `mindmap` (hierarchical decomposition)
- **System with interactions** → `graph TD` (components + relationships)
- **Process / sequence** → `flowchart TD`

Generate the Mermaid diagram. Use `<br>` for line breaks inside node labels. Ensure valid syntax.

```mermaid
<diagram here>
```

Add a brief legend explaining what the diagram shows.

## Step 6: Reconstruct — Emergent Properties and Tensions

Now zoom back out. After analyzing the parts, describe:
- **Interactions**: how sub-problems affect each other
- **Emergent properties**: effects that only appear when parts combine (not visible in any single sub-problem)
- **Core tension**: what fundamental trade-off or conflict is at the heart of this problem?

This is the section where synthesis happens — the reconstructed understanding should be richer than the original problem statement.

## Step 7: Paths Forward

Based on first principles (not "what others usually do"), propose 2–4 paths forward. For each:

```
### Option <N>: <name>

**Addresses**: which root cause(s) this targets
**Approach**: what to actually do
**Trade-offs**:
  - Pro: ...
  - Con: ...
  - Risk: ...
**First-principles justification**: why this is sound from fundamentals, not convention
```

End with a **Recommendation** — the single option you'd prioritize and why.

</process>

<output-format>
Structure the full output as:

---

## Problem Analysis: <short title>

### 1. Restated Problem
<one precise sentence>

### 2. First Principles
**Verified facts:**
- ...

**Challenged assumptions:**
- ...

**Fundamental constraints:**
- ...

### 3. Decomposition
<sub-problems>

### 4. Root Causes
<causal chains per sub-problem>

### 5. Visual Model
```mermaid
...
```
<legend>

### 6. Synthesis
<interactions, emergent properties, core tension>

### 7. Paths Forward
<options with trade-offs>

**Recommendation**: ...

---
</output-format>

<guidelines>
- Never skip Step 2 (First Principles) — it is what distinguishes this analysis from a surface-level summary
- The diagram must be generated even if simple — visual representation forces structural clarity
- If the problem touches code in the current project, use Read/Glob/Grep to gather relevant context before analyzing
- Keep each step focused; avoid repetition across steps
- If `$ARGUMENTS` is empty, ask the user to describe the problem they want analyzed
</guidelines>
