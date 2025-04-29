module SqlQueryAnalyzer
  class SuggestionRules
    def self.all
      [
        {
          matcher: ->(line) { line.include?('Seq Scan') },
          severity: :critical,
          message: "⚡ Sequential Scan detected. Add appropriate indexes to avoid full table scans."
        },
        {
          matcher: ->(line) { line.include?('Nested Loop') },
          severity: :warning,
          message: "🌀 Nested Loop detected. Ensure JOINs are optimized and indexed."
        },
        {
          matcher: ->(line) { line.include?('Bitmap Heap Scan') },
          severity: :info,
          message: "📦 Bitmap Heap Scan used. Acceptable but check if an index-only scan is possible."
        },
        {
          matcher: ->(line) { line.include?('Materialize') },
          severity: :warning,
          message: "📄 Materialize detected. May cause extra memory usage if result sets are large."
        },
        {
          matcher: ->(line) { line.include?('Hash Join') },
          severity: :info,
          message: "🔗 Hash Join used. Generally fast for large datasets, but check hash table memory usage."
        },
        {
          matcher: ->(line) { line.include?('Merge Join') },
          severity: :info,
          message: "🔀 Merge Join used. Efficient if input is sorted properly; check indexes."
        },
        {
          matcher: ->(line) { line.downcase.include?('cte') || line.downcase.include?('with') },
          severity: :info,
          message: "🔧 CTE usage detected. Be aware CTEs can materialize (costly) in Postgres < 12."
        }
      ]
    end
  end
end
