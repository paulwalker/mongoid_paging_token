module MongoidPagingToken
  module Criteria
    extend ActiveSupport::Concern

    def paging_token
      pager.to_s
    end

    def can_page?
      pager.strategy.can_page?
    end

    def pager
      @pager ||= PagingToken.new(self)
    end
  end
end
