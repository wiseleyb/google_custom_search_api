require File.dirname(__FILE__) + '/spec_helper'

describe GoogleCustomSearchApi, vcr: true do
  context 'general search' do
    it 'returns results' do
      VCR.use_cassette('poker_search', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker')
        request = response.queries.request.first

        expect(request.startIndex).to eq(1)
        expect(request['count']).to eq(10)
        expect(request.totalResults.to_i).to be > 1000
      end
    end

    it 'works with empty search' do
      VCR.use_cassette('search-no-results', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('asdfowefwoejfowsaa')
        request = response.queries.request.first

        expect(request.totalResults.to_i).to be(0)
      end
    end

    it 'finds second page' do
      VCR.use_cassette('poker_search-start-11', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker', start: 11)
        request = response.queries.request.first

        expect(request.startIndex).to eq(11)
        expect(request['count']).to eq(10)
        expect(request.totalResults.to_i).to be > 1000
      end
    end

    it 'when it is past 100 results' do
      VCR.use_cassette('search-error-invalid',
                       record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker', start: 101)

        error = response.error.errors.first
        expect(error.domain).to eq('global')
        expect(error.reason).to eq('invalid')
        expect(error.message).to eq('Invalid Value')
      end
    end
  end

  context 'pages' do
    it 'returns paging information and correct page for page 1' do
      VCR.use_cassette('poker_search-page-1', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker', page: 1)
        expect(response.pages).to eq(10)
        expect(response.current_page).to eq(1)
        expect(response.next_page).to eq(2)
        expect(response.previous_page).to eq(nil)
        expect(response.queries.request.first.startIndex).to eq(1)
      end
    end

    it 'returns paging information and correct page for page 2' do
      VCR.use_cassette('poker_search-page-2', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker', page: 2)
        expect(response.pages).to eq(10)
        expect(response.current_page).to eq(2)
        expect(response.next_page).to eq(3)
        expect(response.previous_page).to eq(1)
        expect(response.queries.request.first.startIndex).to eq(11)
      end
    end

    it 'returns paging information and correct page for page 10' do
      VCR.use_cassette('poker_search-page-10', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker', page: 10)
        expect(response.pages).to eq(10)
        expect(response.current_page).to eq(10)
        expect(response.next_page).to eq(nil)
        expect(response.previous_page).to eq(9)
        expect(response.queries.request.first.startIndex).to eq(91)
      end
    end

    it 'returns paging information and correct page for start 11' do
      VCR.use_cassette('poker_search-page-start-11', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker', start: 11)
        expect(response.pages).to eq(10)
        expect(response.current_page).to eq(2)
        expect(response.next_page).to eq(3)
        expect(response.previous_page).to eq(1)
        expect(response.queries.request.first.startIndex).to eq(11)
      end
    end

    it 'returns paging information for basic search' do
      VCR.use_cassette('poker_search', record: :new_episodes) do
        response = GoogleCustomSearchApi.search('poker')
        expect(response.pages).to eq(10)
        expect(response.current_page).to eq(1)
        expect(response.next_page).to eq(2)
        expect(response.previous_page).to eq(nil)
        expect(response.queries.request.first.startIndex).to eq(1)
      end
    end
  end

  context 'search and return all results' do
    it 'returns resules without a yield' do
      VCR.use_cassette('poker_search-10-pages', record: :new_episodes) do
        response = GoogleCustomSearchApi.search_and_return_all_results('poker')
        expect(response.size).to eq(10)
        expect(response.first.items.size).to eq(10)
      end
    end

    it 'returns an empty array' do
      VCR.use_cassette('search-no-results', record: :new_episodes) do
        response =
          GoogleCustomSearchApi.
            search_and_return_all_results('asdfqwefaefwezzu')
        expect(response.first.items.size).to eq(0)
      end
    end

    it 'works with a yield' do
      VCR.use_cassette('poker_search-10-pages', record: :new_episodes) do
        GoogleCustomSearchApi.search_and_return_all_results('poker') do |r|
          expect(r.items.size).to eq(10)
        end
      end
    end

    it 'works when only one row is returned' do
      VCR.use_cassette('wine_search', record: :new_episodes) do
        GoogleCustomSearchApi.search_and_return_all_results(
          '"California cult winery known for its Rhône"') do |r|
          expect(r.items.size).to eq(3)
        end
      end
    end
  end
end
