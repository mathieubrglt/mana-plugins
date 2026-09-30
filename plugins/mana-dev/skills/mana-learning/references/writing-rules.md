# Writing and reading rules

## Content

1. **No duplicates.** Before writing, search the existing titles for the
   same lesson. When one covers it, extend or replace that learning; never
   add a second one.
2. **Default to general.** Write the lesson at the widest scope where the
   strategy is still a concrete check.
3. **Generalize one step at a time.** When a step makes the strategy vague,
   keep the previous version.
4. **Stay specific when the lesson is bound to a named thing.** A concrete
   hazard keeps its name ("never run tool X against production; it deleted
   production data"). Strip names, values and tools only when removing them
   does not change the lesson.
5. An incident that yields no checkable directive produces an action item,
   not a learning.

## Form

6. The title is the lesson: a directive with a precise verb (page, verify,
   trace, reject; never handle, ensure, improve).
7. One learning, one lesson. A second lesson gets one `also:` line, marked
   for extraction.
8. Each line at most 20 words. Over budget means under-distilled.
9. One term for one concept across the store; a new term needs a glossary
   entry.
10. `suspected=` is mandatory; write `none` when nothing is unverified.
11. Present tense, active voice.
12. **Literal wording.** No idioms, metaphors or wordplay: every line must
    carry its meaning when read word by word.

## Reading

1. The title is the directive; it applies without the body.
2. Apply a learning only when the situation matches its scope. Do not
   stretch a learning that names a tool or a system to other tools or
   systems.
3. Truncation order under token pressure: title, strategy, learned,
   impact. Titles alone are a valid digest.
4. `suspected=` claims are hypotheses; never restate them as fact.
5. `also:` lines are secondary lessons; apply them with lower confidence.
6. Flag as malformed rather than interpret: a learning that needs incident
   context, or one whose strategy is not a concrete check.
