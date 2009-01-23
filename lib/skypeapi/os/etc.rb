module SkypeAPI
  module OS
    module Share
      def invoke cmd, method=nil, &block
        method = method ? method : block
        if method
          invoke_callback cmd do |res|
            check_response res,cmd
            method.call res
          end
          return true
        else
          begin
            return check_response(invoke_block(cmd), cmd)
          rescue SkypeAPIError
            raise $!, caller(1)
          end
        end
      end
      
      #ŽÀ‚Íreg==nil‚ÅA‚»‚Ì‘¼‚ÆŒ¾‚¤ã©B
      def add_notify reg, block=Proc.new
        @notify[reg] = block
      end
      
      def del_notify reg
        @notify.delete reg
      end
      
      def add_event sym, block=Proc.new
        @event[sym].push block
        block
      end
      
      #def set_event sym, block=Proc.new
      #  @event[sym] = Array.new
      #  add_event sym, block
      #end
      
      def del_event sym, block=nil
        unless block
          @event[sym] = Array.new
        else
          @event[sym].delete block
        end
      end
      
      def exist_event? sym
        if @event[sym].length > 0
          return true
        else
          return false
        end
      end
      
      def get_event sym
        @event[sym]
      end
      
      def do_event sym,*args
        @event[sym].each do |e|
          if e.arity == 1
            e.call args[0]
          else
            e.call args
          end
        end
      end
      
      private
      
      def check_response res,cmd
        if res =~ /^ERROR /m
          raise SkypeAPIError::API,res, caller
        else
          return res
        end
      end
      
    end
    
    class Abstruct
      include Share
      
      def initialize
        @send_count = 0
        @queue = Queue.new
        #@queue = Array.new
        @notify = Hash.new
        @event = Hash.new do |h,k|
          h[k] = Array.new
        end
        @attached = false
        @first_attached = true
        @raise_when_detached = false
      
      end
      
      def invoke_callback cmd, callback = Proc.new
      end
      
      def invoke_block cmd
      end
      
      def attach name = nil
      end
            
      def attach_wait name = nil
      end
      
      def wait action = nil
      end
      
      def polling
      end
      
      def close
      end
      
      private
      def invoke_prototype cmd
      end
    end
  end
  
  class Mac
    #wiki like
    def initialize
      raise SkypeAPIError::NotImplement
    end
  end
end
