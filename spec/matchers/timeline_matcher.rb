module Webrat
  module Matchers
    
    class TimelineTags < HaveSelector
      def initialize(version_number = nil, &block)
        @expected = "li"
        @options  = {:id=>"version-#{version_number.to_s}"}
        @block    = block
        @version_number = version_number
      end
      
      def as(status)
        @status_selector = HaveSelector.new("img", :id=>"version-#{@version_number}-icon",   :src=>"/images/admin/#{status.to_s}.png")
        self
      end
      
      def matches?(stringlike, &block)
        @block ||= block
        matched = matches(stringlike)
        
        matched.any? && 
          (!@status_selector || @status_selector.matches?(matched)) && 
          (!@block || @block.call(matched))
      end
      
    end
    
    # timeline.should have_version(version_number)
    # timeline.should have_version(version_number).as(status)
    def have_version(version_number)
      TimelineTags.new(version_number)
    end

  end
end
