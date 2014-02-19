require 'spec_helper'

describe MongoidPagingToken do

  before :all do
    class Foo
      include ::Mongoid::Document

      field :title, type: String
      field :description, type: String
    end
  end

  describe :paging_token do
    describe 'one field sort' do
      before :each do
        @foos = 10.times.map do |i|
          Foo.create! title: "title_#{i}"
        end
      end

      it 'generates a paging token for criteria when appropriate' do
        expect(Foo.desc(:title).limit(5).paging_token).to_not be_nil
      end

      it 'does not generate a token when it cannot page further' do
        expect(Foo.desc(:title).limit(15).paging_token).to be_nil
      end

      it 'does not generate a paging token when it does not have a sort' do
        expect(Foo.limit(5).paging_token).to be_nil
      end

      it 'pages through items with the token' do
        token = Foo.desc(:title).limit(4).paging_token

        results = Foo.page_by_token(token)
        expect(results.to_a.size).to eq(4)

        token = results.paging_token
        results = Foo.page_by_token(token)
        expect(results.to_a.size).to eq(2)
        expect(results.paging_token).to be_nil
      end

      it 'pages through items with the token' do
        token = Foo.desc(:title, :id).limit(4).paging_token

        results = Foo.page_by_token(token)
        expect(results.to_a.size).to eq(4)

        token = results.paging_token
        results = Foo.page_by_token(token)
        expect(results.to_a.size).to eq(2)
        expect(results.paging_token).to be_nil
      end

    end

    describe 'two field sort' do
      before :each do
        @foos = 1.upto(5).map do |i|
          Foo.create! title: 'title', description: "description_#{i}"
        end
        @foos += 6.upto(9).map do |i|
          Foo.create! title: "title_#{i}", description: "description_#{i}"
        end
      end

      it 'pages correctly with a standard two field sort without other conditions' do
        token = Foo.asc(:title, :description).limit(4).paging_token

        criteria = Foo.page_by_token(token)
        token, results = criteria.paging_token, criteria.entries

        expect(results.first.description).to eq('description_5')
        expect(results.last.description).to eq('description_8')

        criteria = Foo.page_by_token(token)
        token, results = criteria.paging_token, criteria.entries

        expect(token).to be_nil
        expect(results).to have(1).item
        expect(results.first.description).to eq('description_9')
      end

      it 'pages correctly with an or condition' do
        token = Foo.asc(:title, :description).
          any_of(title: /t/, description: /t/).limit(4).paging_token

        criteria = Foo.page_by_token(token)
        token, results = criteria.paging_token, criteria.entries

        expect(results.first.description).to eq('description_5')
        expect(results.last.description).to eq('description_8')

        criteria = Foo.page_by_token(token)
        token, results = criteria.paging_token, criteria.entries

        expect(token).to be_nil
        expect(results).to have(1).item
        expect(results.first.description).to eq('description_9')
      end

    end

  end

end