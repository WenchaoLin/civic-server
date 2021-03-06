class DatatableBase
  delegate :params, to: :@view_context

  def initialize(view_context)
    @view_context = view_context
  end

  def as_json(options = {})
    {
      result: data,
      total: total_items
    }
  end

  private
  def data
    objects.map { |o| presenter_class.new(o) }
  end

  def objects
    @objects ||= filter(order(paginate(select_query)))
  end

  def total_items
    @total_items ||= filter(count_query).all[0].count
  end

  def paginate(objects)
    objects.page(page).per(count)
  end

  def filter(objects)
    if filter_params = params['filter']
      filter_params.inject(objects) do |o, (col, term)|
        if actual_col = filter_column(col)
          o.where("#{actual_col} ILIKE :search", search: "%#{term}%")
        else
          o
        end
      end
    else
      objects
    end
  end

  def order(objects)
    if sort_params = params['sorting']
      sort_params.inject(objects) do |o, (col, direction)|
        if actual_col = order_column(col)
          o.order("#{actual_col} #{sort_direction(direction)} NULLS LAST")
        else
          o
        end
      end
    else
      objects
    end
  end

  def page
    params[:page].to_i
  end

  def count
    params[:count].to_i
  end

  def sort_direction(dir)
    dir == 'desc' ? 'desc' : 'asc'
  end

  def filter_column(col)
    self.class::FILTER_COLUMN_MAP[col]
  end

  def order_column(col, col_hash = self.class::ORDER_COLUMN_MAP)
    col_hash[col]
  end

  def presenter_class
    raise 'Must implement in subclass'
  end

  def column_map(col)
    raise 'Must implement in subclass'
  end

  def initial_scope
    raise 'Must implement in subclass'
  end

  def select_query
    raise 'Must implement in subclass'
  end

  def count_query
    raise 'Must implement in subclass'
  end
end
