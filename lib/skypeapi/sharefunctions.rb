class NilClass
  def _flag
    nil
  end
  
  def _swi
    nil
  end
  
  def _str
    ""
  end
  
  def _int
    nil
  end
end

class String
  def _flag
    case self
    when /^(TRUE)|(ON)$/i
      return true
    when /^(FALSE)|(OFF)$/i
      return false
    else
      self
    end
  end
  
  def _int
    self.empty? ? nil : self.to_i
  end
  
  def _str
    self
  end
end

class TrueClass
  def _swi
    "ON"
  end
  
  def _str
    "TRUE"
  end
end

class FalseClass
  def _swi
    "OFF"
  end
  
  def _str
    "FALSE"
  end
end

module SkypeAPI
  
  module ShareFunctions
    #private
    
    #ex
    #invoke_echo "CREATE APPLICATION #{@appName}"
    #CREATE APPLICATION #{@appName} -> CREATE APPLICATION #{@appName}
    def invoke_echo cmd
      begin
        invoke(cmd) == cmd
        rescue SkypeAPIError
          raise $!, caller(1)
        end
      end
    #ex
    #invoke_one "GET CHATMESSAGE #{@id} BODY","CHATMESSAGE #{@id} BODY"
    #GET CHATMESSAGE #{@id} BODY -> CHATMESSAGE #{@id} BODY (.+)
    def invoke_one cmd, regExp=cmd
      regExp.gsub!(/[\^$.\\\[\]*+{}?|()]/) do |char|
        "\\" + char
      end
      begin
        invoke(cmd) =~ /^#{regExp} (.*)$/m
        return $1
      rescue SkypeAPIError => e
        raise $!, caller
      end
    end
    
    #ex
    #invoke_get("GET USER #{@handle} SkypeOut")
    #GET USER #{@handle} SkypeOut -> USER #{@handle} SkypeOut (.+)
    def invoke_get prop, value=nil
      cmd = "GET #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s+' ' : ''}#{prop}#{value ? ' ' + value : ''}"
      reg = "#{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s+' ' : ''}#{prop}#{value ? ' ' + value : ''}".gsub(/[\^$.\\\[\]*+{}?|()]/) do |char|
        "\\" + char
      end
      begin
        invoke(cmd) =~ /^#{reg} (.*)$/m
        return $1
      rescue SkypeAPIError
        raise $!, caller
      end
    end
    
    def invoke_set prop,value=nil
      cmd = "SET #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}#{value ? ' '+value.to_s : '' }"
      reg = "#{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}"
      begin
        str = invoke_one cmd, reg
      rescue SkypeAPIError
        raise $!, caller
      end
      if self.class == Module
        self::V2O[prop] ? self::V2O[prop].call(str) : str
      else
        self.class::V2O[prop] ? self.class::V2O[prop].call(str) : str
      end
    end
    
    #trueしか返さない。送りっぱなし。それ以外の返り血があるようなのははinvokeで実装せよ。
    def invoke_alter prop, value=nil
      cmd = "ALTER #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}#{value ? ' '+value.to_s : '' }"
      #res = "ALTER #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}"
      #reg.gsub!(/[\^$.\\\[\]*+{}?|()]/) do |char|
      #  "\\" + char
      #end
      #res = "ALTER #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{prop}"
      begin
        invoke(cmd)# == res
      rescue SkypeAPIError
        raise $!, caller
      end
      true
    end
    
    #def sendAlterWithID prop, value=nil
    #  str = invoke_one "ALTER #{self.class::OBJECT_NAME} #{@id} #{prop}#{value ? ' '+value.to_s : '' }","ALTER #{self.class::OBJECT_NAME} #{@id} #{prop}"
    #  self.class::V2O[self.class::P2M[prop]] ? self.class::V2O[self.class::P2M[prop]].call(str) : str
    #end
  end
end
