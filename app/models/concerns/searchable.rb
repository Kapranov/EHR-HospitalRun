module Searchable
  def self_search(fields, search_method_name, collection = nil)
    define_search_name = method_search_name(search_method_name)
    define_limit_name = method_limit_name(search_method_name)
    self.class.instance_eval do
      define_method define_search_name do |part|
        self_collection(self, collection).where(search_conditions(fields, part))
      end
    end
    self.class.instance_eval do
      define_method define_limit_name do |amount = 10|
        self_collection(self, collection).limit(amount)
      end
    end
  end

  def search(fields, search_method_name, collection = nil)
    define_search_name = method_search_name(search_method_name)
    define_limit_name = method_limit_name(search_method_name)
    define_method define_search_name do |part|
      self.class.self_collection(self, collection).where(self.class.search_conditions(fields, part))
    end
    define_method define_limit_name do |amount|
      self.class.self_collection(self, collection).limit(amount)
    end
  end

  def search_conditions(fields, part)
    if fields.is_a? Array
      {or: fields.map{ |field| { field => /^#{part}/ } } }
    else
      { fields => /^#{part}/ }
    end
  end

  def method_search_name(search_name)
    "find_#{search_name}_by"
  end

  def method_limit_name(limit_name)
    "#{limit_name}_first"
  end

  def self_collection(result, collection)
    if collection.is_a? Array
      collection.each { |method| result = result.method(method).call }
      result
    else
      self
    end
  end
end