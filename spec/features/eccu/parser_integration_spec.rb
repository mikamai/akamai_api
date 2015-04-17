require 'spec_helper'

describe 'Some example of input -> output' do

  context 'only 1 recursive-dirs tag' do
    let(:parser){ AkamaiApi::ECCUParser.new "foo/" }
    it{ expect( parser.xml ).to eq( "<eccu><match:recursive-dirs value=\"foo\"><match:this-dir value=\"This Directory Only\"><revalidate>now</revalidate></match:this-dir></match:recursive-dirs></eccu>" ) }
  end

  context 'eccu_test/**/*.txt' do
    let(:parser){ AkamaiApi::ECCUParser.new "eccu_test/**/*.txt" }
    it{ expect( parser.xml ).to \
        eq("<eccu><match:recursive-dirs value=\"eccu_test\"><match:ext value=\"txt\"><revalidate>now</revalidate></match:ext></match:recursive-dirs></eccu>" )
    }
  end

  context 'eccu_test/*/*.txt' do
    let(:parser){ AkamaiApi::ECCUParser.new "eccu_test/*/*.txt" }
    it{ expect( parser.xml ).to \
        eq("<eccu><match:recursive-dirs value=\"eccu_test\"><match:sub-dirs-only value=\"Sub-directories Only\"><match:ext value=\"txt\"><revalidate>now</revalidate></match:ext></match:sub-dirs-only></match:recursive-dirs></eccu>" )
    }
  end

  context 'eccu_test/*.txt' do
    let(:parser){ AkamaiApi::ECCUParser.new "eccu_test/*.txt" }
    it{ expect( parser.xml ).to \
        eq("<eccu><match:recursive-dirs value=\"eccu_test\"><match:this-dir value=\"This Directory Only\"><match:ext value=\"txt\"><revalidate>now</revalidate></match:ext></match:this-dir></match:recursive-dirs></eccu>" )
    }
  end

end
