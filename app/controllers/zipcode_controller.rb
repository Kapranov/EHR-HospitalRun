class ZipcodeController < ApplicationController
  skip_before_action :authenticate_user!

  def city_set
    part = params[:city].downcase
    zipcodes = Zipcode.where(:city.eq => (part..(part + 'z' * 25)))
    part = part.split.map(&:capitalize).join(' ')
    zipcodes = Zipcode.where(:city.eq => (part..(part + 'z' * 25))) if zipcodes.blank?

    zipcodes = zipcodes.uniq(&:city)
                        .first(5)
                        .map do |code|
                          code.attributes.merge({
                                                  state_abbr: code.state.try(:abbr),
                                                  state_name: code.state.try(:name)
                                                })
                        end

    render json: { data: zipcodes, status: 'Ok' }
  end

  def zip_set
    zipcodes = Zipcode.where(:code.eq   => (params[:zip]..(params[:zip] + 'z' * 25)))
                      .uniq(&:code)
                      .first(5)
                      .map do |code|
                        code.attributes.merge({
                                                  state_abbr: code.state.try(:abbr),
                                                  state_name: code.state.try(:name)
                                              })
                      end
    render json: { data: zipcodes, status: 'Ok' }
  end
end
