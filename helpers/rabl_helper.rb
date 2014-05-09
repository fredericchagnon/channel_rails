module RablHelper
  def node_unless_nil(name, &block)
    node(name, { :if => lambda { |m| m.send(name) } }, &block)
  end
end