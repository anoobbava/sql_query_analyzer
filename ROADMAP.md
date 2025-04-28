
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

- [ ] Show file and line number where bad queries are called
- [ ] Warn about missing WHERE clauses in JOINs
- [ ] Add hint support (like FORCE INDEX for MySQL)

---

## Version 0.3.0

- [ ] Generate HTML reports
- [ ] Save EXPLAIN + suggestions to disk for audit trails
- [ ] Support query complexity score (1-10)

---

## Version 1.0.0

- [ ] Support MySQL, PostgreSQL, SQLite seamlessly
- [ ] Modular rule engine (easy to add new rules)
- [ ] Publish gem officially
- [ ] Public GitHub open-source release 🚀

---
