# frozen_string_literal: true

require "spec_helper"

RSpec.describe SqlQueryAnalyzer::QueryPlanPresenter do
  let(:output) { ["Line 1", "Line 2"] }
  let(:warnings) do
    [
      {
        line_number: 1,
        line_text: "Warning line",
        suggestion: SqlQueryAnalyzer::Suggestion.new(:warning, "Test warning")
      }
    ]
  end
  let(:total_cost) { 100.0 }
  let(:rows_estimate) { 1000 }
  let(:actual_time) { 50.0 }
  let(:output_stream) { StringIO.new }
  let(:presenter) do
    described_class.new(
      output: output,
      warnings: warnings,
      total_cost: total_cost,
      rows_estimate: rows_estimate,
      actual_time: actual_time,
      output_stream: output_stream
    )
  end

  describe "#display" do
    it "displays query plan with line numbers" do
      presenter.display
      output_text = strip_ansi(output_stream.string)
      expect(output_text).to include("QUERY PLAN")
      expect(output_text).to include("1: Line 1")
      expect(output_text).to include("2: Line 2")
    end

    it "displays query metrics" do
      presenter.display
      output_text = strip_ansi(output_stream.string)
      expect(output_text).to include("Query Metrics")
      expect(output_text).to include("Total Cost: 100.0")
      expect(output_text).to include("Rows Estimate: 1000")
      expect(output_text).to include("Actual Time: 50.0 ms")
    end

    it "displays warnings when present" do
      presenter.display
      output_text = strip_ansi(output_stream.string)
      expect(output_text).to include("Warnings and Suggestions")
      expect(output_text).to include("Line 1: Warning line")
      expect(output_text).to include("[WARNING] Test warning")
    end

    context "when no warnings are present" do
      let(:warnings) { [] }

      it "displays success message" do
        presenter.display
        output_text = strip_ansi(output_stream.string)
        expect(output_text).to include("No immediate problems detected")
      end
    end
  end

  describe ".classify_cost" do
    it "classifies low cost" do
      described_class.classify_cost(100, output_stream: output_stream)
      output_text = strip_ansi(output_stream.string)
      expect(output_text).to include("Query cost is LOW")
    end

    it "classifies moderate cost" do
      described_class.classify_cost(500, output_stream: output_stream)
      output_text = strip_ansi(output_stream.string)
      expect(output_text).to include("Query cost is MODERATE")
    end

    it "classifies high cost" do
      described_class.classify_cost(1500, output_stream: output_stream)
      output_text = strip_ansi(output_stream.string)
      expect(output_text).to include("Query cost is HIGH")
    end

    it "handles nil cost" do
      described_class.classify_cost(nil, output_stream: output_stream)
      expect(output_stream.string).to be_empty
    end
  end

  describe "private methods" do
    describe "#colorize_by_severity" do
      it "colorizes critical suggestions" do
        suggestion = SqlQueryAnalyzer::Suggestion.new(:critical, "Test critical")
        expect(strip_ansi(presenter.send(:colorize_by_severity, suggestion))).to include("Test critical")
      end

      it "colorizes warning suggestions" do
        suggestion = SqlQueryAnalyzer::Suggestion.new(:warning, "Test warning")
        expect(strip_ansi(presenter.send(:colorize_by_severity, suggestion))).to include("Test warning")
      end

      it "colorizes info suggestions" do
        suggestion = SqlQueryAnalyzer::Suggestion.new(:info, "Test info")
        expect(strip_ansi(presenter.send(:colorize_by_severity, suggestion))).to include("Test info")
      end

      it "handles unknown severity" do
        suggestion = SqlQueryAnalyzer::Suggestion.new(:unknown, "Test unknown")
        expect(strip_ansi(presenter.send(:colorize_by_severity, suggestion))).to eq("[UNKNOWN] Test unknown")
      end
    end
  end

  private

  def strip_ansi(text)
    text.gsub(/\e\[\d+m/, "")
  end
end 