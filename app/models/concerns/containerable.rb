module Containerable
  def field_array(field, opt)
    fields = field.to_s.pluralize.to_sym

    self.class_eval do
      field fields, type: Array, default: []
    end

    method_fields_exists_name = "#{fields}?"
    method_all_objects_name   = "all_#{fields}"
    klass = field.to_s.camelcase.constantize

    # objects?
    define_method method_fields_exists_name do
      method(fields).call.present? && method(fields).call.any?
    end

    # all_objects
    define_method method_all_objects_name do
      method(method_fields_exists_name).call ? klass.where(:id.in => method(fields).call) : []
    end

    # add_object
    define_method "add_#{field}" do |obj|
      update(fields => method(fields).call << obj.id)
    end

    # destroy_object
    define_method "destroy_#{field}" do |id|
      method(method_all_objects_name).call.find(id).try(:destroy) if opt[:cleanable]
      update(fields => method(fields).call - [id])
    end

    create_purifier_callback(fields, method_all_objects_name) if opt[:cleanable]
  end

  private

  def create_purifier_callback(field_plur, method_all_objects_name)
    before_destroy_name = :"destroy_#{field_plur}"

    define_method before_destroy_name do
      objects = method(method_all_objects_name).call
      objects.destroy_all if objects.any?
    end

    self.class_eval do
      before_destroy before_destroy_name
      private before_destroy_name
    end
  end
end