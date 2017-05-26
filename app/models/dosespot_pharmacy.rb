class DosespotPharmacy
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :pharmacy_code,               type: Integer,                  required: true
  field :store_name,                  type: String,  max_length: 500, required: true
  field :first_address,               type: String,  max_length: 35,  required: true
  field :second_address,              type: String,  max_length: 35
  field :city,                        type: String,  max_length: 35,  required: true
  field :state,                       type: String,  max_length: 20,  required: true
  field :zip,                         type: String,  max_length: 10,  required: true
  field :primary_phone,               type: String,  max_length: 35,  required: true
  field :mobile_phone,                type: String,  max_length: 25,  required: true

  belongs_to :dosespot
end
