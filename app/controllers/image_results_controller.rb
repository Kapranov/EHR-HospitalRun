class ImageResultsController < ApplicationController
  layout 'providers_imaging'

  before_action :find_patient, :find_image_result

  def imaging
  end

  def update
    image_result = ImageResult.find(params[:id])
    if image_result.update(image_result_params)
      create_images
      log 5, 1, @patient.id
      flash[:notice] = updation_notification(image_result)
      redirect_to image_orders_path
    else
      flash[:error] = image_result.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def form
    render partial: 'image_results/form'
  end

  def search_by_image_order
  end

  def results_search_by_image_order
    @image_order = current_user.provider.image_orders.find(params[:id])
  end

  protected

  def image_params
    params.require(:image).permit(:image)
  end

  def image_result_params
    params.require(:image_result).permit(
        :images,
        :schedule_at,
        :exam,
        :requested_by,
        :history,
        :radiophamaceutical,
        :technique,
        :comparison,
        :findings,
        :impression,
        :patient_id
    )
  end

  def check_role
    # authorize :chart, :insurance_show?
  end

  def find_patient
    @patient = params[:patient_id].present? ? Patient.find(params[:patient_id]) : current_user.main_provider.patients.first
  end

  def find_image_result
    @image_result = @patient.try(:image_result)
  end

  def create_images
    images = params[:image_result][:images]
    if images.present? && images.any?
      images.each do |_, value|
        @image_result.add_image(Image.create(image: value))
      end
    end
  end
end