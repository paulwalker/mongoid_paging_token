require 'spec_helper'

describe MongoidPagingToken do

  before :all do
    class Foo
      include ::Mongoid::Document

      field :title, type: String
      field :description, type: String
    end
  end

  before :each do
    @foos = 10.times.map do |i|
      Foo.create! title: "title_#{i}"
    end
  end

  describe :paging_token do
    it 'generates a paging token for criteria when appropriate' do
      expect(Foo.desc(:title).limit(5).paging_token).to_not be_nil
    end

    it 'does not generate a token when it cannot page further' do
      expect(Foo.desc(:title).limit(15).paging_token).to be_nil
    end

    it 'does not generate a paging token when it does not have a sort' do
      expect(Foo.limit(5).paging_token).to be_nil
    end

    it 'does not support sorting on more than two fields' do
      expect { Foo.desc(:title, :description, :id).limit(5).paging_token }.to raise_error(NotImplementedError)
    end
  end

  describe :page_by_token do
    describe 'one field sort' do
      it 'pages through items with the token' do
        token = Foo.desc(:title).limit(4).paging_token

        results = Foo.page_by_token(token)
        expect(results.to_a.size).to eq(4)

        token = results.paging_token
        results = Foo.page_by_token(token)
        expect(results.to_a.size).to eq(2)
        expect(results.paging_token).to be_nil
      end
    end

    describe 'two field sort' do
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
  end

end