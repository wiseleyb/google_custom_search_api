require File.dirname(__FILE__) + '/spec_helper'


describe GoogleCustomSearchApi,
  vcr: { record: :new_episodes } do

  context 'general search' do
    it 'returns results' do
      response = GoogleCustomSearchApi.search('poker')
      request = response.queries.request.first

      expect(request.startIndex).to eq(1)
      expect(request['count']).to eq(10)
      expect(request.totalResults.to_i).to be > 1000
    end

    it 'works with empty search' do
      response = GoogleCustomSearchApi.search('asdfowefwoejfowsaa')
      request = response.queries.request.first

      expect(request.totalResults.to_i).to be(0)
    end

    it 'finds second page' do
      response = GoogleCustomSearchApi.search('poker', start: 11)
      request = response.queries.request.first

      expect(request.startIndex).to eq(11)
      expect(request['count']).to eq(10)
      expect(request.totalResults.to_i).to be > 1000
    end

    it 'when it is past 100 results' do
      response = GoogleCustomSearchApi.search('poker', start: 101)

      error = response.error.errors.first
      expect(error.domain).to eq('global')
      expect(error.reason).to eq('invalid')
      expect(error.message).to eq('Invalid Value')
    end
  end
end
