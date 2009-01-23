module SkypeAPI
  module Object
    class Call < AbstractObject
      OBJECT_NAME = "CALL"
      
      def self.create *targets
        res = (SkypeAPI.invoke_one "CALL " + targets.join(", "),"CALL").split(" ")
        #return SkypeAPI::Call.new(res[0]),res[2]
        new res[0]
      end
      
      getter :Timestamp, 'TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Partner, 'PARTNER_HANDLE' do |str|
        SkypeAPI::User.new str
      end
      getter :PartnerDispname, 'PARTNER_DISPNAME'
      getter :TargetIdentity, 'TARGET_IDENTITY'
      getter :ConfID, 'CONF_ID' do |str|
        str.to_i
      end
      getter :Type, 'TYPE'
      getter :Status, 'STATUS'
      getter :VideoStatus, 'VIDEO_STATUS'
      getter :VideoSendStatus, 'VIDEO_SEND_STATUS'
      getter :VideoReceiveStatus, 'VIDEO_RECEIVE_STATUS'
      getter :FailureReason, 'FAILUREREASON' do |str|
        str.to_i
      end
      #getter :Subject, 'SUBJECT'
      getter :PSTNNumber, 'PSTN_NUMBER'
      getter :Duration, 'DURATION' do |str|
        str.to_i
      end
      getter :PSTNStatus, 'PSTN_STATUS'
      getter :ConfParticipantsCount, 'CONF_PARTICIPANTS_COUNT' do |str|
        str.to_i
      end
      
      notice :ConfParticipant, 'CONF_PARTICIPANT'  do |str|
        res = str.split(' ')
        res[1] = SkypeAPI::User.new res[1] if res[1]
        res
      end
      #?CALL 59 CONF_PARTICIPANT 1 echo123 INCOMING_P2P INPROGRESS Echo Test Service . 
      def getConfParticipant num
        str = invoke_get "CONF_PARTICIPANT #{num}"
        res = str.split(' ')
        res[0] = SkypeAPI::User.new res[0]
        res
      end
      
      getter :VMDuration, 'VM_DURATION' do |str|
        str.to_i
      end
      getter :VMAllowedDuration, 'VM_ALLOWED_DURATION' do |str|
        str.to_i
      end
      
      getter :Rate, 'RATE' do |str|
        str.to_i
      end
      getter :RateCurrency, 'RATE_CURRENCY'
      getter :RatePrecision, 'RATE_PRECISION' do |str|
        str.to_f #?
      end
      
      getter :Input, 'INPUT'
      getter :Output, 'OUTPUT'
      getter :CaptureMic, 'CAPTURE_MIC'
      getter :VAAInputStatus, 'VAA_INPUT_STATUS' do |str|
        str._flag
      end
            
      getter :ForwardedBy, 'FORWARDED_BY' do |str|
        if str.empty? or str == '?'
          nil
        else
          SkypeAPI::User.new str
        end
      end
      getter :TransferActive, 'TRANSFER_ACTIVE' do |str|
        str._flag
      end
      getter :TransferStatus, 'TRANSFER_STATUS'
      getter :TransferredBy, 'TRANSFERRED_BY' do |str|
        if str.empty?
          nil
        else
          SkypeAPI::User.new str
        end
      end
      getter :TransferredTo, 'TRANSFERRED_TO' do |str|
        if str.empty?
          nil
        else
          SkypeAPI::User.new str
        end
      end

      def getCanTransfer user
        res = invoke_get "CAN_TRANSFER #{user}"
        V2O[:CanTransffer].call(user.to_s + ' ' + res)
      end
      notice :CanTransffer, 'CAN_TRANSFER' do |str|
        str.split(' ')[1]._flag
      end
            
      getter :Seen, "SEEN" do |str|
        str._flag
      end
      
      #Notify?
      #getter :DTMF, "DTMF" do |str|
      #  str.to_i
      #end
      #getter :JoinConference, "JOIN_CONFERENCE"
      #getter :StartVideoSend, "START_VIDEO_SEND"
      #getter :StopVideoSend, "STOP_VIDEO_SEND"
      #getter :StartVideoReceive, "START_VIDEO_RECEIVE"
      #getter :StopVideoReceive, "STOP_VIDEO_RECEIVE"
      
      def setSeen
        invoke_set "SEEN"
      end
      
      def setStatus s
        invoke_set "STATUS", s
      end
      
      def setStatusOnHold
        setStatus "ONHOLD"
      end
      
      def setStatusInprogress
        setStatus "INPROGRESS"
      end
      
      def setStatusFinished
        setStatus "FINISHED"
      end
      
      #def setDTMF number
      #  invoke_set "DTMF #{number}"
      #end
      
      def setJoinConference masterCall
        invoke_set "JOIN_CONFERENCE", masterCall.to_s
      end
      
      def setStartVideoSend
        invoke_set "START_VIDEO_SEND"
      end
      
      def setStopVideoSend
        invoke_set "STOP_VIDEO_SEND"
      end
      
      def setStartVideoReceive
        invoke_set "START_VIDEO_RECEIVE"
      end
      
      def setStopVideoReceive
        invoke_set "STOP_VIDEO_RECEIVE"
      end
      
      def answer
        invoke_alter "ANSWER"
      end
      
      def hold
        invoke_alter "HOLD"
      end
      
      def resume
        invoke_alter "RESUME"
      end
      
      def hangup
        invoke_alter "HANGUP"
      end
      
      def end val=''
        invoke_alter "END", val  
      end
      
      def dtmf number
        invoke_alter "DTMF", number
      end
      
      def transfer *users
        invoke_alter "TRANSFER", users.join(', ')
      end
      
      def joinConference call
        invoke_alter "JOIN_CONFERENCE"
      end
      
      def startVideoSend
        invoke_alter "START_VIDEO_SEND"
      end

      def stopVideoSend
        invoke_alter "STOP_VIDEO_SEND"
      end
      
      def startVideoReceive
        invoke_alter "START_VIDEO_RECEIVE"
      end
      
      def stopVideoReceive
        invoke_alter"STOP_VIDEO_RECEIVE"
      end
      
      def setInput device
        invoke_alter "SET_INPUT", device
      end
      
      def setOutput device
        invoke_alter "SET_OUTPUT", device
      end
      
      def setCaptureMic device
        invoke_alter "SET_CAPTURE_MIC", device
      end
      
      
      def alter value
        invoke_one "ALTER CALL #{@id} #{value}","ALTER CALL #{@id}"
      end
    end
  end
end
