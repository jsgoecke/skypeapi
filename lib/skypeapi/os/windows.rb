require 'swin'
require 'Win32API'

module SkypeAPI
  module OS
    class Windows < Abstruct
      require 'skypeapi/os/timer'
      
      WAIT_CMD_LIMIT = 10.0 #sec
      PING_CYCLE = 5.0 #sec
      PING_LIMIT = 3.0 # < PING_CYCLE
      SLEEP_INTERVAL = 0.001
      
      HWND_BROADCAST = 0xFFFF
      WM_COPYDATA = 0x004A
      WM_USER = 0x0400
      WM_USER_MSG = WM_USER + 1
      SKYPECONTROLAPI_ATTACH_SUCCESS=0
      SKYPECONTROLAPI_ATTACH_PENDING_AUTHORIZATION=1
      SKYPECONTROLAPI_ATTACH_REFUSED=2
      SKYPECONTROLAPI_ATTACH_NOT_AVAILABLE=3
      SKYPECONTROLAPI_ATTACH_API_AVAILABLE=0x8001
      
      RegisterWindowMessage = Win32API.new('user32','RegisterWindowMessageA', 'P', 'L')
      SendMessage = Win32API.new("user32", "SendMessageA", ['L']*4, 'L')
      PostMessage = Win32API.new("user32", "PostMessageA", 'LLLP', 'L')
      
      def initialize
        @send_count = 0
        @queue = Array.new
        @callback = Hash.new
        @notify = Hash.new
        @event = Hash.new do |h,k|
          h[k] = Array.new
        end
        @attached = false
        @first_attached = true
        @raise_when_detached = false
        
        @invoke_mutex = Mutex.new
        @invoke_block_mutex = Mutex.new
        
        add_event :available do
          SkypeAPI.attach
        end
        
        Timer.interval PING_CYCLE do
          invoke_callback('PING'){} if @attached
        end
        
        @reattach_mutex = Mutex.new
        
        @wmBuffer = Hash.new        
        @wmHandler = SWin::LWFactory.new(SWin::Application.hInstance).newwindow nil
        @wmHandler.create
        @wmHandler.addEvent(WM_COPYDATA)
        @wmHandler.addEvent(WM_USER_MSG)
        @wmHandler.instance_variable_set :@skypeAPI,self
        @wmHandler.instance_variable_set :@wmBuffer,@wmBuffer
        @wmHandler.instance_variable_set :@queue,@queue
        
        class << @wmHandler
          attr_reader :hSkypeAPIWindowHandle
          
          def msghandler(sMsg)
            case sMsg.msg
            when @dwAttachMsg
              case sMsg.lParam
              when SKYPECONTROLAPI_ATTACH_SUCCESS
                @hSkypeAPIWindowHandle = sMsg.wParam
                @queue.push Proc.new{@skypeAPI.invoke_callback("PROTOCOL 9999"){}}
                
                @queue.push Proc.new{@skypeAPI.do_event(:attach,:success)}
                unless @skypeAPI.attached
                  if @skypeAPI.first_attached
                    @queue.push Proc.new{@skypeAPI.do_event(:attached)}
                  else
                    @queue.push Proc.new{@skypeAPI.do_event(:reattached)}
                  end
                end
                @skypeAPI.attached = true
                @skypeAPI.first_attached = false
              when SKYPECONTROLAPI_ATTACH_PENDING_AUTHORIZATION
                @queue.push Proc.new{@skypeAPI.do_event(:attach,:authorize)}
                @queue.push Proc.new{@skypeAPI.do_event(:authorize)}
              when SKYPECONTROLAPI_ATTACH_REFUSED
                @queue.push Proc.new{@skypeAPI.do_event(:attach,:refused)}
                @queue.push Proc.new{@skypeAPI.do_event(:refused)}
                @skypeAPI.attached = false
              when SKYPECONTROLAPI_ATTACH_NOT_AVAILABLE
                @queue.push Proc.new{@skypeAPI.do_event(:attach, :not_available)}
                @queue.push Proc.new{@skypeAPI.do_event(:not_available)}
                @skypeAPI.attached = false
              when SKYPECONTROLAPI_ATTACH_API_AVAILABLE
                @queue.push Proc.new{@skypeAPI.do_event(:attach, :available)}
                @queue.push Proc.new{@skypeAPI.do_event(:available)}
              else
                @queue.push Proc.new{@skypeAPI.do_event(:attach,:unkown)}
                @queue.push Proc.new{@skypeAPI.do_event(:unkown)}
              end
              sMsg.retval = 1
              #return true
            when WM_COPYDATA
              if sMsg.wParam == @hSkypeAPIWindowHandle
                retval = application.cstruct2array(sMsg.lParam,"LLL")
                cmd = application.pointer2string(retval[2],retval[1])
                @skypeAPI.push_queue cmd
                sMsg.retval = 1
                return true
              end
            when WM_USER_MSG
              unless SendMessage.call(sMsg.wParam, WM_COPYDATA, sMsg.hWnd, sMsg.lParam)
                raise  SkypeAPIError::Connect,"Skype not ready"
              end
              sMsg.retval = true
              return true
            end
          end
        end
        
        @wmHandler.create unless @wmHandler.alive?
        @dwDiscoverMsg = RegisterWindowMessage.call("SkypeControlAPIDiscover");
        raise SkypeAPIError::Attach,"SkypeControlAPIDiscover nothing" unless @dwDiscoverMsg
        @dwAttachMsg = RegisterWindowMessage.call("SkypeControlAPIAttach")
        raise SkypeAPIError::Attach,"SkypeControlAPIAttach nothing" unless @dwAttachMsg
        @wmHandler.instance_variable_set :@dwAttachMsg, @dwAttachMsg
        @wmHandler.addEvent @dwAttachMsg
      end
      
      attr_accessor :attached, :first_attached#,:received,:sent
      
      def attach name = nil #,&block)
        #post?
        unless PostMessage.call(HWND_BROADCAST, @dwDiscoverMsg, @wmHandler.hWnd, 0)
          raise SkypeAPIError::Attach,"SkypeControlAPIDiscover broadcast fail"
        end
        return true
      end
      
      def attach_wait name = nil
        flag = true
        add_event :attached do
          flag = false
        end
        attach name
        while flag
          polling
          sleep SLEEP_INTERVAL
        end
      end
      
      def invoke_prototype num, cmd
        unless @wmHandler.hSkypeAPIWindowHandle
          raise SkypeAPIError::Attach,"NullPointerException SendSkype!"
          return false
        end
        
        cmd = '#' + num.to_s + ' ' + cmd + "\0"
        pCopyData = @wmHandler.application.arg2cstructStr("LLS",0,cmd.length+1,cmd)
        unless PostMessage.call(@wmHandler.hWnd, WM_USER_MSG, @wmHandler.hSkypeAPIWindowHandle, pCopyData)
          @wmHandler.instance_variable_set :@hSkypeAPIWindowHandle,nil
          raise SkypeAPIError::Attach,"Skype not ready"
        end
        @queue.push(proc{do_event(:sent, cmd)}) if exist_event? :sent
        return true
      end
      
      def invoke_callback cmd,cb=Proc.new
        send_count = nil
        @invoke_mutex.synchronize do
          send_count = @send_count
          @send_count += 1
        end
        
        @callback[send_count] = cb
        begin
          invoke_prototype send_count, cmd
        rescue => e
          @callback.delete(send_count)
          raise e
        end
        return true
      end
=begin
      def invoke_block cmd, waitLimit=nil
        @invoke_block_mutex.synchronize do
          res_val = nil
          current_thread = Thread.current
          invoke_callback cmd do |res|
            res_val = res
            current_thread.run
          end
          begin
            timeout 10 do
              sleep
            end
          rescue TimeoutError
            if ping
              retry
            else
              reattach
              return invoke_block(cmd)
            end
          else
            return res_val
          end
        end
      end
      
      def reattach
        @attached = false
        @queue.push(proc{do_event(:detached)})
        if @raise_when_detached
          raise SkypeAPI::Error::Attach
        else
          SkypeAPI.attach
          loop do
            if @attached
              break
            end
            sleep SLEEP_INTERVAL
          end
          p 'reattached'
        end
      end
=end
#=begin
      def invoke_block cmd, waitLimit = WAIT_CMD_LIMIT
        resVal = nil
        invoke_callback cmd do |res|
          resVal = res
        end
        startTime = Time.now
        loop do
          polling
          if resVal
            return resVal
          end
          
          if Time.now - startTime > waitLimit
            if ping
              startTime = Time.now
            else
              if @attached
                @attached = false
                @queue.push(proc{do_event(:detached)})
                SkypeAPI.attach
              end
              
              if @raise_when_detached
                raise SkypeAPI::Error::Attach
              else
                loop do
                  polling
                  if @attached
                    break
                  end
                  sleep SLEEP_INTERVAL
                end
                ret = invoke_block(cmd, waitLimit)
                return ret 
              end
            end
          end
          
          #Thread.pass
          sleep SLEEP_INTERVAL
        end
      end
#=end
      def wait someAction=nil
        if someAction.class == Proc
          @wmHandler.application.messageloop do 
            queue_process
            Timer.polling
            someAction.call
          end
        elsif block_given?
          @wmHandler.application.messageloop do
            queue_process
            Timer.polling
            yield
          end
        else
          @wmHandler.application.messageloop do
          	queue_process
          	Timer.polling
          end
        end
      end
      
      def polling
        @wmHandler.application.doevents
        Thread.pass
        queue_process
        Timer.polling
      end
      
      def close
        @wmHandler.close
      end
      
      def push_queue res
        @queue.push(proc{do_event(:received, res.chop)})
        if res =~ /^(#(\d+?) )?(.+?)\000$/m
          if $2
            if @callback[$2.to_i]
              cb = @callback[$2.to_i]
              val = $3
              @callback.delete($2.to_i)
              #@queue.push(proc{cb.call val})
              cb.call val
            end
          else
            cmd = $3
            
            if cmd == 'CONNSTATUS LOGGEDOUT'
              @attached = false
              @queue.push(proc{do_event(:detached)})
              SkypeAPI.attach
            end
            
            flag = false
            @notify.each do |reg,action|
              if cmd =~ reg
                tmp = $1
                @queue.push(proc{action.call(tmp)})
                flag = true
              end
            end
            
            unless flag
              action = @notify[nil]
              @queue.push(proc{action.call(cmd)})
            end
          end
        end
      end
      
      private
      def queue_process
        while callback = @queue.shift
          #Thread.new do
            callback.call
          #end
        end
      end
#=begin
      def ping
        resVal = nil
        invoke_callback 'PING' do |res|
          resVal = res
        end
        startTime = Time.now
        loop do
          polling##
          if resVal
            return resVal
          end
          if Time.now - startTime > PING_LIMIT
            return false
          end
          sleep SLEEP_INTERVAL
        end
      end
#=end
    end
  end
end
