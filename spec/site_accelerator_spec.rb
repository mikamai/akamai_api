require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AkamaiApi::SiteAccelerator do
  it 'should define a cp_codes method' do
    should respond_to(:cp_codes)
  end

  it 'should raise error if login is not correct' do
    lambda { AkamaiApi::SiteAccelerator.new.cp_codes }.should raise_error(AkamaiApi::LoginError)
  end

  it 'should report correctly' do
    expected = {
      :multi_ref => [
                     {
                       :cpcode => 123,
                       :description => 'Test CPCode',
                       :service => 'Service'
                     }, {
                       :cpcode => 321,
                       :description => 'Another Test',
                       :service => 'Service'
                     }
                   ]
    }
    Savon::Client.any_instance.should_receive(:request).with('getCPCodes').and_return expected
    list = AkamaiApi::SiteAccelerator.new.cp_codes
    list.should be_a(Array)
    list.length.should == 2
  end
end
