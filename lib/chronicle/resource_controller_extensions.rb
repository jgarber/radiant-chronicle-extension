module Chronicle::ResourceControllerExtensions
  def self.included(base)
    base.class_eval do
      alias_method_chain :load_model, :current_version
    end
  end
  
  def load_model_with_current_version
    model = load_model_without_current_version
    unless %w(remove destroy).include?(action_name)
      self.model = model.respond_to?(:current) ? model.current : model
    end
  end
end