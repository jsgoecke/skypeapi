module SkypeAPI
  module Object
    class SMS< AbstractObject
      OBJECT_NAME = "SMS"

      def self.create target, type="OUTGOING"
        res = @@skypeApi.invoke "CREATE SMS #{type} #{target}"
        res =~ /^SMS (\d+) STATUS (.+)$/
        id, status = $1, $2
        return id, status
      end
      
      def self.createConfirmationCodeRequest target
        create target, 'CONFIRMATION_CODE_REQUEST'
      end
      
      def self.createConfirmationCodeSubmit target
        create target, 'CONFIRMATION_CODE_SUBMIT'
      end
      
      def self.delete id
        @@skypeApi.invoke_echo "DELETE SMS #{id}"
      end
      
      getter :Body, 'BODY'
      getter :Type, 'TYPE'
      getter :Status, 'STATUS'
      getter :FailureReason, 'FAILUREREASON'
      getter :FailedUnseen?, 'IS_FAILED_UNSEEN'
      getter :Timestamp, 'TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Price, 'PRICE' do |str|
        str.to_i
      end
      getter :PricePrecision, 'PRICE_PRECISION' do |str|
        str.to_i
      end
      getter :PriceCurrency, 'PRICE_CURRENCY'
      getter :ReplyToNumber, 'REPLY_TO_NUMBER'
      getter :TargetNumbers, 'TARGET_NUMBERS' do |str|
        str.split(', ')
      end
      getter :TargetStatuses, 'TARGET_STATUSES' do |str|
        hash = Hash.new
        str.split(', ').each do |lump|
          pstn, status = lump.split('=')
          hash[pstn] = status
        end
        hash
      end
      
      def getChunk noOfChunks
        res = send"CHUNK #{noOfChunks}"
        return noOfChunks, res
      end
      
      def setBody text
        invoke_set "BODY", text
      end
      
      def send
        invoke_alter "SEND"
      end
      
      def delete
        invoke_echo "DLETE SMS #{@id}"
      end
      
      def setTargetNumber *nums
        nums = nums[0] if nums[0].class == Array
        invoke_set "TARGET_NUMBERS", nums.join(', ')
      end
      
      def setSeen
        invoke_set "SEEN"
      end
      
      def setReplyToNumber pstn
        invoke_set "REPLY_TO_NUMBER", pstn
      end
    end
  end
end
