module MongoidPagingToken
  class PagingToken

    attr_reader :criteria

    def initialize(criteria)
      @criteria = criteria.options[:cache] ? criteria : criteria.cache
    end

    def strategy
      @strategy ||= begin
        klass = if (sortings = criteria.options[:sort]) && 
          sortings.keys.size < 3 && 
          !sortings.keys.any? { |key| inner_document_key?(key) }

          sortings.keys.size == 2 ? TwoFieldBoundaryStrategy : OneFieldBoundaryStrategy
        else
          OffsetStrategy
        end
        klass.new(criteria)
      end
    end

    def limit
      strategy.limit
    end

    def to_s
      strategy.can_page? ? Base64.urlsafe_encode64(Marshal.dump(strategy.next_criteria)) : nil
    end

    def sorts
      criteria.options[:sort]
    end

    def entries
      criteria.entries
    end

    private

    def inner_document_key?(key)
      key.is_a?(String) && key =~ /\./
    end

  end
end