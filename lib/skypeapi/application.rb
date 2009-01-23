module SkypeAPI
  module Object
    class Stream
      def initialize app, streamString
        @app = app
        @id = streamString
        @user = SkypeAPI.user(@id.split(':')[0])
      end
      
      def to_s
        @id
      end
      
      def user
        @user
      end
      
      def write msg
        @app.write self, cmd
      end
      
      def datagram msg, &block
        @app.datagram self, cmd
      end
      
      def read
        @app.read self
      end
      
      def disconnect
        @app.disconnect self
      end
    end
    
    class Application < AbstractObject
      OBJECT_NAME = "APPLICATION"
      
      getter :Connectable , 'CONNECTABLE' do |str|
        str.split(' ').collect{|i| SkypeAPI.user(i)}
      end
      
      getter :Connecting,'CONNECTING' do |str|
        str.split(' ').collect{|i| SkypeAPI.user(i)}
      end
      
      getter :Streams, 'STREAMS' do |str|
        str.split(' ').collect{|streamID| Stream.new(self, streamID)}
      end
      
      getter :Received, 'RECEIVED' do |str|
        str.split(' ').collect do |i|
          streamID, byte = i.split('=')
          {:stream => Stream.new(self, streamID),:bytes => byte.to_i}
        end
      end
      
      getter :Sending, 'SENDING' do |str|
        str.split(' ').collect do |i|
          streamID, byte = i.split('=')
          {:stream => Stream.new(self, streamID),:bytes => byte.to_i}
        end
      end
      
      notice :Datagram, 'DATAGRAM' do |str|
        user,data = str.split(' ',2)
        [SkypeAPI.user(user), data]
      end
      
      def self.create appName
        app = new appName
        app.create
        app
      end
      
      def create
        invoke_echo "CREATE APPLICATION #{@id}"
      end
      
      def connect user
        invoke_echo "ALTER APPLICATION #{@id} CONNECT #{user}"
      end
      
      def write stream, msg
        invoke_alter "WRITE", "#{stream} #{msg}"
      end
      
      def datagram stream, msg
        invoke_alter "DATAGRAM", "#{stream} #{msg}"
      end
      
      def read stream
        res = invoke "ALTER APPLICATION #{@id} READ #{stream}"
        res =~ /^ALTER APPLICATION #{@id} READ #{stream} (.*)$/m
        $1
      end
      
      def disconnect stream
        invoke_echo "ALTER APPLICATION #{@id} DISCONNECT #{stream}"
      end
      
      def delete
        invoke_echo "DELETE APPLICATION #{@id}"
      end
    end
  end
end
