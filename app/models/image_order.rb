class ImageOrder
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include AttachmentCollectionable

  def self.order_types
    [:'Image Order', :'Image Result']
  end

  def self.names
    [:'Lab Name']
  end

  def self.statuses
    [:Open, :Closed, :Canceled, :Discontinued, :Hold, :Archived]
  end

  def self.ordering_facilities
    [:'Ordering facility']
  end

  def self.image_statuses
    [:'In Progress']
  end

  field :order_num,           type: Integer,       required: true
  field :order_type,          type: Enum,          in: self.order_types,         default: self.order_types.first
  field :image_name,          type: Enum,          in: self.names,               default: self.names.first
  field :status,              type: Enum,          in: self.statuses,            default: self.statuses.first
  field :ordering_physician,  type: String
  field :ordering_facility,   type: Enum,          in: self.ordering_facilities, default: self.ordering_facilities.first
  field :image_status,        type: Enum,          in: self.image_statuses,      default: self.image_statuses.first
  field :schedule_at,         type: Time
  field :received_at,         type: Time
  field :notes,               type: Text

  has_many   :test_orders,    dependent: :destroy
  belongs_to :provider
  belongs_to :patient

  before_validation :set_order_num
  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :schedule_at_date, :schedule_at_time
  attr_accessor :received_at_date, :received_at_time

  private

  def set_order_num
    self.order_num = ImageOrder.last.present? ? ImageOrder.last.order_num + 1 : 1
  end

  def get_datetimes
    self.schedule_at ||= Time.now
    self.received_at ||= Time.now

    self.schedule_at_date ||= self.schedule_at.to_date.to_s(:frontend_date)
    self.schedule_at_time ||= "#{'%02d' % self.schedule_at.to_time.hour}:#{'%02d' % self.schedule_at.to_time.min}"

    self.received_at_date ||= self.received_at.to_date.to_s(:frontend_date)
    self.received_at_time ||= "#{'%02d' % self.received_at.to_time.hour}:#{'%02d' % self.received_at.to_time.min}"
  end

  def set_datetimes
    self.schedule_at = "#{Date.strptime(self.schedule_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.schedule_at_time}".to_time
    self.received_at = "#{Date.strptime(self.received_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.received_at_time}".to_time
  end
end