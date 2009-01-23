module SkypeAPI
  module Object
    class Group < AbstractObject
      OBJECT_NAME = "GROUP"
      
      def self.create displayName
        @@skypeApi.invoke("CREATE GROUP #{displayName}")
        group = nil
        tmp = nil
        if @@skypeApi.Group.notify[:displayname] and @@skypeApi.Group.notify[:displayname][displayName]
          tmp = @@skypeApi.Group.notify[:displayname][displayName]
        end
        @@skypeApi.Group.setNotify :DisplayName, displayName do |g|
          group = g
        end
        until group
          @@skypeApi.polling
          sleep 0.0123
        end
        if tmp
          @@skypeApi.Group.setNotify :DisplayName, displayName, tmp
          tmp.call group
        else
          @@skypeApi.Group.notify[:displayname][displayName] = nil
        end
        group
        #ThreadSafe ‚ª‘å•Ï‚¾‚ë‚¤‚È‚ŸBBB
      end
      
      getter :Type, 'TYPE'
      getter :CustomGroupID, 'CUSTOM_GROUP_ID' do |str|
        str.to_i
      end
      getter :DisplayName, 'DISPLAYNAME'
      getter :NrofUsers, 'NROFUSERS' do |str|
        str.to_i
      end
      getter :NrofUsersOnline, 'NROFUSERS_ONLINE' do |str|
        str.to_i
      end
      getter :Users, 'USERS' do |str|
        str.split('./')
      end
      getter :Visible, 'VISIBLE' do |str|
        str._flag
      end
      getter :Expanded, 'EXPANDED' do |str|
        str._flag
      end
      
      def setDisplayName dispname
        invoke_set "DISPLAYNAME", dispname
      end
      
      def delete
        invoke_echo "DELETE GROUP #{@id}"
      end
      
      def addUser user
        invoke_alter "ADDUSER", user
      end
      
      def removeUser user
        invoke_alter "REMOVEUSER", user
      end
      
      def share msg=''
        invoke_alter "Share", msg
      end
      
      def accept
        invoke_alter "ACCEPT"
      end
      
      def decline
        invoke_alter "DECLINE"
      end
      
    end
  end
end
