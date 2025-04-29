module SqlQueryAnalyzer
  class Suggestion
    attr_reader :severity, :message

    def initialize(severity, message)
      @severity = severity
      @message = message
    end

    def to_s
      "[#{severity.to_s.upcase}] #{message}"
    end
  end

  class SuggestionEngine
    RULES = [
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

    def initialize(explain_output, sql = nil)
      @explain_output = explain_output
      @sql = sql
    end

    def analyze
      output = []
      warnings = []
      total_cost, rows_estimate, actual_time = nil

      @explain_output.each_with_index do |row, idx|
        line = row["QUERY PLAN"]
        output << line

        # Extract cost and rows
        if line =~ /cost=\d+\.\d+\.\.(\d+\.\d+) rows=(\d+)/
          total_cost = $1.to_f
          rows_estimate = $2.to_i
        end

        # Extract actual execution time
        actual_time ||= $1.to_f if line =~ /actual time=(\d+\.\d+)/

        RULES.each do |rule|
          if rule[:matcher].call(line)
            warnings << {
              line_number: idx + 1,
              line_text: line,
              suggestion: Suggestion.new(rule[:severity], rule[:message])
            }
          end
        end
      end

      # SQL based suggestions (outside EXPLAIN)
      sql_warnings = sql_level_warnings
      warnings.concat(sql_warnings)

      display_results(output, warnings, total_cost, rows_estimate, actual_time)

      classify_query_cost(total_cost)
    end

    private

    def sql_level_warnings
      warnings = []

      if @sql&.match?(/select\s+\*/i)
        warnings << {
          line_number: 'N/A',
          line_text: 'SELECT *',
          suggestion: Suggestion.new(:warning, "🚨 Query uses SELECT *. Specify only needed columns for performance.")
        }
      end

      if @sql&.match?(/join/i) && !@sql.match?(/on/i)
        warnings << {
          line_number: 'N/A',
          line_text: 'JOIN without ON',
          suggestion: Suggestion.new(:critical, "⚡ JOIN without ON detected. May cause massive row combinations (CROSS JOIN).")
        }
      end

      warnings
    end

    def display_results(output, warnings, total_cost, rows_estimate, actual_time)
      puts "\n🔍 QUERY PLAN:"
      output.each_with_index { |line, idx| puts "  #{idx + 1}: #{line}" }

      puts "\n💰 Total Cost: #{total_cost}" if total_cost
      puts "📈 Rows Estimate: #{rows_estimate}" if rows_estimate
      puts "⏱️  Actual Time: #{actual_time} ms" if actual_time

      if warnings.any?
        puts "\n🚩 Warnings and Suggestions:"
        warnings.each do |warn|
          puts "  Line #{warn[:line_number]}: #{warn[:line_text]}"
          puts "    👉 #{warn[:suggestion]}"
        end
      else
        puts "\n✅ No immediate problems detected in the query plan."
      end
    end

    def classify_query_cost(total_cost)
      return unless total_cost

      case total_cost
      when 0..300
        puts "\n✅ Query cost is LOW. All good!"
      when 301..1000
        puts "\n🧐 Query cost is MODERATE. May benefit from optimizations."
      else
        puts "\n🛑 Query cost is HIGH. Recommend tuning immediately!"
      end
    end
  end
end
