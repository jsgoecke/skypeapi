module SkypeAPI
  module Object
    class VoiceMail < AbstractObject
      OBJECT_NAME = "VOICEMAIL"
      
      def self.create target
        @@skypeApi.invoke "CALLVOICEMAIL #{target}"
      end
      
      def self.open id
        @@skypeApi.invoke "OPEN VOICEMAIL #{id}"
      end
      
      getter :Type, 'TYPE'
      getter :Partner, 'PARTNER_HANDLE' do |str|
        @@skypeApi.user str
      end
      getter :PartnerDispname, 'PARTNER_DISPNAME'
      getter :Status, 'STATUS'
      getter :FailureReason, 'FAILUREREASON'
      #getter :Subject, 'SUBJECT'
      getter :Timestamp, 'TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Duration, 'DURATION' do |str|
        str.to_i
      end
      getter :AllowedDuration, 'ALLOWED_DURATION' do |str|
        str.to_i
      end
      
      #def alter action
      #  @@skypeApi.invoke "ALTER VOICEMAIL #{id} #{action}"
      #end
      
      def startPlayback
        invoke_alter "STARTPLAYBACK"
      end
      def stopPlayback
        invoke_alter "STOPPLAYBACK"
      end
      def upload
        invoke_alter "UPLOAD"
      end
      def download
        invoke_alter "DOWNLOAD"
      end
      def startRecording
        invoke_alter "STARTRECORDING"
      end
      def stopRecording
        invoke_alter "STOPRECORDING"
      end
      def delete
        invoke_alter "DELETE"
      end

    end
  end
end
