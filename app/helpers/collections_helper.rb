module CollectionsHelper
  def enables_collection
    [['Enable', true], ['Disable', false]]
  end

  def actives_collection
    [['Active', true], ['Inactive', false]]
  end
end
