# -*- encoding: utf-8 -*-

require 'kitchen/provisioner/chef_zero'
require 'kitchen/provisioner/sandbox_berks_env'

module Kitchen
  module Provisioner
    # Chef Zero Berkshelf Environment provisioner.
    #
    # @author Mario Santos <mario.rf.santos@gmail.com>
    class ChefZeroBerksEnv < ChefZero
      def create_sandbox
        @sandbox_path = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, sandbox_path)
        info('Preparing files for transfer')
        debug("Creating local sandbox in #{sandbox_path}")
        SandboxBerksEnv.new(config, sandbox_path, instance).populate
        prepare_chef_client_zero_rb
        prepare_validation_pem
        prepare_client_rb
      end
    end
  end
end
