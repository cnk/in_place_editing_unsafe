# Extend ActiveRecord so we can validate attributes before saving one a time

module ActiveRecord
  class Base
    def update_attribute_with_validation(attribute, value)
      self[attribute] = value
      save
    end
  end
end

module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        if @item.update_attribute_with_validation(attribute, params[:value])
          display_value = params[:value].blank? && options[:empty_text] ? options[:empty_text] : @item.send(attribute).to_s
        else
          display_value = attribute.to_s.humanize + ' ' + @item.errors.on(attribute) || 'Oooops!'
        end
        render :text => display_value
      end
    end

  # Example:
  #
  #   Assuming you have 2 models - posts which can belong_to categories
  #   and categories which can have_many posts - you can create this update method
  # 
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for_foreign_key :post, :category_id, :category, :name
  #   end
  #
  #   and then use it in conjunction with and in_place_editor_select_field from 
  #   http://thetacom.info/2008/03/21/rails-in-place-editing-plugin-w-selection/
  #   (code at http://pastie.org/169443)
  # 
  #   # View
  #   <%= in_place_editor_select_field :post, 'title', {}, {:collection => @categories.inspect, :empty_text => '...' } %>
  #
    def in_place_edit_for_foreign_key(object, attribute, foreign_object, display_attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        if @item.update_attribute_with_validation(attribute, params[:value])
          # look up name for new foreign key
          foreign_object = foreign_object.to_s.camelize.constantize.find(@item.send(attribute))
          display_value = foreign_object.send(display_attribute).to_s
        else
          display_value = attribute.to_s.humanize + ' ' + @item.errors.on(attribute) || 'Oooops!'
        end
        render :text => display_value
      end
    end

  end
end
