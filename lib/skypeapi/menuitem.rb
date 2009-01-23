module SkypeAPI
  module Object
    class MenuItem < AbstractObject
      OBJECT_NAME = 'MENU_ITEM'
      
      def self.create h, block=Proc.new
        raise ArgumentError unless h[:id] and h[:context] and h[:caption]
        #id, context, caption, hint=nil, icon=nil, enabled=nil, enableMultipleContacts=nil, &block
        res = SkypeAPI.invoke "CREATE MENU_ITEM #{h[:id]} CONTEXT #{h[:context]} CAPTION #{h[:caption]}#{h[:hint].nil? ? '' : " HINT #{h[:hint]}"}#{h[:icon].nil? ? '' : " ICON #{h[:icon]}"}#{h[:enable].nil? ? '' : " ENABLED #{h[:enabled]}"}#{h[:enableMultipleContacts].nil? ? '' : " ENABLE_MULTIPLE_CONTACTS #{h[:enableMultipleContacts]}"}"
        res == "MENU_ITEM #{h[:id]} CREATED"
        instance = new h[:id]
        instance.setNotify block if block
        instance
      end

      def self.setNotify sym=nil, block=Proc.new
        @notify[sym] = block
      end
      
      def self.notified msg
        if msg =~ /^([^ ]+) CLICKED( ([^ ]+))? CONTEXT ([^ ]+)( CONTEXT_ID (.+))?$/m
          id = $1; context = $4; userID = $3; contextID = $6
          user = userID ? SkypeAPI.user(userID) : nil
          instance = new $1
          @notify[nil].call instance, context, user, contextID if @notify[nil]
          @notify[id].call instance, context, user, contextID if @notify[id]
          @@instance[self][id].notified instance, context, user, contextID if @@instance[self][id]
        end
      end
      
      def notified instance, context, user, contextID
        @notify.call instance, context, user, contextID if @notify
      end
      
      def setNotify block=Proc.new
        @notify = block
      end
      
      def self.delete id
        new(id).delete
      end
      
      def delete
        res = SkypeAPI.invoke "DELETE MENU_ITEM #{@id}"
        res == "DELETE MENU_ITEM #{@id}"
      end
      
      def setCaption caption
        res = invoke "SET MENU_ITEM #{@id} CAPTION #{caption}"
        res == "MENU_ITEM #{@id} CAPTION \"#{caption}\""
      end
      
      def setHint hint
        res = invoke "SET MENU_ITEM #{@id} HINT #{hint}"
        res == "MENU_ITEM #{@id} HINT \"#{hint}\""
      end
      
      def setEnabled flag
        res = invoke "SET MENU_ITEM #{@id} ENABLED #{flag._str}"
        res == "MENU_ITEM #{@id} ENABLED #{flag._str}"
      end
      
      alias set_notify setNotify
      #alias del_notify delNotify
      alias set_caption setCaption
      alias set_hint setHint
      alias set_enabled setEnabled
    end
  end
end
