module MongoidPagingToken
  class Strategy

    attr_reader :criteria

    def initialize(criteria)
      @criteria = criteria
    end

    def limit
      criteria.options[:limit]
    end

    def can_page?
      !!(sorts && limit) && limit > 0 && limit == entries.size
    end

    protected

    def sorts
      criteria.options[:sort]
    end

    def entries
      criteria.entries
    end

  end
end