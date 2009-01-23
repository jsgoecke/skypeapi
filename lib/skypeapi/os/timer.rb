#module SkypeAPI
#  module OS
#    class Windows
			class Timer
			  class << self
			    def interval term, block=Proc.new
			      Interval.new term, block
			    end
			    
			    def timeout term, block=Proc.new
			      Timeout.new term, block
			    end
			    
			    def delete instance
			      case instance.class
			      when Timeout
			        instance.delete
			      when Interval
			        instance.delete
			      else
			        raise ArgumentError
			      end
			    end
			    
			    def polling
			      now = Time.now.to_i
			      Timeout.polling now
			      Interval.polling now
			    end
			  end
			  
			  class Abstruct
			    
			    class << self
			      
			      def new term, block
			        instance = super
			        @stack << instance
			        return instance
			      end
			      
			      def delete instance
			        @stack.delete instance
			      end
			      
			    end
			    
			    
			    def delete
			      self.class.delete self
			    end
			    
			    attr_reader :term, :block
			    
			  end
			  
			  class Timeout < Abstruct
			    @stack = Array.new
			    class << self
			      
			      def polling now
			        @stack.delete_if do |timeout|
			          if now >= timeout.term
			            timeout.block.call
			            true
			          else
			            false
			          end
			        end
			      end
			      
			    end
			    
			    def initialize term, block
			      @term = term + Time.now.to_i
			      @block = block
			    end
			    
			  end
			  
			  class Interval < Abstruct
			    @stack = Array.new
			    
			    class << self
			      
			      def polling now
			        @stack.each do |interval|
			          if now >= interval.term + interval.old
			            interval.old = now
			            interval.block.call
			          end
			        end
			      end
			      
			    end
			    
			    def initialize term, block
			      @term = term
			      @old = Time.now.to_i
			      @block = block
			    end
			    
			    attr_accessor :old
			  end
			end
#		end
#	end
#end