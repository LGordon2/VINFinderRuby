require 'thread/pool'
class Thread::Pool
  def wait_until_finished
    until self.wait_done.nil?
      self.wait_done
    end
  end
end
