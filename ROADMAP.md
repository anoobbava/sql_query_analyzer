
---
# 🛣 `ROADMAP.md` (Feature Roadmap)

```markdown
# SqlQueryAnalyzer - Roadmap

---

## Version 0.1.0

- [x] Explain ActiveRecord queries
- [x] Suggest improvements based on query plan
- [x] Catch common bad practices (SELECT *, missing indexes)

---

## Version 0.2.0

- [x] We need to have an opton to run only the Explain or Explain Analyze alone
- [x] Need to Expand the rules and need to think of how we can do that effectively
- [x] Show file and line number where bad queries are called
- [x] Warn about missing WHERE clauses in JOINs
- [x] check the hinting of indexes and add the index option needed also check the indexes already exists in the code
- [x] composite indices and thier existence is there or not

---

## Version 0.3.0

- [ ] Generate HTML reports
- [ ] Save EXPLAIN + suggestions to disk for audit trails
- [ ] Support query complexity score (1-10)

---

## Version 1.0.0
- [ ] Add hint support (like FORCE INDEX for MySQL)
- [ ] Support MySQL, PostgreSQL, SQLite seamlessly
- [ ] Modular rule engine (easy to add new rules)
- [ ] Publish gem officially
- [ ] Public GitHub open-source release 🚀

---
