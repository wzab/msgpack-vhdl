module MsgPack_RPC_Interface::VHDL::Memory::Binary::Store
  extend MsgPack_RPC_Interface::VHDL::Util

  def generate_decl(indent, name, type, kvmap, registory)
    return []
  end

  def generate_stmt(indent, name, type, kvmap, registory)
    class_name    = self.name.to_s.split("::")[-2]
    addr_type     = registory[:addr_type]
    decode_binary = (class_name == "Binary") ? "TRUE" : "FALSE"
    decode_string = (class_name == "String") ? "TRUE" : "FALSE"
    instance_name = registory.fetch(:instance_name, "PROC_STORE_" + name.upcase)
    write_data    = registory[:write_data]
    write_addr    = registory[:write_addr]
    write_start   = registory.fetch(:write_start  , "open")
    write_busy    = registory.fetch(:write_busy   , "open")
    write_sign    = registory.fetch(:write_sign   , "open")
    write_last    = registory.fetch(:write_last   , "open")
    write_strb    = registory.fetch(:write_strb   , "open")
    write_valid   = registory.fetch(:write_valid  , "open")
    write_ready   = registory.fetch(:write_ready  , "'1'" )
    addr_bits     = addr_type.width
    data_bits     = registory[:width]*8
    if kvmap == true then
      key_string = "STRING'(\"" + name + "\")"
      vhdl_lines = string_to_lines(
        indent, <<"        EOT"
          #{instance_name} : MsgPack_KVMap_Store_Binary_Array   -- 
              generic map (              #{sprintf("%-28s", ""                     )}   -- 
                  KEY                 => #{sprintf("%-28s", key_string             )} , --
                  MATCH_PHASE         => #{sprintf("%-28s", registory[:match_phase])} , --
                  CODE_WIDTH          => #{sprintf("%-28s", registory[:code_width ])} , --
                  ADDR_BITS           => #{sprintf("%-28s", addr_bits              )} , --
                  DATA_BITS           => #{sprintf("%-28s", data_bits              )} , --
                  DECODE_BINARY       => #{sprintf("%-28s", decode_binary          )} , --
                  DECODE_STRING       => #{sprintf("%-28s", decode_string          )}   --
              )                          #{sprintf("%-28s", ""                     )}   -- 
              port map (                 #{sprintf("%-28s", ""                     )}   -- 
                  CLK                 => #{sprintf("%-28s", registory[:clock      ])} , -- In  :
                  RST                 => #{sprintf("%-28s", registory[:reset      ])} , -- in  :
                  CLR                 => #{sprintf("%-28s", registory[:clear      ])} , -- in  :
                  I_CODE              => #{sprintf("%-28s", registory[:param_code ])} , -- In  :
                  I_LAST              => #{sprintf("%-28s", registory[:param_last ])} , -- In  :
                  I_VALID             => #{sprintf("%-28s", registory[:param_valid])} , -- In  :
                  I_ERROR             => #{sprintf("%-28s", registory[:param_error])} , -- Out :
                  I_DONE              => #{sprintf("%-28s", registory[:param_done ])} , -- Out :
                  I_SHIFT             => #{sprintf("%-28s", registory[:param_shift])} , -- Out :
                  MATCH_REQ           => #{sprintf("%-28s", registory[:match_req  ])} , -- In  :
                  MATCH_CODE          => #{sprintf("%-28s", registory[:match_code ])} , -- In  :
                  MATCH_OK            => #{sprintf("%-28s", registory[:match_ok   ])} , -- Out :
                  MATCH_NOT           => #{sprintf("%-28s", registory[:match_not  ])} , -- Out :
                  MATCH_SHIFT         => #{sprintf("%-28s", registory[:match_shift])} , -- Out :
                  START               => #{sprintf("%-28s", write_start            )} , -- Out :
                  BUSY                => #{sprintf("%-28s", write_busy             )} , -- Out :
                  ADDR                => #{sprintf("%-28s", write_addr             )} , -- Out :
                  DATA                => #{sprintf("%-28s", write_data             )} , -- Out :
                  STRB                => #{sprintf("%-28s", write_strb             )} , -- Out :
                  LAST                => #{sprintf("%-28s", write_last             )} , -- Out :
                  VALID               => #{sprintf("%-28s", write_valid            )} , -- Out :
                  READY               => #{sprintf("%-28s", write_ready            )}   -- In  :
              );                         #{sprintf("%-28s", ""                     )}   -- 
        EOT
      )
    else
      vhdl_lines    = string_to_lines(
        indent, <<"        EOT"
          #{instance_name} : MsgPack_Object_Store_Binary_Array   -- 
              generic map (              #{sprintf("%-28s", ""                     )}   -- 
                  CODE_WIDTH          => #{sprintf("%-28s", registory[:code_width ])} , --
                  ADDR_BITS           => #{sprintf("%-28s", addr_bits              )} , --
                  DATA_BITS           => #{sprintf("%-28s", data_bits              )} , --
                  DECODE_BINARY       => #{sprintf("%-28s", decode_binary          )} , --
                  DECODE_STRING       => #{sprintf("%-28s", decode_string          )}   --
              )                          #{sprintf("%-28s", ""                     )}   -- 
              port map (                 #{sprintf("%-28s", ""                     )}   -- 
                  CLK                 => #{sprintf("%-28s", registory[:clock      ])} , -- In  :
                  RST                 => #{sprintf("%-28s", registory[:reset      ])} , -- in  :
                  CLR                 => #{sprintf("%-28s", registory[:clear      ])} , -- in  :
                  I_CODE              => #{sprintf("%-28s", registory[:param_code ])} , -- In  :
                  I_LAST              => #{sprintf("%-28s", registory[:param_last ])} , -- In  :
                  I_VALID             => #{sprintf("%-28s", registory[:param_valid])} , -- In  :
                  I_ERROR             => #{sprintf("%-28s", registory[:param_error])} , -- Out :
                  I_DONE              => #{sprintf("%-28s", registory[:param_done ])} , -- Out :
                  I_SHIFT             => #{sprintf("%-28s", registory[:param_shift])} , -- Out :
                  START               => #{sprintf("%-28s", write_start            )} , -- Out :
                  START               => #{sprintf("%-28s", write_start            )} , -- Out :
                  BUSY                => #{sprintf("%-28s", write_busy             )} , -- Out :
                  ADDR                => #{sprintf("%-28s", write_addr             )} , -- Out :
                  DATA                => #{sprintf("%-28s", write_data             )} , -- Out :
                  STRB                => #{sprintf("%-28s", write_strb             )} , -- Out :
                  LAST                => #{sprintf("%-28s", write_last             )} , -- Out :
                  VALID               => #{sprintf("%-28s", write_valid            )} , -- Out :
                  READY               => #{sprintf("%-28s", write_ready            )}   -- In  :
        EOT
      )
    end
    return vhdl_lines
  end
  
  def generate_body(indent, name, type, kvmap, registory)
    return generate_stmt(indent, name, type, kvmap, registory)
  end
  
  def use_package_list(kvmap)
    if kvmap == true then
      return ["MsgPack.MsgPack_KVMap_Components.MsgPack_KVMap_Store_Binary_Array"]
    else
      return ["MsgPack.MsgPack_Object_Components.MsgPack_Object_Store_Binary_Array"]
    end
  end

  module_function :generate_body
  module_function :generate_decl
  module_function :generate_stmt
  module_function :use_package_list
end