module Fingers
end

class String
  def shellescape
    self.gsub('"', '\\"')
  end
end
