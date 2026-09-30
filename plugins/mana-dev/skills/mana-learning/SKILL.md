---
name: mana-learning
description: Write, gate, and store durable learnings in Mana through the MCP tools. One learning is a title and four lines under a stable learning/ memory key, admitted only after a fresh-agent gate. Use after an incident, after a measured result, and before a session closes or compacts.
---

# Mana learning discipline

A good learning captures a reusable lesson from an observed problem. It is
precise enough to act on and survives the loss of its original context.
Store each one in Mana, as a memory under a stable `learning/` key.

## Format

```
<title: imperative rule, at most 10 words>
learned: <why the rule holds, one line>
impact: confirmed=<observed effects> | suspected=<unverified effects or none>
strategy: <the concrete check or action, one line>
scope: <the conditions the lesson needs, only when it needs any>
```

Titles are unique across the store. `suspected=` is mandatory; write `none`
when nothing is unverified. Check a draft with
`python3 scripts/check_learning.py <file>` before you store it: it names
every missing line and every line past the budget.

The rules behind the format, and how to read a learning, are in
`references/writing-rules.md`. The four learnings that govern the corpus
itself are in `references/meta-learnings.md`.

## Admission gate

Run the gate with a fresh agent that has no write access, no incident
context, and a small context window (in Claude Code: one Agent call, a small
model, "do not use any tools", "answer in at most three sentences").

1. Give the agent a short scenario that matches the problem, plus the
   learning. Ask: "what do you do?"
2. Admit when the agent's answer follows the learning.
3. Stronger, when it matters: run the scenario without the learning, and
   admit only when the learning changed the answer.

A learning the agent cannot act on from its lines alone is rejected. An
incident that yields no checkable directive is an action item, not a
learning.

## Store through the MCP tools

1. Search first: `mana_search` for the lesson's terms, or `mana_memory_list`
   with `memoryKeyPrefix: learning/`. When one covers it, revise that one.
2. Derive a short kebab-case slug from the title.
3. New learning: `mana_remember_interaction` with `interactionId`
   `learning-<date>-<slug>`, `memoryType: case`, the title as `title`, the
   lines exactly as `text` (title first), and `memoryKey: learning/<slug>`.
4. Revision: the same `memoryKey`, the revised lines, and a `changeReason`.
   Mana keeps the prior version.
5. Read `quality` in the result. `probable_duplicate` means another key
   holds this lesson: merge the two into the older key with a
   `changeReason`, and dismiss the newer one.
6. Verify with one `mana_search` for a distinctive term. A store without a
   verified retrieval is not complete.

## Glossary and highlight

The glossary is one memory under `learning/glossary`, memory type
`entity_state`, one line per term: `term: definition`. A learning that
introduces a term adds it in the same session, with a `changeReason`.
Each project keeps one `highlight/<project>` memory of at most 200 words:
what the store holds, how to query it, and what belongs in it. The standing
instructions carry both to every agent, in a bounded space, so keep them
short.

## Cadence

- After an incident, a measured result, or a design decision: distill,
  gate, and store the learning before the task closes.
- Before a session closes or compacts: sweep it for undistilled lessons,
  store the admitted ones, and record the rest as action items.
- At session start: the standing instructions carry every active learning
  title. A title that matches the situation is the rule; its body is one
  `mana_memory_list` call by key.

Never store a secret, a credential, or personal data in a learning.
