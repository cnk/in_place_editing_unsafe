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
  end
end
