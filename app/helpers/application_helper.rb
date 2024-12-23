# app/helpers/application_helper.rb

module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    current_sort = params[:sort] == column
    direction = current_sort && params[:direction] == "asc" ? "desc" : "asc"

    # Extract permitted parameters, including :id to prevent warnings
    permitted_params = params.permit(:id, :sort, :direction, :product_id, :quantity_threshold, :year, :month).to_h
    # Merge with new sort and direction
    new_params = permitted_params.merge(sort: column, direction: direction)

    # Generate the URL using the current path and new params
    url = "#{request.path}?#{new_params.to_query}"

    # Add an arrow icon based on current sort direction
    arrow = ""
    if current_sort
      arrow = direction == "asc" ? "↑" : "↓"
    end

    # Add a CSS class if currently sorted by this column
    css_class = current_sort ? "sorted-#{direction}" : ""

    link_to "#{title} #{arrow}".html_safe, url, class: css_class
  end

  def toggle_direction
    params[:direction] == "asc" ? "desc" : "asc"
  end
end
