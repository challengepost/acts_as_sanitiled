require 'spec_helper'

describe 'New object with textiled description' do
  before do
    @story = Story.new
  end

  it "should have nil description" do
    @story.description.should.be.nil
  end

  it "should have nil description source" do
    @story.description_source.should.be.nil
  end

  it "should have nil description plain" do
    @story.description_plain.should.be.nil
  end
end

describe 'A standard textiled object' do
  before do
    @desc_textile = '_why announces __Sandbox__'
    @body_textile = <<EOF
First line
Second line with *bold*

Second paragraph with special char(TM), <a href="javascript:alert('shit')">XSS attribute</a>,
script>script tag</script>, and <b>unclosed tag.
EOF

    @story = Story.new(
      :title => 'The Thrilling Freaky-Freaky Sandbox Hack',
      :description => @desc_textile,
      :body => @body_textile)

    @desc_html    = '_why announces <i>Sandbox</i>'
    @desc_plain   = '_why announces Sandbox'

    @body_html    = "<p>First line<br />\nSecond line with <strong>bold</strong></p>\n<p>Second paragraph with special char\342\204\242, <a>XSS attribute</a>,<br />\nscript&gt;script tag, and <b>unclosed tag.</b></p>"
    @body_plain   = "First line\nSecond line with bold\n\nSecond paragraph with special char™, XSS attribute,\nscript>script tag, and unclosed tag."
  end

  it "should properly textilize and strip html" do
    @story.description.should.equal @desc_html
    @story.description(:source).should.equal @desc_textile
    @story.description(:plain).should.equal @desc_plain

    @story.body.should.equal @body_html
    @story.body(:source).should.equal @body_textile
    @story.body(:plain).should.equal @body_plain
  end

  it "should raise when given a non-sensical option" do
    proc{ @story.description(:cassadaga) }.should.raise
  end

  it "should pick up changes to attributes" do
    @story.description.should.equal @desc_html

    @story.description = "**IRb** is simple"
    @story.description.should.equal "<b>IRb</b> is simple"
    @story.description(:plain).should.equal "IRb is simple"
  end

  it "should be able to toggle whether textile is active or not" do
    @story.description.should.equal @desc_html
    @story.textiled = false
    @story.description.should.equal @desc_textile
  end

  it "should be able to do on-demand textile caching" do
    @story.textiled.size.should.equal 0
    @story.textilize
    @story.textiled.size.should.equal 2
    @story.description.should.equal @desc_html
  end

  it "should clear textiled hash on reload" do
    @story.textilize
    @story.textiled.size.should.equal 2
    @story.reload
    @story.textiled.size.should.equal 0
  end
end

describe 'An object with one textiled and one sanitized field' do
  before do
    @author = Author.new(
      :name => '<b>King *George*</p>',
      :bio => '*Bold* but with <script>')
  end

  it "should sanitize but not textilize name" do
    @author.name.should.equal '<b>King *George*</b>'
  end

  it "should textilize but not sanitize bio" do
    @author.bio.should.equal '<p><strong>Bold</strong> but with <script></p>'
  end
end

describe 'Defining fields on an ActiveRecord object' do
  it "should not allow both skip_textile and skip_sanitize" do
    proc do
      class Foo < ActiveRecord::Base
        acts_as_sanitiled :body, :skip_sanitize => true, :skip_textile => true
      end
    end.should.raise
  end

  it "should not allow options hash on acts_as_textiled" do
    proc do
      class Foo < ActiveRecord::Base
        acts_as_textiled :body, :option => :is_verboten
      end
    end.should.raise
  end
end

describe 'acts_as_sanitized' do
  it "uses default sanitize options if options aren't passed in" do
    ActsAsSanitiled.default_sanitize_options = { :elements => ['p', 'em', 'strong'] }
    @publisher = Publisher.new(:name => '<p>King <script></script> George</p>' )
    @publisher.name.should.equal '<p>King  George</p>'
  end
end