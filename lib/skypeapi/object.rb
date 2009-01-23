require 'date'

module SkypeAPI
  module Object
    
   
    #亜種をコピペ散在。
    module Notify
      def setNotify property=nil,value=nil, block=Proc.new
        property = property.to_s.downcase.to_sym if property
        value = value.to_s.upcase if value.class == Symbol
        @notify[property] = Hash.new unless @notify[property]
        @notify[property][value] = block
      end
      
      def delNotify property=nil,value=nil
        @notify[property].delete value
      end
      
      def notify
        @notify
      end
      
      def notified instance, property,value
        if @notify[nil]
          @notify[nil][nil].call instance, property, value if @notify[nil][nil]
          @notify[nil][value].call instance, property if @notify[nil][value]
        end
        if @notify[property]
          @notify[property][nil].call instance, value if @notify[property][nil]
          @notify[property][value].call instance if @notify[property][value]
        end
      end
      alias set_notify setNotify
      alias del_notify delNotify
    end
    
    module Get
      def getter methodName, skypeProperty=methodName.to_s.upcase, &callBack
        defineMethod = self == SkypeAPI ? self.class.method(:define_method) : method(:define_method)
        defineMethod.call 'get' + methodName.to_s do
          str = invoke_get skypeProperty
          callBack ? callBack.call(str) : str
        end
        
        #code4doc
        #className = (defined? self::OBJECT_NAME) ? self::OBJECT_NAME : ''#'SkypeAPI'
        #puts "'" + className + "::" + 'get' + methodName.to_s + "',"
        
        self::P2M[skypeProperty] = methodName.to_sym
        self::V2O[skypeProperty] = callBack if callBack
      end
      
      def notice methodName,skypeProperty,&block
        self::P2M[skypeProperty] = methodName.to_sym
        self::V2O[methodName] = block if block
      end
    end
    
    class AbstractObject
      extend SkypeAPI::Object::Notify
      extend Forwardable
      extend SkypeAPI::Object::Get
      include SkypeAPI::Object::Notify
      include SkypeAPI::ShareFunctions
      
      #継承引き釣り全部いり。@@instance[class][id of instance]
      @@instance = Hash.new do |hash,key|
        hash[key] = Hash.new
      end
      @@skypeApi = SkypeAPI
      
      #定数は継承してほしくない為、個別に生成。
      #Module include self.class::P2M
      #Module extend self::P2M
      #Class  P2M
      #Instance P2M でアクセス。
      def self.inherited sub
        if self == AbstractObject
          sub.const_set :P2M, Hash.new{|hash,key| hash[key] = key}
          sub.const_set :V2O, Hash.new
        end
        sub.instance_variable_set :@notify, Hash.new
      end
      
      #extendしたNotifyをオーバーライド。
      #やってるのは、値の変換と自分のnotifyとインスタンスのnotify回し。
      def self.notified msg
        if msg =~ /^([^ ]+) ([^ ]+) (.*)$/m
          id = $1; skypeProperty = $2; value = $3
          instance = new id
          property = self::P2M[skypeProperty].to_s.downcase.to_sym if self::P2M[skypeProperty].class == Symbol
          value = self::V2O[skypeProperty].call value if self::V2O[skypeProperty]
          
          if @notify[nil]
            @notify[nil][nil].call instance, property, value if @notify[nil][nil]
            @notify[nil][value].call instance, property if @notify[nil][value]
          end
          if @notify[property]
            @notify[property][nil].call instance, value if @notify[property][nil]
            @notify[property][value].call instance if @notify[property][value]
          end
          @@instance[self][id].notified instance, property, value if @@instance[self][id]
        end
      end
      
      def self.new id
        if @@instance[self][id]
          return @@instance[self][id]
        else
          instance = super id
          instance.instance_variable_set(:@notify, Hash.new do |h,k|
            h[k] = Hash.new
          end)
          @@instance[self][id] = instance
          return instance
        end
      end
      
      def initialize id
        @id = id
      end
      
      def to_s
        @id.to_s
      end
      
      def_delegators :@@skypeApi, :invoke
    end
    
  end
end
