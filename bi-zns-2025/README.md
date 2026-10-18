# BI-ZNS: knowledge systems (2025/26)

| Folder | Task | Notes |
|---|---|---|
| [`task1-forward-chaining-rules/`](task1-forward-chaining-rules/) | Rule base for an inference system with forward chaining | Only my rule files (`rules.txt`, `rules2.txt`) are included. The Python inference system was built on the course-provided template and isn't published |
| [`task2-prolog-fityard/`](task2-prolog-fityard/) | FITYard (variant B): a Prolog agent in a 4×4 Wumpus-World-like grid that explores, collects items, avoids traps and stacks crates to reach a key | SWI-Prolog |
| [`task3-fuzzy-expert-system/`](task3-fuzzy-expert-system/) | Fuzzy expert system for the Wisconsin Breast Cancer Diagnostic (WBCD) dataset: linguistic variables, rule base, inference | Expects `data.csv` (WBCD). Package: `fuzzy-expert` |
| [`task4-random-forest-rule-extraction/`](task4-random-forest-rule-extraction/) | Rule extraction from a random forest trained on WBCD, scoring rules and optimizing the rule set on a validation split | Expects `data.csv` (WBCD) |

The WBCD dataset is available from the
[UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/17/breast+cancer+wisconsin+diagnostic).

**Packages:** pandas, numpy, scikit-learn, matplotlib, fuzzy-expert. **Prolog:** SWI-Prolog.
