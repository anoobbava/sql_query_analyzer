# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQueryAnalyzer::SuggestionRules do
  describe '.all' do
    let(:rules) { described_class.all }

    it 'returns an array of rules' do
      expect(rules).to be_an(Array)
      expect(rules).not_to be_empty
    end

    it 'each rule has required attributes' do
      rules.each do |rule|
        expect(rule).to have_key(:matcher)
        expect(rule).to have_key(:severity)
        expect(rule).to have_key(:message)
      end
    end

    describe 'rule matchers' do
      it 'detects Sequential Scan' do
        rule = rules.find { |r| r[:message].include?('Sequential Scan') }
        expect(rule[:matcher].call('Seq Scan on users')).to be true
        expect(rule[:severity]).to eq(:critical)
      end

      it 'detects Nested Loop' do
        rule = rules.find { |r| r[:message].include?('Nested Loop') }
        expect(rule[:matcher].call('Nested Loop')).to be true
        expect(rule[:severity]).to eq(:warning)
      end

      it 'detects Bitmap Heap Scan' do
        rule = rules.find { |r| r[:message].include?('Bitmap Heap Scan') }
        expect(rule[:matcher].call('Bitmap Heap Scan')).to be true
        expect(rule[:severity]).to eq(:info)
      end

      it 'detects Materialize' do
        rule = rules.find { |r| r[:message].include?('Materialize') }
        expect(rule[:matcher].call('Materialize')).to be true
        expect(rule[:severity]).to eq(:warning)
      end

      it 'detects Hash Join' do
        rule = rules.find { |r| r[:message].include?('Hash Join') }
        expect(rule[:matcher].call('Hash Join')).to be true
        expect(rule[:severity]).to eq(:info)
      end

      it 'detects Merge Join' do
        rule = rules.find { |r| r[:message].include?('Merge Join') }
        expect(rule[:matcher].call('Merge Join')).to be true
        expect(rule[:severity]).to eq(:info)
      end

      it 'detects CTE usage' do
        rule = rules.find { |r| r[:message].include?('CTE usage') }
        expect(rule[:matcher].call('WITH users AS (SELECT * FROM users)')).to be true
        expect(rule[:severity]).to eq(:info)
      end
    end

    it 'has unique messages' do
      messages = rules.map { |r| r[:message] }
      expect(messages.uniq.size).to eq(messages.size)
    end

    it 'has valid severity levels' do
      valid_severities = %i[critical warning info]
      rules.each do |rule|
        expect(valid_severities).to include(rule[:severity])
      end
    end
  end
end
