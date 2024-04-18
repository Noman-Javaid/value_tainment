require 'rails_helper'

describe Aws::Buckets::Objects::Delete do
  include_context 'Aws mocks and stubs'
  let(:delete_instance) { described_class.new(bucket_name, object_key) }

  describe '#call' do
    context 'when object was remove from bucket' do
      before do
        allow(Aws::S3::Resource).to(
          receive(:new).and_return(s3_resource)
        )
      end

      it 'returns true' do
        expect(delete_instance.call).to be_truthy
      end
    end

    context 'when object was not remove from bucket' do
      before do
        allow(Aws::S3::Resource).to(
          receive(:new).and_return(s3_resource_fail)
        )
      end

      it 'returns false' do
        expect(delete_instance.call).to be_falsey
      end
    end
  end
end
