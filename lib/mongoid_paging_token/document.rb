module MongoidPagingToken
  module Document
    extend ActiveSupport::Concern

    included do
      def self.page_by_token(token)
        Marshal.load(Base64.decode64(CGI.unescape(token)))
      end
    end

  end
end
