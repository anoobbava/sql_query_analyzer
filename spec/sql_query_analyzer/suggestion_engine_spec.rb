# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQueryAnalyzer::SuggestionEngine do
  let(:explain_output) do
    [
      { "QUERY PLAN" => "Seq Scan on users (cost=0.00..10.00 rows=100 width=4)" }
    ]
  end
  let(:sql) { "SELECT * FROM users" }
  let(:engine) { described_class.new(explain_output, sql) }

  describe '#analyze' do
    before do
      allow(SqlQueryAnalyzer::SuggestionRules).to receive(:all).and_return([
        {
          matcher: ->(line) { line.include?('Seq Scan') },
          severity: :warning,
          message: 'Sequential Scan detected'
        }
      ])
      allow(SqlQueryAnalyzer::SqlLevelRules).to receive(:evaluate).and_return([])
      allow(SqlQueryAnalyzer::SequentialScanAdvisor).to receive(:new).and_return(
        instance_double(SqlQueryAnalyzer::SequentialScanAdvisor, enhanced_message: 'Consider adding an index')
      )
      allow(SqlQueryAnalyzer::QueryPlanPresenter).to receive(:new).and_return(
        instance_double(SqlQueryAnalyzer::QueryPlanPresenter, display: nil)
      )
      allow(SqlQueryAnalyzer::QueryPlanPresenter).to receive(:classify_cost).and_return(:high)
    end

    it 'processes explain output and generates suggestions' do
      expect(SqlQueryAnalyzer::SuggestionRules).to receive(:all)
      expect(SqlQueryAnalyzer::SqlLevelRules).to receive(:evaluate).with(sql)
      expect(SqlQueryAnalyzer::SequentialScanAdvisor).to receive(:new)
      expect(SqlQueryAnalyzer::QueryPlanPresenter).to receive(:new)
      expect(SqlQueryAnalyzer::QueryPlanPresenter).to receive(:classify_cost)

      engine.analyze
    end

    it 'extracts cost and row estimates' do
      allow(SqlQueryAnalyzer::QueryPlanPresenter).to receive(:new) do |args|
        expect(args[:total_cost]).to eq(10.0)
        expect(args[:rows_estimate]).to eq(100)
        instance_double(SqlQueryAnalyzer::QueryPlanPresenter, display: nil)
      end

      engine.analyze
    end

    it 'handles sequential scan suggestions' do
      allow(SqlQueryAnalyzer::SequentialScanAdvisor).to receive(:new).and_return(
        instance_double(SqlQueryAnalyzer::SequentialScanAdvisor, enhanced_message: 'Consider adding an index')
      )

      expect(SqlQueryAnalyzer::QueryPlanPresenter).to receive(:new) do |args|
        expect(args[:warnings].first[:suggestion].message).to eq('Consider adding an index')
        instance_double(SqlQueryAnalyzer::QueryPlanPresenter, display: nil)
      end

      engine.analyze
    end

    context "when sequential scan is not detected" do
      let(:explain_output) do
        [
          { "QUERY PLAN" => "Index Scan on users (cost=0.00..10.00 rows=100 width=4)" }
        ]
      end

      it "uses the default message from the rule" do
        warnings = engine.analyze
        expect(warnings.none? { |w| w[:suggestion].message.include?("Sequential Scan") }).to be true
      end
    end

    context "when sequential scan advisor returns nil" do
      before do
        allow(SqlQueryAnalyzer::SequentialScanAdvisor).to receive(:new).and_return(
          instance_double(SqlQueryAnalyzer::SequentialScanAdvisor, enhanced_message: nil)
        )
      end

      it "uses the default message from the rule" do
        warnings = engine.analyze
        expect(warnings.any? { |w| w[:suggestion].message.include?("Sequential Scan detected") }).to be true
      end
    end
  end
end

RSpec.describe SqlQueryAnalyzer::Suggestion do
  describe '#to_s' do
    it 'formats the suggestion with severity and message' do
      suggestion = described_class.new(:warning, 'Test message')
      expect(suggestion.to_s).to eq('[WARNING] Test message')
    end
  end
end 