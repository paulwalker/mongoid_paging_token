module MongoidPagingToken
  class OneFieldBoundaryStrategy < Strategy

    def next_criteria
      if criteria.selector[first_sort_field]
        if criteria.selector[first_sort_field].keys.size > 1
          criteria.selector[first_sort_field].delete(first_sort_operator)
        else
          criteria.selector.delete(first_sort_field)
        end
      end

      criteria.where(first_condition)
    end

    protected

    def first_sort_field
      sorts.keys.first
    end

    def first_sort_operator
      sorts.values.first == 1 ? '$gt' : '$lt'
    end

    def first_sort_value
      entries.last[first_sort_field]
    end

    def first_condition
      first_sort_value.nil? ?
        { first_sort_field => { '$ne' => first_sort_value } } :
        { first_sort_field => { first_sort_operator => first_sort_value } }
    end

  end
end



