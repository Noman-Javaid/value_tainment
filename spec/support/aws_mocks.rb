RSpec.shared_context 'Aws mocks and stubs' do # rubocop:todo RSpec/ContextWording
  let(:bucket_name) { 'bucket_name' }
  let(:object_key) { 'some_key' }
  let(:method) { :get }
  let(:expires_in) { { expires_in: 10.minutes.to_i } }
  let(:presigned_url) { 'https://amazon.s3/test_url' }
  let(:s3_object) { double('object') }
  let(:s3_object_with_presigned) { double('object') }
  let(:s3_object_fail) { double('object') }
  let(:s3_bucket) { double('bucket') }
  let(:s3_bucket_with_presigned) { double('bucket') }
  let(:s3_bucket_fail) { double('bucket') }
  let(:s3_resource) { double('resource') }
  let(:s3_resource_with_presigned) { double('resource') }
  let(:s3_resource_fail) { double('resource') }
  let(:ses_client) { double('ses_client') }

  before do
    allow(s3_resource).to receive(:bucket).with(bucket_name).and_return(s3_bucket)
    allow(s3_resource_fail).to receive(:bucket).with(bucket_name).and_return(s3_bucket_fail)
    allow(s3_bucket).to receive(:object).with(object_key).and_return(s3_object)
    allow(s3_bucket_fail).to receive(:object).with(object_key).and_return(s3_object_fail)
    allow(s3_object_fail).to receive(:delete).and_raise(Aws::Errors::ServiceError)
    allow(s3_object).to receive(:delete).and_return(true)
    allow(s3_resource_with_presigned).to receive(:bucket).with(bucket_name).and_return(s3_bucket_with_presigned)
    allow(s3_bucket_with_presigned).to receive(:object).with(object_key).and_return(s3_object_with_presigned)
    allow(s3_object_with_presigned).to receive(:presigned_url).with(method, expires_in).and_return(presigned_url)
  end
end
