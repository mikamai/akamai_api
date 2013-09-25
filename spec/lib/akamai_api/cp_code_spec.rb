require 'spec_helper'

describe AkamaiApi::CpCode do
  include Savon::SpecHelper

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  describe '::all' do
    context 'when there are multiple cp codes' do
      before do
        fixture = File.read 'spec/fixtures/cp_code/collection.xml'
        savon.expects(:get_cp_codes).returns(fixture)
      end

      it 'returns a collection of cp codes' do
        AkamaiApi::CpCode.all.each { |o| o.should be_a AkamaiApi::CpCode }
      end

      it 'returns a collection with the correct size' do
        AkamaiApi::CpCode.all.count.should == 2
      end

      it 'correctly fills each cp code object' do
        first = AkamaiApi::CpCode.all.first
        first.code.should == '12345'
        first.description.should == 'Foo Site'
        first.service.should == 'Site_Accel::Site_Accel'
      end
    end

    context 'when there is only one cp code' do
      before do
        fixture = File.read 'spec/fixtures/cp_code/single.xml'
        savon.expects(:get_cp_codes).returns(fixture)
      end

      it 'returns a collection of cp codes' do
        AkamaiApi::CpCode.all.each { |o| o.should be_a AkamaiApi::CpCode }
      end

      it 'returns a collection with the correct size' do
        AkamaiApi::CpCode.all.count.should == 1
      end
    end
  end
end