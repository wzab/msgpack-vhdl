module MsgPack_RPC_Interface::VHDL::Memory::Binary
  extend MsgPack_RPC_Interface::VHDL::Util

  def generate_port_list(master, data_type, kvmap, registory)
    addr_type = registory[:addr_type]
    data_type = MsgPack_RPC_Interface::Standard::Type.new(Hash({"name" => "Logic_Vector", "width" => registory[:width]*8}))
    strb_type = MsgPack_RPC_Interface::Standard::Type.new(Hash({"name" => "Logic_Vector", "width" => registory[:width]  }))
    addr_type_name = addr_type.generate_vhdl_type
    data_type_name = data_type.generate_vhdl_type
    strb_type_name = strb_type.generate_vhdl_type
    vhdl_lines = Array.new
    w_out = (master) ? "out" : "in"
    w_in  = (master) ? "in"  : "out"
    r_in  = (master) ? "in"  : "out"
    r_out = (master) ? "out" : "in"
    add_port_line(vhdl_lines, registory, :write_addr , w_out,  "#{addr_type_name}")
    add_port_line(vhdl_lines, registory, :write_data , w_out,  "#{data_type_name}")
    add_port_line(vhdl_lines, registory, :write_strb , w_out,  "#{strb_type_name}")
    add_port_line(vhdl_lines, registory, :write_valid, w_out,  "std_logic"        )
    add_port_line(vhdl_lines, registory, :read_addr  , w_out,  "#{addr_type_name}")
    add_port_line(vhdl_lines, registory, :read_data  , r_in ,  "#{data_type_name}")
    return vhdl_lines
  end

  module_function :generate_port_list

  require_relative 'binary/store'
  require_relative 'binary/query'

end