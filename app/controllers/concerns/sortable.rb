# app/controllers/concerns/sortable.rb

module Sortable
  extend ActiveSupport::Concern

  included do
    before_action :permit_sorting_params, only: [:index, :show, :products]
  end

  private

  ALLOWED_SORT_COLUMNS = %w[product_id quantity year month id].freeze

  def permit_sorting_params
    # Include :id to prevent Rails from flagging it as unpermitted
    params.permit(:id, :sort, :direction, :product_id, :quantity_threshold, :year, :month)
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
