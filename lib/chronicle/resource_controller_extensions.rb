module Chronicle::ResourceControllerExtensions
  def self.included(base)
    base.class_eval do
      alias_method_chain :load_model, :version
    end
  end
  
  def load_model_with_version
    model = load_model_without_version
    unless %w(remove destroy).include?(action_name) ||
      (action_name == "update" && params["page"] && params["page"]["status_id"].to_i >= Status[:published].id)
        self.model = case
        when params[:version] && version = model.versions.get_version(params[:version].to_i)
          flash[:notice] = "Loaded version #{version.number}. Click save to revert to this content."
          version.instance
        when model.respond_to?(:current)
          model.current
        else
          model
        end
    end
  end
end