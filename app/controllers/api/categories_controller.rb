class API::CategoriesController < API::ApplicationController

  def index
    @categories = Category.where.not(parent_id: 0).includes(:parent)
    respond_with(@categories)
  end

  def parents
    @categories = Category.where(parent_id: 0)
    respond_with(@categories)
  end

  protected
  def collection
    Category.all_parent_categories
  end
end
