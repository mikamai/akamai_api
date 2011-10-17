require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AkamaiApi::Ccu do
  before { AkamaiApi.use_local_manifests = true }

  it 'should define a purge method' do
    should respond_to(:purge)
  end

  it 'should receive correct args inside purge method' do
    uris = [ 'uri1', 'uri2' ]
    opts = { :key1 => 'v', :key2 => 'v' }
    AkamaiApi::Ccu.any_instance.should_receive(:purge).with(uris, opts)
    AkamaiApi::Ccu.new.purge uris, opts
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
    resp = AkamaiApi::Ccu.new.purge ['http://www.prada.com', 'http://www.miumiu.com'], {}
    resp[:code].should == 100
  end

  it 'should fill the view accordingly' do
    pr = AkamaiApi::Ccu::PurgeRequest.new
    pr.username = 'sample'
    pr.password = 'sample'
    pr.options = [ { :key => 'key1', :value => 'value1' }, { :key => 'key2', :value => 'value2' } ]
    pr.uris = [ 'uri1', 'uri2' ]
    expected = IO.read File.join(File.dirname(__FILE__), 'dump', 'ccu1.xml')
    pr.render.should == expected
  end
end
