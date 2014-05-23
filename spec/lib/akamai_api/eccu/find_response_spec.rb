require 'spec_helper'

describe AkamaiApi::Eccu::FindResponse do
  let(:raw_data) do
    {
      file_id: '1234',
      notes: 'Notes',
      status_change_email: "guest@mikamai.com",
      upload_date: 'date',
      uploaded_by: 'guest',
      version: '1',
      contents: Base64.encode64('hello world'),
      file_size: '1',
      filename: 'file.txt',
      md5_digest: '123',
      extended_status_message: 'status',
      status_code: '200',
      status_message: 'message',
      status_update_date: 'asdasd',
      property_name: 'foo.bar',
      property_name_exact_match: true,
      property_type: 'hostheader'
    }
  end

  subject { AkamaiApi::Eccu::FindResponse.new raw_data }

  describe "#code" do
    it "returns the 'file_id' property" do
      expect(subject.code).to eq "1234"
    end
  end

  {
    :notes       => :notes,
    :email       => :status_change_email,
    :uploaded_at => :upload_date,
    :uploaded_by => :uploaded_by,
    :version     => :version_string
  }.each do |local_name, soap_name|
    describe "##{local_name}" do
      it "returns the '#{soap_name}' property when its a string" do
        expect(subject.send local_name).to eq raw_data[soap_name]
      end

      it "returns nil when the '#{soap_name}' property isnt a string" do
        raw_data[soap_name] = {}
        expect(subject.send local_name).to be_nil
      end
    end
  end

  describe "#file" do
    it "returns an hash" do
      expect(subject.file).to be_a Hash
    end

    it "returns a de-encoded content when there is a 'contents' property'" do
      expect(subject.file[:content]).to eq 'hello world'
    end

    it "doesnt return any content when the 'contents' property isnt a String" do
      raw_data[:contents] = {}
      expect(subject.file).to_not have_key :content
    end

    it "returns a size property" do
      expect(subject.file[:size]).to eq 1
    end

    it "returns the file name when there is a 'file_name' property" do
      expect(subject.file[:name]).to eq 'file.txt'
    end

    it "doesnt return any file name when the 'filename' property isnt a String" do
      raw_data[:filename] = {}
      expect(subject.file).to_not have_key :name
    end

    it "returns the md5 when there is an 'md5' property" do
      expect(subject.file[:md5]).to eq '123'
    end

    it "doesnt return any md5 when the 'md5' property isnt a String" do
      raw_data[:md5_digest] = {}
      expect(subject.file).to_not have_key :md5
    end
  end

  describe "#status" do
    it "returns an hash" do
      expect(subject.status).to be_a Hash
    end

    it "returns an 'extended' property when there is an 'extended_status_property'" do
      expect(subject.status[:extended]).to eq 'status'
    end

    it "does not return any 'extended' when the 'extended_status_property' isnt a String" do
      raw_data[:extended_status_message] = {}
      expect(subject.status).to_not have_key :extended
    end

    it "returns a 'code' property when there is a 'status_code'" do
      expect(subject.status[:code]).to eq 200
    end

    it "returns a 'message' property when there is a 'status_message'" do
      expect(subject.status[:message]).to eq 'message'
    end

    it "does not return any 'message' property when 'status_message' isnt a String" do
      raw_data[:status_message] = {}
      expect(subject.status).to_not have_key :message
    end

    it "returns an 'updated_at' property when there is a 'status_update_date'" do
      expect(subject.status[:updated_at]).to eq 'asdasd'
    end

    it "does not return any 'updated_at' property when 'status_update_date' isnt a String" do
      raw_data[:status_update_date] = {}
      expect(subject.status).to_not have_key :updated_at
    end
  end

  describe "#property" do
    it "returns an Hash" do
      expect(subject.property).to be_a Hash
    end

    it "returns a 'name' property when there is a 'property_name'" do
      expect(subject.property[:name]).to eq 'foo.bar'
    end

    it "does not return any 'name' property when 'propert_name' isnt a String" do
      raw_data[:property_name] = nil
      expect(subject.property).to_not have_key :name
    end

    it "returns a 'exact_match' property set to true when 'property_name_exact_match' is true" do
      expect(subject.property[:exact_match]).to be_true
    end

    it "returns a 'exact_match' property set to false when 'property_name_exact_match' isnt true" do
      raw_data[:property_name_exact_match] = {}
      expect(subject.property[:exact_match]).to be_false
    end

    it "returns a 'type' property when there is a 'property_type'" do
      expect(subject.property[:type]).to eq 'hostheader'
    end

    it "does not return any 'type' property when 'property_type' isnt a String" do
      raw_data[:property_type] = {}
      expect(subject.property).to_not have_key :type
    end
  end
end
