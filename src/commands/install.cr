require "../spec"
require "../manager"
require "./command"

module Shards
  module Commands
    class Install < Command
      getter :spec, :manager

      def initialize(path)
        @spec = Spec.from_file(path)
        @manager = Shards::Manager.new(spec)
      end

      # TODO: load dependencies from shards.lock if present,
      #       otherwise resolve dependencies and save shards.lock
      def run
        manager.resolve

        manager.packages.each do |package|
          if package.installed?(loose: true)
            Shards.logger.info "Using #{package.name} (#{package.version})"
          else
            Shards.logger.info "Installing #{package.name} (#{package.version})"
            package.install
          end
        end
      end
    end

    def self.install(path = Dir.working_directory)
      Install.new(path).run
    end
  end
end
