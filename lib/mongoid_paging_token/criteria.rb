module MongoidPagingToken
  module Criteria
    extend ActiveSupport::Concern

    def paging_token
      @paging_token ||= MongoidPagingToken::PagingToken.new(self)
      @paging_token.to_s
    end
  end
end
