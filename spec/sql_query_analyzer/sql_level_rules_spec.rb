# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQueryAnalyzer::SqlLevelRules do
  describe '.evaluate' do
    context 'when sql is nil' do
      it 'returns an empty array' do
        expect(described_class.evaluate(nil)).to be_empty
      end
    end

    context 'when sql contains SELECT *' do
      let(:sql) { 'SELECT * FROM users' }

      it 'returns a warning about SELECT *' do
        warnings = described_class.evaluate(sql)
        expect(warnings.size).to eq(1)
        expect(warnings.first[:line_text]).to eq('SELECT *')
        expect(warnings.first[:suggestion].message).to include('Query uses SELECT *')
      end
    end

    context 'when sql contains JOIN without ON' do
      let(:sql) { 'SELECT * FROM users JOIN posts' }

      it 'returns a warning about JOIN without ON' do
        warnings = described_class.evaluate(sql)
        expect(warnings.size).to eq(2) # One for SELECT * and one for JOIN
        join_warning = warnings.find { |w| w[:line_text] == 'JOIN without ON' }
        expect(join_warning[:suggestion].message).to include('JOIN without ON detected')
      end
    end

    context 'when sql contains JOIN with ON' do
      let(:sql) { 'SELECT * FROM users JOIN posts ON users.id = posts.user_id' }

      it 'does not return a warning about JOIN' do
        warnings = described_class.evaluate(sql)
        expect(warnings.size).to eq(1) # Only the SELECT * warning
        expect(warnings.first[:line_text]).to eq('SELECT *')
      end
    end

    context 'when sql is well-formed' do
      let(:sql) { 'SELECT id, name FROM users JOIN posts ON users.id = posts.user_id' }

      it 'returns no warnings' do
        expect(described_class.evaluate(sql)).to be_empty
      end
    end
  end
end
