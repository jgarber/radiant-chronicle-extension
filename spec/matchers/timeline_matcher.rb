module Webrat
  module Matchers
    
    class TimelineTags < HaveSelector
      def initialize(version_number = nil, options = {}, &block)
        @expected = "li"
        @options  = options.merge(:id=>"version-#{version_number.to_s}")
        @block    = block
        @version_number = version_number
      end
      
      def as(status)
        @status = status
        self
      end
      
      def matches?(stringlike, &block)
        @block ||= block
        matched = matches(stringlike)
        
        @block.call(matched) if @block
        status_matcher(matched) if @status
        
        matched.any?
      end
      
      def status_matcher(stringlike)
        stringlike.should HaveSelector.new("img", :id=>"version-#{@version_number}-icon",   :src=>"/images/admin/#{@status.to_s}.png")
      end
      
    end
    
    # timeline.should have_version(version_number)
    # timeline.should have_version(version_number).as(status)
    def have_version(version_number, options={})
      TimelineTags.new(version_number, options)
    end

  end
end
