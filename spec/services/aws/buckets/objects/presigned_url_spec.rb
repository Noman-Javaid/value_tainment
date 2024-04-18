require 'rails_helper'

describe Aws::Buckets::Objects::PresignedUrl do
  include_context 'Aws mocks and stubs'
  include_context 'users_for_expert_endpoints'
  let(:quick_question) do
    create(:quick_question, individual: individual, expert: expert)
  end
  let(:attachment) { create(:attachment, in_bucket: true, quick_question: quick_question) }
  let(:presigned_url_instance) do
    described_class.new(bucket_name, object_key, method, attachment)
  end
  let(:response_headers) do
    {
      'Content-Type': attachment.file_type,
      'Content-Disposition': "inline; filename=\"#{attachment.file_name}\"; filename*=UTF-8''#{attachment.file_name}"
    }
  end
  let(:response_hash) do
    {
      url: presigned_url,
      headers: response_headers
    }
  end

  describe '#call' do
    before do
      allow(Aws::S3::Resource).to(
        receive(:new).and_return(s3_resource_with_presigned)
      )
    end

    context 'when upload url is requested' do
      let(:method) { :put }

      it 'returns hash with url and headers' do
        expect(presigned_url_instance.call).to eq(response_hash)
      end
    end

    context 'when download url is requested' do
      let(:response_headers) { nil }
      let(:method) { :get }

      it 'returns hash with url and headers' do
        expect(presigned_url_instance.call).to eq(response_hash)
      end
    end
  end
end
