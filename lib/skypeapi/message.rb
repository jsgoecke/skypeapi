module SkypeAPI
  module Object
    class Message < AbstractObject
      OBJECT_NAME = "MESSAGE"
 
      PROPERTY2METHOD =  {
        'TIMESTAMP' => :timestamp,
        'PARTNER_HANDLE' => :partnerHandle,
        'PARTNER_DISPNAME' => :partnerDispname,
        'CONF_ID' => :confIdD,
        'TYPE' => :type,
        'STATUS' => :status,
        'FAILUREREASON' => :failureReason,
        'BODY' => :body,
      }
      
      def self.create target,text
        if defined? target.getHandle
          target = target.getHandle
        elsif target.class == String
        else
          raise target
        end
        res = @skypeApi.invoke_one "MESSAGE #{target} #{text}","MESSAGE"
        if res =~ /^(\d+) STATUS (.+)$/
          return @skypeApi.getMessage($1),"getStatus",$2
        else
          raise #????
        end
      end
      
      def timestamp() invoke_get('TIMESTAMP'); end
      def partnerHandle() invoke_get('PARTNER_HANDLE'); end
      def partnerDispname() invoke_get('PARTNER_DISPNAME'); end
      def confIdD() invoke_get('CONF_ID'); end
      def type() invoke_get('TYPE'); end
      def status() invoke_get('STATUS'); end
      def failureReason() invoke_get('FAILUREREASON'); end
      def body() invoke_get('BODY'); end
      
      #def setSeen
      #  str2object invoke_one("SET MESSAGE #{@id} SEEN","SET MESSAGE #{@id} STATUS")
      #end
    end
  end
end
