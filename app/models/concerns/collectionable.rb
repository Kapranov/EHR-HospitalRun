module Collectionable
  def select_collection(collection, label = :itself, id = :id, collection_name = nil)
    define_method select_collection_name(collection, collection_name) do
      self.class.collection_call(self, collection).map { |value| [self.class.methods_call(value, label), self.class.methods_call(value, id)] }
    end
  end

  def self_select_collection(collection, label = :itself, id = :id, collection_name = nil)
    method_collection_name = select_collection_name(collection, collection_name)
    self.class.instance_eval do
      define_method method_collection_name do
        collection_call(self, collection).map { |value| [methods_call(value, label), methods_call(value, id)] }
      end
    end
  end

  def methods_call(value, methods)
    if methods.is_a? Array
      methods.each { |method| value = value.method(method).call }
    else
      value = value.method(methods).call
    end
    value
  end

  def collection_call(collections, collection)
    if collection.is_a? Array
      collection.each { |col| collections = collections.send(col) }
    else
      collections = collections.method(collection).call
    end
    collections
  end

  def select_collection_name(collection, collection_name)
    collection_name.present? ? collection_name : "#{(collection.is_a? Array) ? collection[-1] : collection}_collection"
  end
end