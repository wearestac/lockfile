class LockFile
  attr_accessor :path, :filename, :qualified_path

  def initialize(path="/tmp", filename="lockfile.lock")
    @path, @filename = path, filename
  end
  
  def qualified_path
    "#{@path}/#{@filename}"
  end
  
  def process_id
    locked? ? read_lockfile(self.qualified_path) : nil
  end

  def lock!
    locked? ? false : create_lockfile(self.qualified_path)
  end

  def unlock!
    unlocked? ? false : destroy_lockfile(self.qualified_path)
  end

  def locked?
    lockfile_exists?(self.qualified_path)
  end

  def unlocked?
    !lockfile_exists?(self.qualified_path)
  end

  protected
  def lockfile_exists?(file)
    File.exists?(file)
  end

  def create_lockfile(lockfile)
    begin
      File.open(lockfile, "w") { |f| f.write(Process.pid) }
    rescue
      raise LockFileExists
    end
  end

  def read_lockfile(lockfile)
    begin
      File.open(lockfile, "r").gets { |l| puts l }
    rescue
      raise LockFileMissing
    end
  end

  def destroy_lockfile(lockfile)
    begin
      File.delete(lockfile)
    rescue
      raise LockFileMissing
    end
  end

  public
  class LockFileError < StandardError #:nodoc:
  end
  class LockFileExists < LockFileError #:nodoc:
  end  
  class LockFileMissing < LockFileError #:nodoc:
  end  

end
