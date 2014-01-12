unless defined?(CommandWithErrors)
  class CommandWithErrors < Imperator::Command
    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end
  end
end
