module SqlQueryAnalyzer
  class SequentialScanAdvisor
    def initialize(line_text)
      @line_text = line_text
    end

    def enhanced_message
      table_name, column_names = extract_table_and_columns
      return nil unless table_name

      if column_names.empty?
        return "⚡ Sequential Scan detected on '#{table_name}', but no filter condition found. Likely a full table read (e.g., SELECT *), or small table size makes index use unnecessary."
      end

      missing_indexes = column_names.select do |column|
        !index_exists?(table_name, column)
      end

      if missing_indexes.any?
        "⚡ Sequential Scan detected on '#{table_name}'. Consider adding indexes on: #{missing_indexes.join(', ')}."
      else
        "⚡ Sequential Scan detected on '#{table_name}', but indexes seem to exist. Might be due to low table size or outdated stats."
      end
    end

    private

    def extract_table_and_columns
      # Simplified pattern: "Seq Scan on users  (cost=...)"
      if @line_text =~ /Seq Scan on (\w+)/
        table_name = $1
        columns = extract_filter_columns(@line_text)
        [table_name, columns]
      else
        [nil, []]
      end
    end

    def extract_filter_columns(text)
      # Example EXPLAIN line might include: "Filter: (email = 'x')"
      text.scan(/Filter: \((.*?)\)/).flatten
          .flat_map { |f| f.scan(/\b(\w+)\s*=/) }
          .flatten
    end

    def index_exists?(table_name, column)
      ActiveRecord::Base.connection.indexes(table_name).any? do |idx|
        idx.columns.include?(column)
      end
    rescue => e
      false # Assume false in case of table missing or dev env differences
    end
  end
end
