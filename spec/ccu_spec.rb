require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AkamaiApi::Ccu do
  it 'should define a purge method' do
    should respond_to(:purge)
  end

  it 'should raise error if login is not correct' do
    lambda { AkamaiApi::Ccu.new.purge }.should raise_error(AkamaiApi::LoginError)
  end

  it 'should report correctly' do
    expected = {
      :purge_request_response => {
        :return => {
          :result_code => '100',
          :result_msg => 'Success',
          :session_id => 'fake',
          :est_time => '420',
          :uri_index => -1
        }
      }
    }
    Savon::Client.any_instance.should_receive(:request).and_return expected
    resp = AkamaiApi::Ccu.new.purge 'http://www.prada.com', {}
    resp[:code].should == 100
  end
end
