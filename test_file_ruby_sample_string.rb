module StringModule

  def self.foo
    "I am from a file."
  end

end

class RubyClass

  def foo
    "I am from a file and an instance."
  end

  def with_arguments(name="")
    "My name is #{name}."
  end

end

class RubyNumber

  def pow(num=0)
    num * num
  end

  def sum(a=1, b=1)
    a+b
  end
end

