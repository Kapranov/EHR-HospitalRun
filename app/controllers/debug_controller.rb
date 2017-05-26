class DebugController < ApplicationController
  before_action :restrict_to_development, only: [:index, :select2]

  layout 'debug'
 
  def index
  end

  def select2
    @option_data = [['First Item', 0], ['Second Item', 1], ['Third Item', 2]]
    @themes = ['admin-black-white', 'gray-dark', 'gray-light', 'gray-lighter-highlight', 'gray-lighter', 'green-dark', 'green-light', 'green-lighter', 'green-white-dark', 'green-white-light', 'white-light']
    @padding_types = ['1x', '1-5x', '2x', '2-5x', '3x']
    @arrow_types = ['none', '1x', '2x', '3x', '4x']
    @font_types = ['0-5x', '1x', '2x', '3x', '4x']
    @font_weight_types = ['light', 'regular', 'medium', 'bold', 'heavy']
    @text_align_types = ['left', 'center', 'right']
    @arrow_padding_types = ['0-5x']
    @validation_types = ['valid', 'unvalid']
  end

  protected
    def restrict_to_development
      head(:bad_request) unless Rails.env.development?
    end
end
