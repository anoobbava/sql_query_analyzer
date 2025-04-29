# SqlQueryAnalyzer

[![Gem Version](https://badge.fury.io/rb/sql_query_analyzer.svg)](https://badge.fury.io/rb/sql_query_analyzer)

Analyze your ActiveRecord queries easily with EXPLAIN and smart optimization suggestions. 🚀

---

## Installation

Add this line to your Gemfile:

```ruby
gem 'sql_query_analyzer'
```

And then execute:

```ruby
bundle install
```

Or install it manually:

```
gem install sql_query_analyzer
```

Need to create a new file in the config/initializers/sql_query_analyzer.rb


## Usage
In your Rails console or app:

```ruby
User.where(active: true).explain_with_suggestions

```


✅ You will get:

- Full EXPLAIN ANALYZE plan

- Smart suggestions like:
    - Missing JOIN conditions
    - Sorting without indexes
    - High row scan warnings


### Why Use This Gem?

- Save time analyzing slow queries
- Instant smart hints
- Improve database performance faster
- Beginner-friendly explanations


### Example Output

```mathematica
=== EXPLAIN ANALYZE OUTPUT ===
Seq Scan on users ...

=== SUGGESTIONS ===
[CRITICAL] ⚡ Sequential Scan detected. Consider adding indexes.
[WARNING] 🚨 Query uses SELECT *. Select only needed columns.
```

## Roadmap
For a detailed roadmap, visit [our GitHub Pages roadmap](https://github.com/anoobbava/sql_query_analyzer/blob/master/ROADMAP.md).