module SqlQueryAnalyzer
  class SequentialScanAdvisor
    attr_reader :query_plan

    def initialize(query_plan)
      @query_plan = query_plan
    end

    def enhanced_message
      table_name, column_names = extract_table_and_columns

      return nil unless sequential_scan_detected?

      if column_names.empty?
        return "👉 [CRITICAL] ⚡ Sequential Scan detected on '#{table_name}', " \
               "but no filter condition found. Likely a full table read " \
               "(e.g., SELECT *), or small table size makes index use unnecessary."
      end

      messages = []
      messages << "👉 [CRITICAL] ⚡ Sequential Scan detected on '#{table_name}', " \
                  "and filter involves columns: #{column_names.join(', ')}."
      if missing_composite_index?(table_name, column_names)
        messages << "💡 Consider adding a composite index on: #{column_names.join(', ')}"
      end
      messages.join("\n")
    end

    private

    def sequential_scan_detected?
      query_plan.include?("Seq Scan on")
    end

    def extract_table_and_columns
      table_name = query_plan.match(/Seq Scan on (\w+)/)&.captures&.first
      [ table_name, extract_columns_from_filter ]
    end

    def extract_columns_from_filter
      # Grab the Filter line out of the full plan
      filter_line = query_plan.lines.find { |l| l.strip.start_with?("Filter:") }
      return [] unless filter_line

      # Remove the "Filter:" prefix and any Postgres typecasts
      cleaned = filter_line
                  .sub("Filter:", "")
                  .gsub(/::[a-zA-Z_ ]+/, "")
                  .downcase

      # Pull actual column names for this table from the schema
      table_name = query_plan.match(/Seq Scan on (\w+)/)&.captures&.first
      return [] unless table_name
      schema_cols = ActiveRecord::Base
                      .connection
                      .columns(table_name.to_sym)
                      .map(&:name)
                      .map(&:downcase)

      # Of all schema columns, pick those mentioned in the cleaned filter
      extracted = schema_cols.select { |col| cleaned.include?(col) }.uniq
      extracted
    end

    def missing_composite_index?(table_name, columns)
      existing = ActiveRecord::Base
                   .connection
                   .indexes(table_name.to_sym)
                   .map(&:columns)
                   .map { |cols| cols.map(&:downcase) }

      !existing.any? { |idx_cols| idx_cols == columns || idx_cols.first(columns.length) == columns }
    end
  end
end
