class AreaCodesController < ApplicationController
  skip_before_action :authenticate_user!

  def get_area_codes
    area_codes = if params[:area_code].present?
                  AreaCode.where(code: /^#{params[:area_code]}/)
                  .limit(5)
                  .map do |code|
                    code.attributes.merge({
                                            id: code.try(:code),
                                            text: code.try(:code)
                                          })
                  end
                end
    render json: area_codes.to_json
  end
end
