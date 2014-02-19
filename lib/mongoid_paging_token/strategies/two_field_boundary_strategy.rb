module MongoidPagingToken
  class TwoFieldBoundaryStrategy < OneFieldBoundaryStrategy

    def next_criteria
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

    protected

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

  end
end
