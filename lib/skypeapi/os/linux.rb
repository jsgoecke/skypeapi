require 'dbus'
require "thread"

module SkypeAPI
  module OS
    class Linux < Abstruct
      class Notify < DBus::Object
        dbus_interface "com.Skype.API.Client" do
          dbus_method :Notify, "in data:s" do |res|
            @os.push_queue res
          end
        end
      end
      
      def initialize service_name="org.ruby.service"
        super()
        bus = DBus.session_bus
        exobj = Notify.new("/com/Skype/Client")
        #exobj.instance_variable_set(:@queue, @queue)
        exobj.instance_variable_set(:@os, self)
        bus.request_service(service_name).export(exobj)
        service = bus.service 'com.Skype.API'
        @invoker = service.object '/com/Skype'
        @invoker.default_iface = 'com.Skype.API'
        @invoker.introspect
        
        #l = DBus::Main.new
        #l << bus
        #Thread.new do
        #  l.run
        #end
      end
      
      def attach name
        invoke "NAME #{name}"
        invoke "PROTOCOL 9999"
        if @first_attached
          @queue.push proc{do_event :attached}
        else
          @queue.push proc{do_event :reattached}
        end
      end
      
      def invoke_prototype(cmd)
        res = @invoker.Invoke('#' + @send_count.to_s + ' ' + cmd)[0]
        old_count = @send_count.to_s
        @send_count+=1
        @queue.push proc{do_event :sent, '#' + old_count + ' ' + cmd}
        @queue.push proc{do_event :received, res}
        res =~ /^##{old_count} (.*)$/m
        return $1
      end
      
      alias :invoke_block :invoke_prototype

      def invoke_callcack cmd,cb=Proc.new
        res = send_prototype(cmd)
        cb.call(res)
      end
      
      def close
      end
      
      def polling
        flag = true
        begin
          while flag
            proc = @queue.shift true
            proc.call
          end
        rescue
          flag = false
        end  
      end
      
      def push_queue res
        @queue.push(proc{do_event(:received, res)})
        
        if res == 'CONNSTATUS LOGGEDOUT'
          @attached = false
          @queue.push(proc{do_event(:detached)})
          SkypeAPI.attach
        end
            
        flag = false
        @notify.each do |reg,action|
          if res =~ reg
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
  
      
      def wait
      end

      def attach_wait(name)
          @name = name
          attach(name)
      end
    end
  end
end
