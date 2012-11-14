require 'ostruct'
require 'rubygems'
require 'ruby-debug'

class Genesis
  @@current_chapter = 1
  @@current_section = 1
  class << self
    def current_chapter
      @@current_chapter
    end

    def current_section
      @@current_section
    end

    def next_section
      @@current_section += 1
    end
  end
end

class Object
  def method_missing(*args, &block)
    what = args.first
    what = What.is(what)
    if block
      x = block.call(what)
      what.+ x if x.is_a?(What)
    end
    what
  end

  def the(*args, &block)
    what = args.first
    raise "what?" unless what
    what = What.is(what) unless what.is_a?(What)
    what.specific = true
    if block_given?
      x = block.call(what)
      what.+ x if x.is_a?(What)
    end
    what
  end

def __method__
  caller[0]=~/`(.*?)'/  # note the first quote is a backtick
  $1
end

end



def In(*args, &block)
  what = args.first
  yield if block_given?
  God.knew "#{__method__} #{what}"
  God.tells and God.rest
end

alias :And :In

#def form
#  the(:form)
#end

class What < OpenStruct
  @@created = {}

  class << self
    def is(name)
      if name.is_a?(What)
        name
      else
        @@created[name] ||= self.new(:name => name)
      end
    end
  end

  def initialize(*args)
    super
    self.within = []
    self.without = []
    self.reject = false
    self.specific = false
  end

  def getBinding
    binding
  end

  def +(what)
    if what.is_a?(Symbol) && respond_to?(what)
      send(what)
    else
      what = What.is(what)
      if what.reject
        self.without << what unless self.without.include?(what)
      else
        self.within << what unless self.within.include?(what)
      end
      what.within.map {|w| self.+(w) if self != w }
    end
    self
  end

  def and(what)
    God.knows "and #{what}"
    self.+(what)
  end

  def to_s
    "#{the}#{self.name}"
  end

  def the
    self.specific ? "the " : ""
  end

end

class God

  @@created = []
  @@knows = []

  class << self
    def created(what)
      God.knew "God created #{what}"
      @@created << what
    end

    def knows(event = nil)
      @@knows << event if event
      @@knows
    end

    def knew(event = nil)
      @@knows.unshift event if event
      @@knows
    end

    def tells
      telling = God.knows.join " "
      p "#{Genesis.current_chapter}.#{Genesis.current_section} #{telling}"
      telling
    end

    def rest
      @@knows = []
      Genesis::next_section
    end
  end
  
end

#heaven = Resource.new(:name => "heaven")
#earth = Resource.new

#def created(what)
#  p what
#end

def without(what)
  God.knows "without #{what}"
  what = What.is(what)
  what.reject = true
  what
end

def was(what)
  God.knew "was"
  What.is(what)
end

def upon(what)
  God.knows "upon"
  What.is(what)
end

def of(what)
  God.knows "of"
  What.is(what)
end