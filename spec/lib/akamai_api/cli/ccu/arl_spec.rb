require 'spec_helper'

module AkamaiApi
  describe CLI::CCU::Arl do
    describe 'invalidate' do
      it 'polls for status' do
        arl = CLI::CCU::Arl.new

        allow(arl).to receive(:load_config)
        allow(arl).to receive(:options).and_return({:poll => true})

        res = double()
        expect(CCU).to receive(:purge).and_return(res)
        
        expect(res).to receive(:code).and_return(201)  
        expect(res).to receive(:time_to_wait).and_return(true)

        renderer = double()
        allow(renderer).to receive(:render)
        allow(CLI::CCU::PurgeRenderer).to receive(:new).and_return(renderer)

        status_res1 = double()
        allow(status_res1).to receive(:code).and_return(201)

        status_res2 = double()
        allow(status_res2).to receive(:completed_at).and_return(nil, nil, true)

        allow(CLI::CCU::StatusRenderer).to receive(:new).and_return(renderer)

        allow(res).to receive(:uri).and_return("status_uri")
      
        expect(CCU).to receive(:status).exactly(3).times.with("status_uri").and_return(status_res2)

        expect(arl).to receive(:sleep).exactly(2).times.with(60)

        arl.invalidate("test_uri")
      end
    end
  end
end
