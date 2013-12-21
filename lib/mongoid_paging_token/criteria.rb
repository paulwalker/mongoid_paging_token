module MongoidPagingToken
  module Criteria
    extend ActiveSupport::Concern

    def paging_token
      paging_token_object.to_s
    end

    def can_page?
      paging_token_object.can_page
    end

    def paging_token_object
      @paging_token ||= MongoidPagingToken::PagingToken.new(self)
    end
  end
end
