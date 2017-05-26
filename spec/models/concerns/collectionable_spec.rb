shared_examples Collectionable do |methods|
  Collectionable_Object = Struct.new(:name, :id)

  methods.each do |method|
    it { expect(obj).to respond_to("#{method}_collection") }
  end

  shared_examples 'a collection' do
    it { should respond_to(method_name) }
    it { expect(subject.method(method_name).call).to match_array(result_array) }
  end

  shared_examples 'a methods creater' do
    let(:collection)   { :objects }
    let(:method_name)  { "#{collection}_collection" }
    let(:objects)      { [Collectionable_Object.new('Andrew', 1),
                          Collectionable_Object.new('Bob', 2)] }
    let(:result_array) { [['Andrew', 1],
                          ['Bob', 2]] }

    describe 'simple collection' do
      before :each do
        allow(subject).to receive(collection).and_return(objects)
        klass.method(test_method_name).call(collection, :name, :id)
      end

      it_behaves_like 'a collection'
    end

    describe 'creates with custom name' do
      let(:custom_method_name)   { :custom_objects_collection }

      before :each do
        allow(subject).to receive(collection).and_return(objects)
        klass.method(test_method_name).call(collection, :name, :id, custom_method_name)
      end

      it { should respond_to(custom_method_name) }
      it { expect(subject.method(custom_method_name).call).to match_array(result_array) }
    end

    describe 'creates with array collection' do
      let(:container)   { :container }

      before :each do
        allow(subject).to receive_message_chain(container, collection).and_return(objects)
        klass.method(test_method_name).call([container, collection], :name, :id)
      end

      it_behaves_like 'a collection'
    end

    describe 'creates with array label' do
      let(:label_container)   { :container }

      before :each do
        allow(subject).to receive(collection).and_return(objects)
        allow_any_instance_of(Collectionable_Object).to receive_message_chain(label_container, :name).and_return('Bob')
        klass.method(test_method_name).call(collection, [label_container, :name], :id)
      end

      it { should respond_to(method_name) }
      it { expect(subject.method(method_name).call).to match_array([['Bob', 1], ['Bob', 2]]) }
    end

    describe 'creates with array id' do
      let(:label_container)   { :container }

      before :each do
        allow(subject).to receive(collection).and_return(objects)
        allow_any_instance_of(Collectionable_Object).to receive_message_chain(label_container, :id).and_return(1)
        klass.method(test_method_name).call(collection, :name, [label_container, :id])
      end

      it { should respond_to(method_name) }
      it { expect(subject.method(method_name).call).to match_array([['Andrew', 1], ['Bob', 1]]) }
    end
  end

  it_behaves_like 'a methods creater' do
    subject     { obj }
    let(:klass) { obj.class }
    let(:test_method_name) { :select_collection }
  end

  it_behaves_like 'a methods creater' do
    subject     { obj.class }
    let(:klass) { obj.class }
    let(:test_method_name) { :self_select_collection }
  end
end