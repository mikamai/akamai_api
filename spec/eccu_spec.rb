require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Akamai::Eccu do
  it 'should define a get_ids' do
    should respond_to(:get_ids)
  end

  it 'should raise error if login is not correct' do
    lambda { Akamai::Eccu.new.get_ids }.should raise_error(Akamai::LoginError)
  end

  it 'test get_ids proxy call' do
    expected = {
      :get_ids_response => {
        :file_ids => {
          :file_ids => [ '1231234', '1231234' ]
        }
      }
    }
    Savon::Client.any_instance.should_receive(:request).with('getIds').and_return expected
    list = Akamai::Eccu.new.get_ids
    list.should be_a(Array)
    list.length.should == 2
  end
  
  it 'test get_info proxy call' do
    expected = {
      :get_info_response => {
        :eccu_info => {
          :file_id => 123123,
          :contents => '',
          :upload_date => Date.today,
          :md5_digest => '',
          :property_name => 'www.mikamai.com',
          :property_name_exact_match => true,
          :property_type => 'hostheader',
          :status_update_date => Date.today,
          :status_code => 4000
        }
      }
    }
    Savon::Client.any_instance.should_receive(:request).with('getInfo').and_return expected
    list = Akamai::Eccu.new.get_info 123123
    list.should be_a(Hash)
    list[:id].should == 123123
  end

  it 'test set_notes proxy call' do
    expected = {
      :set_notes_response => {
        :success => true
      }
    }
    Savon::Client.any_instance.should_receive(:request).with('setNotes').and_return expected
    status = Akamai::Eccu.new.set_notes 123123, 'notes'
    status.should == true
  end

  it 'test set_notify proxy call' do
    expected = {
      :set_status_change_email_response => {
        :success => true
      }
    }
    Savon::Client.any_instance.should_receive(:request).with('setStatusChangeEmail').and_return expected
    status = Akamai::Eccu.new.set_notify_email 123123, 'giovanni@mikamai.com'
    status.should == true
  end

  it 'test delete proxy call' do
    expected = {
      :delete_response => {
        :success => true
      }
    }
    Savon::Client.any_instance.should_receive(:request).with('delete').and_return expected
    status = Akamai::Eccu.new.delete 123123
    status.should == true
  end

  it 'test upload proxy call' do
    expected = {
      :upload_response => {
        :fileId => 123123
      }
    }
    Savon::Client.any_instance.should_receive(:request).with('upload').and_return expected
    file_id = Akamai::Eccu.new.upload 'Sample Content', :notify_email => 'info@mikamai.com', :property => 'http://www.mikamai.com'
    file_id.should == 123123
  end
end
