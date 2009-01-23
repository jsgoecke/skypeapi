module SkypeAPI
  module Object
    class ChatMessage < AbstractObject
      OBJECT_NAME = "CHATMESSAGE"

      def self.create chat ,msg
        res = SkypeAPI.invoke "CHATMESSAGE #{chat} #{msg}"
        if res =~ /^CHATMESSAGE (\d+) STATUS (.+)$/
          return SkypeAPI.chatMessage($1)#, $2
        else
          raise res
        end
      end
      
      getter :Body, 'BODY'
      getter :Timestamp, 'TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Partner, 'PARTNER_HANDLE' do |str|
        SkypeAPI::User.new str
      end
      getter :PartnerDispname, 'PARTNER_DISPNAME'
      getter :From, 'FROM_HANDLE' do |str|
        SkypeAPI::User.new str
      end
      getter :FromDispname, 'FROM_DISPNAME'
      getter :Type, 'TYPE'
      getter :Status, 'STATUS'
      getter :LeaveReason, 'LEAVEREASON' do |str|
        if str.empty?
          nil
        else
          str
        end
      end
      getter :Chat, 'CHATNAME' do |str|
        SkypeAPI::Chat.new str
      end
      getter :Users, 'USERS' do |str|
        str.split(',').map do |handle|
          SkypeAPI::User.new handle
        end
      end
      getter :IsEditable, 'IS_EDITABLE' do |str|
        str._flag
      end
      getter :EditedBy, 'EDITED_BY' do |str|
        if str.empty? then nil else SkypeAPI::User.new(str) end
      end
      getter :EditedTimestamp, 'EDITED_TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Options, 'OPTIONS' do |str|
        str.to_i
      end
      getter :Role, 'ROLE'
      
      def setSeen
        str = SkypeAPI.invoke "SET CHATMESSAGE #{@id} SEEN"
        if str =~ /^CHATMESSAGE #{@id} STATUS (.+)$/
          return true
        else
          raise #????
        end
      end
      
      def setBody(text) invoke_set('BODY',text._str); end
    end
  end
end
