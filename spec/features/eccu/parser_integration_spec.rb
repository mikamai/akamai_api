require 'spec_helper'

def open_expected_file( filename )
  content = File.open(File.dirname(__FILE__) + "/../../fixtures/eccu/parser/#{filename}", "r").read
  strip_content content
end

def strip_content( xml )
  xml.gsub(/(\n|\t|\r)/, " ").gsub(/>\s*</, "><").strip
end

describe 'Some example of input -> output' do

  tests = {
    "foo/"               => "this_dir_only.xml",
    "foo/**"             => "this_dir_recursive.xml",
    "foo/*"              => "sub_dirs.xml",
    "foo/*/"             => "sub_dirs.xml",
    "foo/bar.txt"        => "dir_with_filename.xml",
    "eccu_test/**/*.txt" => "recursive_extension.xml",
    "eccu_test/*/*.txt"  => "only_sub_dirs_extension.xml",
    "eccu_test/*.txt"    => "dir_with_extension.xml",
  }

  tests.each do |expression, file|
    context expression do
      let(:parser){ AkamaiApi::ECCUParser.new expression }
      it{ expect( strip_content( parser.xml ) ).to eq( open_expected_file(file) ) }
    end
  end

end
