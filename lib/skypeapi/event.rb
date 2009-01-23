module SkypeAPI
  module Object    
    class Event  < AbstractObject
      OBJECT_NAME = "EVENT"
      
      def self.create id, caption, hint, block=Proc.new
        res = SkypeAPI.invoke "CREATE EVENT #{id} CAPTION #{caption} HINT #{hint}"
        res == "EVENT #{id} CREATED"
        instance = new id
        instance.setNotify block if block
        instance
      end
      
      def self.setNotify id=nil, block=Proc.new
        @notify[id] = block
      end
      
      def self.notified msg
        if msg =~ /^([^ ]+) CLICKED$/m
          id = $1
          instance = new $1
          @notify[nil].call instance if @notify[nil]
          @notify[id].call instance if @notify[id]
          @@instance[self][id].notified if @@instance[self][id]
        end
      end
      
      def notified
        @notify.call self if @notify
      end
      
      def setNotify block=Proc.new
        @notify = block
      end
      
      def self.delete id
        new(id).delete
      end
      
      def delete
        res = invoke "DELETE EVENT #{@id}"
        res == "DELETE EVENT #{@id}"
      end

      alias set_notify setNotify
      #alias del_notify delNotify

    end
  end
end
