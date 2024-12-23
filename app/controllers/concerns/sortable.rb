module Sortable
  extend ActiveSupport::Concern

  included do
    # Removed the before_action from the concern to allow controllers to specify actions
  end

  private

  ALLOWED_SORT_COLUMNS = %w[product_id quantity year month id].freeze

  def permit_sorting_params
    # Permit relevant parameters for sorting and filtering
    params.permit(:sort, :direction, :product_id, :quantity_threshold, :year, :month)
  end

  def sort_column
    if ALLOWED_SORT_COLUMNS.include?(params[:sort])
      case params[:sort]
      when "product_id"
        "products.name" # Sort by product name
      else
        "sales.#{params[:sort]}"
      end
    else
      "sales.id" # Default sort column
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
