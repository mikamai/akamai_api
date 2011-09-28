require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AkamaiApi::WebService do
  class Foo
    include AkamaiApi::WebService

    def get_account
      self.account
    end

    def get_client
      self.client
    end
  end

  describe 'when included' do
    it 'should define constructor with 2 optional arguments' do
      lambda { Foo.new 'test', 'test' }.should_not raise_error
      lambda { Foo.new 'test', 'test', 'test' }.should raise_error(ArgumentError)
    end

    it 'should expect a loginInfo instance if there is only one argument' do
      lambda { Foo.new 'test' }.should raise_error
      lambda { Foo.new AkamaiApi::LoginInfo.new 'test', 'test' }.should_not raise_error
    end

    it 'should define account facility' do
      f = Foo.new
      f.should respond_to(:account)
    end

    it 'should set account values using initialize' do
      f = Foo.new 'foo', 'foo2'
      f.get_account.should == AkamaiApi::LoginInfo.new('foo', 'foo2')
    end

    it 'should define client facility' do
      f = Foo.new
      f.should respond_to(:client)
    end
      
    it 'should set client in initialize' do
      f = Foo.new
      f.get_client.should_not be_nil
    end
  end

  describe 'manifest' do
    it 'should define use_manifest' do
      Foo.should respond_to(:use_manifest)
    end

    it 'use_manifest helper should accept the remote wsdl and, as option, the local manifest' do
      lambda { Foo.use_manifest 'test' }.should_not raise_error
      lambda { Foo.use_manifest 'test', 'test' }.should_not raise_error
    end

    it 'should define get_manifest' do
      Foo.should respond_to(:get_manifest)
    end

    it 'get_manifest should return the remote manifest if AkamaiApi.use_local_manifests is false' do
      Foo.use_manifest 'remote', 'local'
      AkamaiApi.use_local_manifests = false
      Foo.get_manifest.should == 'remote'
    end

    it 'get_manifest should return the local manifest if AkamaiApi.use_local_manifests is true' do
      Foo.use_manifest 'remote', 'local'
      AkamaiApi.use_local_manifests = true
      Foo.get_manifest.should == File.join(AkamaiApi.wsdl_folder, 'local')
    end
  end

  describe 'service_call helper' do
    it 'should be defined' do
      Foo.should respond_to(:service_call)
    end

    it 'define an instance method when invoked' do
      Foo.service_call :sample do
        true
      end
      f = Foo.new
      f.should respond_to :sample
    end

    it 'wraps the service_call to manage login errors' do
      Foo.service_call :sample2 do
        raise Savon::HTTP::Error.new HTTPI::Response.new 401, {}, {}
      end
      f = Foo.new
      lambda { f.sample2 }.should raise_error(AkamaiApi::LoginError)
    end
  end
end
