module RubyLibrary
  def log(message)
    if STDOUT.tty?
      puts "\e[1m# #{message}\e[0m"
    else
      puts "# #{message}"
    end
  end

  def sh(command, *args)
    log "#{command} #{args.join(' ')}"
    if !system(command, *args)
      abort "*** Command failed with code #{$? ? $?.exitstatus : 'unknown'}"
    end
  end

  # Create a directory tree with the right permissions. Every directory
  # must be sticky and group-writable, so that the psg_autobuilder_run
  # user can create signatures.
  def make_output_subdir(dir)
    infer_nonexistant_subdirs(dir).each do |subdir|
      log "mkdir #{subdir}"
      Dir.mkdir(subdir, 0775)
      if !File.setgid?(subdir)
        sh "chmod", "g+s", subdir
      end
    end
  end

  def infer_nonexistant_subdirs(dirname)
    dirs = []
    while dirname != "/" && !File.exist?(dirname)
      dirs << dirname
      dirname = File.dirname(dirname)
    end
    dirs.reverse!
    dirs
  end
end
