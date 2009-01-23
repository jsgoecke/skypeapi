module SkypeAPI
  module Object
    class ChatMember < AbstractObject
      OBJECT_NAME = "CHATMEMBER"

      getter :Chat, 'CHATNAME' do |str|
        @@skypeApi.chat(str)
      end
      
      getter :User,'IDENTITY' do |str|
         @@skypeApi.user str
      end
      
      getter :Role, 'ROLE'
      
      getter :IsActive, 'IS_ACTIVE' do |str|
        str._flag
      end
      
      def setRoleTo role
        invoke_alter('SETROLETO', role)
      end
      
      def canSetRoleTo role
        #ALTER‚Å•Ô‚èŒŒ‚ª‚ ‚é‹É‚ß‚Ä“ÁŽê—áB
        res = invoke("ALTER CHATMEMBER #{@id} CANSETROLETO #{role}")
        res =~ /ALTER CHATMEMBER CANSETROLETO (TRUE|FALSE)/
        $1._flag
      end
      
    end
  end
end
