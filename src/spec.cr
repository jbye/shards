require "yaml"
require "./dependency"

module Shards
  class Spec
    getter :name, :version, :authors, :dependencies

    def self.from_file(path)
      path = File.join(path, SPEC_FILENAME) if File.directory?(path)
      from_yaml(File.read(path))
    end

    def self.from_yaml(data : String)
      config = YAML.load(data)
      raise Error.new("invalid spec") unless config.is_a?(Hash)
      new(config)
    end

    def initialize(@config)
      @name = config["name"].to_s.strip
      @version = config["version"].to_s.strip
      @authors = to_authors(config["authors"]?)
      @dependencies = to_dependencies(config["dependencies"]?)
    end

    private def to_authors(ary)
      if ary.is_a?(Array)
        ary.map(&.to_s.strip)
      else
        [] of String
      end
    end

    private def to_dependencies(hsh)
      dependencies = [] of Dependency

      if hsh.is_a?(Hash)
        hsh.map do |name, h|
          config = {} of String => String

          case h
          when Hash
            h.each { |k, v| config[k.to_s.strip] = v.to_s.strip }
          when String
            config["version"] = h.strip
          end

          dependencies << Dependency.new(name.to_s.strip, config)
        end
      end

      dependencies
    end
  end
end
