module SkypeAPI
  module Object
    class FileTransfer < AbstractObject
      OBJECT_NAME = "FILETRANSFER"
      
      getter :Type, 'TYPE'
      getter :Status, 'STATUS'
      getter :FailureReason, 'FAILUREREASON'
      getter :Partner, 'PARTNER_HANDLE' do |str|
        @@skypeApi.user str
      end
      getter :PartnerDispname, 'PARTNER_DISPNAME'
      getter :StartTime, 'STARTTIME' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :FinishTime, 'FINISHTIME' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :FilePath, 'FILEPATH'
      getter :FileSize, 'FILESIZE' do |str|
        str.to_i
      end
      getter :BytesPerSecond, 'BYTESPERSECOND' do |str|
        str.to_i
      end
      getter :BytesTransferred, 'BYTESTRANSFERRED' do |str|
        str.to_i
      end
    end
  end
end
