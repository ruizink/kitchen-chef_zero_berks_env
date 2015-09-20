# -*- coding: utf-8 -*-

require 'kitchen/provisioner/chef_zero'

module Kitchen
  module Provisioner
    # Tweaked Chef Zero provisioner that enables Berkshelf to load
    # cookbook restrictions from Chef environments.
    #
    # @author Mario Santos <mario.rf.santos@gmail.com>
    class ChefZeroBerksEnv < ChefZero
      # Performs a Berkshelf cookbook resolution inside a common mutex.
      #
      # @api private
      def resolve_with_berkshelf
        # Load Berksfile
        berks = ::Berkshelf::Berksfile.from_file(berksfile)

        chef_environment = config[:client_rb][:environment]

        # skip if the environment was not specified
        unless chef_environment.nil?
          info("Loading chef environment '#{chef_environment}'...")
          debug("Using environment from '#{config[:environments_path]}/#{chef_environment}.json'")

          environment_json = JSON.parse(File.read("#{config[:environments_path]}/#{chef_environment}.json"))

          ::Berkshelf.ui.mute do
            info("Resolving dependency graph with Berkshelf #{::Berkshelf::VERSION}...")
            berks.install
            info("Locking the versions fetched from the chef environment '#{chef_environment}'...")
            unless environment_json['cookbook_versions'].nil?
              berks.lockfile.graph.each do | graphitem |
                version = environment_json['cookbook_versions'][graphitem.name]
                unless version.nil? || berks.has_dependency?(graphitem.name)
                  info("Adding Berkshelf dependency: #{graphitem.name} (#{version})")
                  berks.add_dependency(graphitem.name, version)
                end
              end
              # update the lockfile
              berks.update
              berks.lockfile.graph.update(berks.install)
              berks.lockfile.update(berks.dependencies)
              berks.lockfile.save
            end
          end
        end
        Kitchen.mutex.synchronize do
          info("Resolving cookbook dependencies with Berkshelf #{::Berkshelf::VERSION}...")
          debug("Using Berksfile from #{berksfile}")

          ::Berkshelf.ui.mute do
            if ::Berkshelf::Berksfile.method_defined?(:vendor)
              # Berkshelf 3.0 requires the directory to not exist
              FileUtils.rm_rf(tmpbooks_dir)
              berks.vendor(tmpbooks_dir)
            else
              berks.install(path => tmpbooks_dir)
            end
          end
        end
      end
    end
  end
end
