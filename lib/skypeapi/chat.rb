module SkypeAPI
  module Object
    class Chat < AbstractObject      
      OBJECT_NAME =  "CHAT"
      
      def self.create *users
        retVal = SkypeAPI.invoke "CHAT CREATE #{users.join(', ')}"
        retVal =~ /^CHAT ([^ ]+) STATUS (.+)$/
        chatID, status = $1, $2
        return SkypeAPI::Chat.new(chatID)#, status
      end
      
      def self.findUsingBlob blob
        retVal = SkypeAPI.invoke "CHAT FINDUSINGBLOB #{blob}"
        retVal =~ /^CHAT ([^ ]+) STATUS (.+)$/
        chatID, status = $1, $2
        return SkypeAPI::Chat.new(chatID)#, status
      end
      
      def self.createUsingBlob blob
        retVal = SkypeAPI.invoke "CHAT CREATEUSINGBLOB #{blob}"
        retVal =~ /^CHAT ([^ ]+) STATUS (.+)$/
        chatID, status = $1, $2
        return SkypeAPI::Chat.new(chatID)#, status
      end
            
      getter :Name, 'NAME'
      getter :Timestamp, 'TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Adder, 'ADDER' do |str|
        str.empty? ? nil : SkypeAPI::User.new(str)
      end
      getter :Status, 'STATUS'
      getter :Posters, 'POSTERS' do |str|
        str.split(', ').map do |handle|
          SkypeAPI::User.new handle
        end
      end
      getter :Members, 'MEMBERS' do |str|
        str.split(' ').map do |handle|
          SkypeAPI::User.new handle
        end
      end
      getter :Topic, 'TOPIC'
      getter :TopicXML, 'TOPICXML'
      getter :ChatMessages, 'CHATMESSAGES' do |str|
        str.split(' ').map do |id|
          SkypeAPI::ChatMessage.new id
        end
      end
      getter :ActiveMembers, 'ACTIVEMEMBERS' do |str|
        str.split(' ').map do |handle|
          SkypeAPI::User.new handle
        end
      end
      getter :FriendlyName, 'FRIENDLYNAME'
      getter :RecentChatMessages, 'RECENTCHATMESSAGES' do |str|
        str.split(' ').map do |handle|
          SkypeAPI::ChatMessage.new handle
        end
      end
      getter :Bookmarked, 'BOOKMARKED' do |str|
        str._flag
      end
      getter :MemberObjects, 'MEMBEROBJECTS' do |str|
        str.split(', ').map do |id|
          SkypeAPI::ChatMember.new id
        end
      end
      getter :PasswordHint, 'PASSWORDHINT'
      getter :GuideLines, 'GUIDELINES'
      getter :Options, 'OPTIONS' do |str|
        str.to_i
      end
      getter :Description, 'DESCRIPTION'
      getter :DialogPartner, 'DIALOG_PARTNER' do |str|
        if str.empty?
           nil
        else
          SkypeAPI::User.new str
        end
      end
      getter :ActivityTimestamp, 'ACTIVITY_TIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :Type, 'TYPE'
      getter :MyStatus, 'MYSTATUS'
      getter :MyRole, 'MYROLE'
      getter :Blob, 'BLOB'
      getter :Applicants, 'APPLICANTS' do |str|
        str.split(' ').map do |handle|
          SkypeAPI::User.new handle
        end
      end
            
      #‚ [
      #def open
      #  retVal = invoke "OPEN CHAT #{@id}"
      #  retVal =~ /^OPEN CHAT (.+)$/
      #  return SkypeAPI.chat($1)
      #end
      
      def setTopic topic
        invoke_alter "SETTOPIC", topic
      end

      def setTopicXML topic
        invoke_alter "SETTOPICXML", topic
      end
      
      def addMembers *members
        invoke_alter "ADDMEMBERS",  members.join(', ')
      end
      
      def leave
        invoke_alter "LEAVE"
      end
      
      def bookmarked
        invoke_alter "BOOKMARK"
      end
      
      def unbookmarked
        invoke_alter "UNBOOKMARK"
      end
      
      def join
        #
        invoke_alter "JOIN"
      end
      
      def clearRecentMessages
        invoke_alter "CLEARRECENTMESSAGES"
      end
      
      def setAlertString string
        invoke_alter "SETALERTSTRING", string
      end
      
      def acceptadd
        invoke_alter "ACCEPTADD"
      end
      
      def disband
        invoke_alter "DISBAND"
      end
      
      
      def setPassword(password, passwordHint='')
        invoke_alter "SETPASSWORD", password + ' ' + passwordHint
      end
      
      def enterPassword password
        invoke_alter "ENTERPASSWORD", password
      end
      
      def setOptions option
        invoke_alter "SETOPTIONS", option
      end

      def kick *users
        users = users.join ', '
        invoke_alter "KICK", users
      end
      
      def kickBan *users
        users = users.join ', '
        invoke_alter "KICKBAN", users
      end
      
      def setGuideLines guidlines
        invoke_alter 'SETGUIDELINES', guidlines
      end
      
      def setOptions optionsBitmap
        invoke_alter 'SETOPTIONS', optionsBitmap.to_s
      end
      
      def sendMessage msg
        SkypeAPI::ChatMessage.create self, msg
      end
      alias send_message sendMessage
    end
  end
end
