module MongoidPagingToken
  class OffsetStrategy < Strategy

    def next_criteria
      criteria.offset(new_offset)
    end

    protected

    def new_offset
      (criteria.options[:skip] || 0) + limit
    end

  end
end