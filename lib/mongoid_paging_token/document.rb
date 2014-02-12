module MongoidPagingToken
  module Document
    extend ActiveSupport::Concern

    included do
      def self.page_by_token(token)
        raise 'paging token value is nil' unless token
        Marshal.load(Base64.urlsafe_decode64(token))
      end
    end

  end
end
