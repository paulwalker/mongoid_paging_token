module MongoidPagingToken
  class PagingToken

    attr_reader :criteria
    def initialize(criteria)
      @criteria = criteria
    end

    def next_page_criteria
      @next_page_criteria ||= begin
        if sorts.keys.size > 2
          raise NotImplementedError, 'paging not supported for more than two sorted fields'
        end

        if one_field_sort?
          one_field_sort_criteria
        else
          two_field_sort_criteria
        end
      end
    end

    def limit
      criteria.options[:limit]
    end

    def can_page?
      !!(sorts && limit) && limit > 0 && limit == entries.size
    end

    def to_s
      return nil unless can_page?
      CGI.escape(Base64.encode64(Marshal.dump(next_page_criteria)))
    end

    private

    def one_field_sort_criteria
      if criteria.selector[first_condition_field]
        if criteria.selector[first_condition_field].keys.size > 1
          criteria.selector[first_condition_field].delete(first_condition_operator)
        else
          criteria.selector.delete(first_condition_field)
        end
      end

      criteria.where(first_condition)
    end

    def two_field_sort_criteria
      while (conditions = criteria.selector['$or'])
        match = conditions.any? do |c| 
          c[first_condition_field] && 
            c[first_condition_field].is_a?(Hash) &&
            c[first_condition_field].keys.first == first_condition[first_condition_field].keys.first
        end

        if match
          if conditions.any? { |c| c.keys == last_condition.keys }
            criteria.selector.delete('$or')
            break
          end
        end
      end

      criteria.any_of(first_condition, last_condition)
    end

    def sorts
      criteria.options[:sort]
    end

    def entries
      criteria.options[:cache] = true unless criteria.options[:cache]
      criteria.entries
    end

    def first_condition_field
      sorts.keys.first
    end

    def first_condition_operator
      sorts.values.first == 1 ? '$gt' : '$lt'
    end

    def first_condition_value
      entries.last[first_condition_field]
    end

    def first_condition
      first_condition_value.nil? ?
        { first_condition_field => { '$ne' => first_condition_value } } :
        { first_condition_field => { first_condition_operator => first_condition_value } }
    end

    def last_condition_field
      sorts.keys.last
    end

    def last_condition_operator
      sorts.values.last == 1 ? '$gt' : '$lt'
    end

    def last_condition_value
      entries.last[last_condition_field]
    end

    def last_condition
      { first_condition_field => first_condition_value,
        last_condition_field  => { last_condition_operator => last_condition_value } }
    end

    def one_field_sort?
      sorts.keys.size == 1
    end
  end
end