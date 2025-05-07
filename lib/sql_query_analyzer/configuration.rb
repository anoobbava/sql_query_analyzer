# frozen_string_literal: true

module SqlQueryAnalyzer
  class Configuration
    attr_accessor :enabled, :logger, :log_level, :environments, :skip_patterns, :min_query_length, :timeout, :explain_type, :analyze_mode

    def initialize
      @enabled = true
      @environments = [:development]
      @log_level = :info
      @logger = Rails.logger if defined?(Rails)
      @skip_patterns = [
        /^explain/i,
        /information_schema/i,
        /pg_/i,
        /schema_migrations/i,
        /active_storage/i,
        /ar_internal_metadata/i,
        /active_record_schema_migrations/i,
        /devise/i,
        /warden/i,
        /current_user/i
      ]
      @min_query_length = 10
      @timeout = 5 # seconds
      @explain_type = :analyze # :analyze or :simple
      @analyze_mode = :async # :sync or :async
    end

    def enabled_for_current_env?
      return false unless enabled
      return true if environments.empty?
      environments.include?(Rails.env.to_sym)
    end

    def should_skip_query?(sql)
      return true if sql.length < min_query_length
      skip_patterns.any? { |pattern| pattern.match?(sql) }
    end

    def explain_command
      case explain_type
      when :analyze
        "EXPLAIN ANALYZE"
      when :simple
        "EXPLAIN"
      else
        "EXPLAIN ANALYZE"
      end
    end
  end
end
