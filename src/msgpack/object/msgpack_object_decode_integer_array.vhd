-----------------------------------------------------------------------------------
--!     @file    msgpack_object_decode_integer_array.vhd
--!     @brief   MessagePack Object decode to integer array
--!     @version 0.1.0
--!     @date    2015/10/19
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2015 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library MsgPack;
use     MsgPack.MsgPack_Object;
entity  MsgPack_Object_Decode_Integer_Array is
    -------------------------------------------------------------------------------
    -- Generic Parameters
    -------------------------------------------------------------------------------
    generic (
        CODE_WIDTH      :  positive := 1;
        ARRAY_DEPTH     :  integer  := 8;
        VALUE_WIDTH     :  integer range 1 to 64;
        VALUE_SIGN      :  boolean  := FALSE;
        CHECK_RANGE     :  boolean  := TRUE ;
        ENABLE64        :  boolean  := TRUE
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals
    -------------------------------------------------------------------------------
        CLK             : in  std_logic; 
        RST             : in  std_logic;
        CLR             : in  std_logic;
    -------------------------------------------------------------------------------
    -- MessagePack Object Code Input Interface
    -------------------------------------------------------------------------------
        I_CODE          : in  MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
        I_LAST          : in  std_logic;
        I_VALID         : in  std_logic;
        I_ERROR         : out std_logic;
        I_DONE          : out std_logic;
        I_SHIFT         : out std_logic_vector(CODE_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- Integer Value Data and Address Output
    -------------------------------------------------------------------------------
        VALUE           : out std_logic_vector(VALUE_WIDTH-1 downto 0);
        SIGN            : out std_logic;
        ADDR            : out std_logic_vector(ARRAY_DEPTH-1 downto 0);
        WE              : out std_logic
    );
end  MsgPack_Object_Decode_Integer_Array;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library MsgPack;
use     MsgPack.MsgPack_Object;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Decode_Array;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Decode_Integer;
architecture RTL of MsgPack_Object_Decode_Integer_Array is
    signal    value_valid       :  std_logic;
    signal    value_error       :  std_logic;
    signal    value_done        :  std_logic;
    signal    value_shift       :  std_logic_vector(CODE_WIDTH -1 downto 0);
    signal    value_din         :  std_logic_vector(VALUE_WIDTH-1 downto 0);
    signal    value_set         :  std_logic;
    signal    array_addr        :  std_logic_vector(ARRAY_WIDTH-1 downto 0);
    signal    array_we          :  std_logic;
    signal    array_start       :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DECODE_ARRAY:  MsgPack_Object_Decode_Array       -- 
        generic map (                                -- 
            CODE_WIDTH      => CODE_WIDTH            --
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            I_CODE          => I_CODE              , -- In  :
            I_LAST          => I_LAST              , -- In  :
            I_VALID         => I_VALID             , -- In  :
            I_ERROR         => I_ERROR             , -- Out :
            I_DONE          => I_DONE              , -- Out :
            I_SHIFT         => I_SHIFT             , -- Out :
            ARRAY_START     => array_start         , -- Out :
            ARRAY_SIZE      => open                , -- Out :
            VALUE_START     => open                , -- Out :
            VALUE_VALID     => value_valid         , -- Out :
            VALUE_ERROR     => value_error         , -- In  :
            VALUE_DONE      => value_done          , -- In  :
            VALUE_SHIFT     => value_shift           -- In  :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DECODE_VALUE: MsgPack_Object_Decode_Integer      -- 
        generic map (                                -- 
            CODE_WIDTH      => CODE_WIDTH          , --
            VALUE_WIDTH     => VALUE_WIDTH         , --
            VALUE_SIGN      => VALUE_SIGN          , --
            CHECK_RANGE     => CHECK_RANGE         , --
            ENABLE64        => ENABLE64              --
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- : In  :
            RST             => RST                 , -- : In  :
            CLR             => CLR                 , -- : In  :
            I_CODE          => I_CODE              , -- : In  :
            I_LAST          => I_LAST              , -- : In  :
            I_VALID         => value_valid         , -- : In  :
            I_ERROR         => value_error         , -- : Out :
            I_DONE          => value_done          , -- : Out :
            I_SHIFT         => value_shift         , -- : Out :
            VALUE           => value_din           , -- : Out :
            WE              => value_set             -- : Out :
        );                                           --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                VALUE      <= (others => '0');
                array_addr <= (others => '0');
                array_we   <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                VALUE      <= (others => '0');
                array_addr <= (others => '0');
                array_we   <= '0';
            else
                if (value_set = '1') then
                    VALUE <= value_din;
                end if;
                array_we <= value_set;
                if    (array_start = '1') then
                    array_addr <= (others => '0');
                elsif (array_we    = '1') then
                    array_addr <= std_logic_vector(unsigned(array_addr) + 1);
                end if;
            end if;
        end if;
    end process;
    WE   <= array_we;
    ADDR <= array_addr;
end RTL;
