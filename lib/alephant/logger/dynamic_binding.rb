module DynamicBinding
  class LookupStack
    def initialize(bindings = [])
      @bindings = bindings
    end

    def method_missing(m, *args)
      @bindings.reverse_each do |bind|
        begin
          method = eval('method(%s)' % m.inspect, bind)
        rescue NameError
        else
          return method.call(*args)
        end
        begin
          value = eval(m.to_s, bind)
          return value
        rescue NameError
        end
      end
      raise NoMethodError, 'No such variable or method: %s' % m
    end

    def run_proc(p, *args)
      instance_exec(*args, &p)
    end
  end
end

class Proc
  def call_with_binding(bind, *args)
    DynamicBinding::LookupStack.new([bind]).run_proc(self, *args)
  end
end
