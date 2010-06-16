require 'rubygems'
require 'sanitize'
require 'RedCloth'
require 'active_support'

module ActsAsSanitiled #:nodoc: all
  mattr_accessor :default_redcloth_options
  mattr_accessor :default_sanitize_options

  @@default_redcloth_options = []
  @@default_sanitize_options = Sanitize::Config::RELAXED

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def acts_as_textiled(*attributes)
      raise "only acts_as_sanitized or acts_as_sanitiled can take an options hash" if attributes.last.is_a?(Hash)

      attributes << {:skip_sanitize => true}
      acts_as_sanitiled(*attributes)
    end

    def acts_as_sanitized(*attributes)
      options = attributes.last.is_a?(Hash) ? attributes.pop : {}
      options[:skip_textile] = true
      attributes << options
      acts_as_sanitiled(*attributes)
    end

    def acts_as_sanitiled(*attributes)
      @textiled_attributes ||= []

      @textiled_unicode = String.new.respond_to? :chars

      options = attributes.last.is_a?(Hash) ? attributes.pop : nil
      skip_textile = options && options.delete(:skip_textile)
      skip_sanitize = options && options.delete(:skip_sanitize)

      raise 'Both textile and sanitize were skipped' if skip_textile && skip_sanitize

      sanitize_options = options.nil? || options.empty? ? ActsAsSanitiled.default_sanitize_options : options
      red_cloth_options = attributes.last && attributes.last.is_a?(Array) ? attributes.pop : ActsAsSanitiled.default_redcloth_options

      raise 'No attributes were specified to filter' if attributes.empty?

      type_options = %w( plain source )

      attributes.each do |attribute|
        define_method(attribute) do |*type|
          type = type.first

          if type.nil? && self[attribute]
            if textiled[attribute.to_s].nil?
              string = self[attribute]
              string = RedCloth.new(string, red_cloth_options).to_html unless skip_textile
              string = Sanitize.clean(string, sanitize_options) unless skip_sanitize
              textiled[attribute.to_s] = string
            end
            textiled[attribute.to_s]
          elsif type.nil? && self[attribute].nil?
            nil
          elsif type_options.include?(type.to_s)
            send("#{attribute}_#{type}")
          else
            raise "I don't understand the `#{type}' option.  Try #{type_options.join(' or ')}."
          end
        end

        define_method("#{attribute}_plain",  proc { strip_html(__send__(attribute)) if __send__(attribute) } )
        define_method("#{attribute}_source", proc { __send__("#{attribute}_before_type_cast") } )

        @textiled_attributes << attribute
      end

      include ActsAsSanitiled::InstanceMethods
    end

    def textiled_attributes
      Array(@textiled_attributes)
    end
  end

  module InstanceMethods
    def textiled
      textiled? ? (@textiled ||= {}) : @attributes.dup
    end

    def textiled?
      @is_textiled != false
    end

    def textiled=(bool)
      @is_textiled = !!bool
    end

    def textilize
      self.class.textiled_attributes.each { |attr| __send__(attr) }
    end

    def reload(*args)
      textiled.clear
      super
    end

    def write_attribute(attr_name, value)
      textiled[attr_name.to_s] = nil
      super
    end

  private
    def strip_html(html)
      html.gsub!(%r{</p>\n<p>}, "</p>\n\n<p>") # Workaround RedCloth 4.2.x issue
      Nokogiri::HTML::DocumentFragment.parse(html).inner_text
    end
  end
end
