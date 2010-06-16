$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rails'
require 'acts_as_sanitiled'
require 'bacon'

class ActiveRecord
  class Base
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes.dup.stringify_keys
    end

    def method_missing(name, *args)
      if name.to_s[%r{=}]
        @attributes[key = name.to_s.sub('=','')] = value = args.first
        write_attribute key, value
      else
        self[name.to_s]
      end
    end

    def [](value)
      @attributes[value.to_s.sub('_before_type_cast', '')]
    end
  end
end unless defined? ActiveRecord

ActiveRecord::Base.send(:include, ActsAsSanitiled)

class Story < ActiveRecord::Base
  acts_as_sanitiled :body
  acts_as_sanitiled :description, [:lite_mode]
end

class Author < ActiveRecord::Base
  acts_as_sanitized :name, :elements => ['b','em']
  acts_as_textiled :bio
end

class Publisher < ActiveRecord::Base
  acts_as_sanitized :name
end

Bacon.summary_on_exit
