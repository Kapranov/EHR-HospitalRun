describe Attachment do
  clean_users

  let(:base_file_name) { FakerHelpers.sample_image_name }
  let(:file_name)      { FakerHelpers.sample_image base_file_name }
  let!(:attachment) { create :attachment, file_name: file_name, amendment_id: nil }

  it 'returns base file name' do
    expect(attachment.basename).to eq base_file_name
  end
end
