# -*- coding: utf-8 -*-

require 'kitchen/provisioner/chef_zero'
require 'git'

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
          unless config[:environments_repo].nil?
            config[:environments_path] = environments_path_from_git(config[:environments_repo])
          end
          info("Loading chef environment '#{chef_environment}'...")
          lock_berksfile(berks, cookbook_versions("#{config[:environments_path]}/#{chef_environment}.json"))
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

      # Fetches a git repo to a temporary directory
      #
      # @param args [String] git repo
      # @return [String] the environments_path directory
      # @api private
      def environments_path_from_git(repo)
        info("Fetching chef environments from repo '#{repo}'...")
        tmpenv_dir = Dir.mktmpdir('environments-')
        Git.clone(repo, 'chef_env', path: tmpenv_dir, depth: 1)
        "#{tmpenv_dir}/chef_env"
      end

      # Gets the cookbook version restrictions from a chef environment
      #
      # @param [String] chef environment path
      # @return [Hash] cookbook versions
      # @api private
      def cookbook_versions(json_path)
        info("Using environment from '#{json_path}'")
        JSON.parse(File.read("#{json_path}"))['cookbook_versions']
      end

      # Locks the cookbook versions into Berksfile.lock
      #
      # @param [Berksfile] berksfile to lock
      # @param [Hash] cookbook versions
      # @api private
      def lock_berksfile(berksfile, cookbook_versions)
        ::Berkshelf.ui.mute do
          info("Resolving dependency graph with Berkshelf #{::Berkshelf::VERSION}...")
          berksfile.install
          unless cookbook_versions.nil?
            berksfile.lockfile.graph.each do |graphitem|
              version = cookbook_versions[graphitem.name]
              unless version.nil? || berksfile.has_dependency?(graphitem.name)
                info("Adding Berkshelf dependency: #{graphitem.name} (#{version})")
                berksfile.add_dependency(graphitem.name, version)
              end
            end
            # update the lockfile
            berksfile.update
            berksfile.lockfile.graph.update(berksfile.install)
            berksfile.lockfile.update(berksfile.dependencies)
            berksfile.lockfile.save
          end
        end
      end
    end
  end
end
