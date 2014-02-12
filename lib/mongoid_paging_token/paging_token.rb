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
      Base64.urlsafe_encode64(Marshal.dump(next_page_criteria))
    end

    private

    def one_field_sort_criteria
      if criteria.selector[first_sort_field]
        if criteria.selector[first_sort_field].keys.size > 1
          criteria.selector[first_sort_field].delete(first_sort_operator)
        else
          criteria.selector.delete(first_sort_field)
        end
      end

      criteria.where(first_condition)
    end

    def two_field_sort_criteria
      remove_two_field_boundary

      boundary_condition = { '$or' => [first_condition, last_condition] }

      if criteria.selector['$and']
        criteria.selector['$and'] << boundary_condition
      else
        and_condition = [boundary_condition]
        criteria.selector.each do |k,v|
          and_condition << { k => v }
          criteria.selector.delete(k)
        end
        criteria.selector['$and'] = and_condition
      end

      criteria.cache
    end

    def is_two_field_boundary?(condition)
      return false unless condition.any? do |c|
        c[first_sort_field] &&
          c[first_sort_field].is_a?(Hash) &&
          c[first_sort_field].keys.first == first_condition[first_sort_field].keys.first
      end

      condition.any? do |c|
        c[first_sort_field] && c[last_sort_field] &&
          c[last_sort_field].is_a?(Hash) &&
          c[last_sort_field].keys.first == last_sort_operator
      end
    end

    def remove_two_field_boundary
      if (condition = criteria.selector['$or']) && is_two_field_boundary?(condition)
        criteria.selector.delete('$or')
        return
      end

      if (conditions = criteria.selector['$and']) &&
        (condition = conditions.find { |c| c['$or'] })
        if is_two_field_boundary?(condition['$or'])
          criteria.selector['$and'].delete_if do |c|
            c['$or']
          end

          others = criteria.selector.delete('$and')
          others.each do |c|
            c.each { |k,v| criteria.selector[k] = v }
          end
        end
      end
    end

    def sorts
      criteria.options[:sort]
    end

    def entries
      criteria.options[:cache] = true unless criteria.options[:cache]
      criteria.entries
    end

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

    def last_sort_field
      sorts.keys.last
    end

    def last_sort_operator
      sorts.values.last == 1 ? '$gt' : '$lt'
    end

    def last_sort_value
      entries.last[last_sort_field]
    end

    def last_condition
      { first_sort_field => first_sort_value,
        last_sort_field  => { last_sort_operator => last_sort_value } }
    end

    def one_field_sort?
      sorts.keys.size == 1
    end
  end
end