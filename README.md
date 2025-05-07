# SqlQueryAnalyzer

[![Gem Version](https://badge.fury.io/rb/sql_query_analyzer.svg)](https://badge.fury.io/rb/sql_query_analyzer)
[![Code Coverage](https://img.shields.io/badge/coverage-99.4%25-brightgreen)](https://github.com/anoobbava/sql_query_analyzer)
[![Branch Coverage](https://img.shields.io/badge/branch%20coverage-80.7%25-yellow)](https://github.com/anoobbava/sql_query_analyzer)

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

Create an initializer file at `config/initializers/sql_query_analyzer.rb`:

```ruby
SqlQueryAnalyzer.configure do |config|
  # Enable/disable the analyzer
  config.enabled = true

  # Specify which environments to run in (default: [:development])
  config.environments = [:development]

  # Set the log level (default: :info)
  config.log_level = :info
end
```

## Usage

### Automatic Query Monitoring

The gem automatically monitors all ActiveRecord queries in your application and logs suggestions to your Rails logger. No additional code is needed!

Example log output:
```
=== SQL Query Analysis ===
Query: SELECT * FROM users WHERE active = true
Warnings:
  - [CRITICAL] Sequential Scan detected. Consider adding an index on users(active)
  - [WARNING] Query uses SELECT *. Select only needed columns.
=======================
```

### Manual Analysis

You can also analyze specific queries manually:

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

- Automatic monitoring of all queries
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

### Example Output using dummy queries

Here is an example of the output response from the Gem:

![Query Response](assets/response.png)

## Code Coverage

The project maintains high test coverage to ensure reliability:

- **Line Coverage**: 99.4% (167/168 lines)
- **Branch Coverage**: 80.7% (46/57 branches)

Coverage is measured using SimpleCov and is checked on every pull request.

## Roadmap
For a detailed roadmap, visit [our GitHub Pages roadmap](https://github.com/anoobbava/sql_query_analyzer/blob/master/ROADMAP.md).