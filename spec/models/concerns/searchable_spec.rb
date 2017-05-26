shared_examples Searchable do |methods|
  methods.each do |method|
    it { expect(obj).to respond_to("find_#{method}_by") }
    it { expect(obj).to respond_to("#{method}_first") }
  end
end

# Due to I don't know how to stub returning NoBrainer::Criteria
# this module tests #seacrh in models/provider_spec
# and #self_seacrh in models/diagnosis_codes_spec # does not exist yet
