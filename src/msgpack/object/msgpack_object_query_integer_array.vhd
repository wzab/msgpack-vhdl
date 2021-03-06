-----------------------------------------------------------------------------------
--!     @file    msgpack_object_query_integer_array.vhd
--!     @brief   MessagePack Object Queary Integer Array Module :
--!     @version 0.2.0
--!     @date    2016/6/23
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2015-2016 Ichiro Kawazome
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
entity  MsgPack_Object_Query_Integer_Array is
    -------------------------------------------------------------------------------
    -- Generic Parameters
    -------------------------------------------------------------------------------
    generic (
        CODE_WIDTH      :  positive := 1;
        ADDR_BITS       :  positive := 32;
        SIZE_BITS       :  integer range 1 to 32 := 32;
        VALUE_BITS      :  integer range 1 to 64 := 32;
        VALUE_SIGN      :  boolean  := FALSE
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals
    -------------------------------------------------------------------------------
        CLK             : in  std_logic; 
        RST             : in  std_logic;
        CLR             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Default(when parameter == nil) Query Size 
    -------------------------------------------------------------------------------
        DEFAULT_SIZE    : in  std_logic_vector( SIZE_BITS-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- Object Code Input Interface
    -------------------------------------------------------------------------------
        I_CODE          : in  MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
        I_LAST          : in  std_logic;
        I_VALID         : in  std_logic;
        I_ERROR         : out std_logic;
        I_DONE          : out std_logic;
        I_SHIFT         : out std_logic_vector(CODE_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- Object Code Output Interface
    -------------------------------------------------------------------------------
        O_CODE          : out MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
        O_LAST          : out std_logic;
        O_ERROR         : out std_logic;
        O_VALID         : out std_logic;
        O_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- Integer Value Input Interface
    -------------------------------------------------------------------------------
        START           : out std_logic;
        BUSY            : out std_logic;
        SIZE            : out std_logic_vector( SIZE_BITS-1 downto 0);
        ADDR            : out std_logic_vector( ADDR_BITS-1 downto 0);
        VALUE           : in  std_logic_vector(VALUE_BITS-1 downto 0);
        VALID           : in  std_logic;
        READY           : out std_logic
    );
end  MsgPack_Object_Query_Integer_Array;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library MsgPack;
use     MsgPack.MsgPack_Object;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Encode_Integer_Array;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Query_Array;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Query_Stream_Parameter;
architecture RTL of MsgPack_Object_Query_Integer_Array is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    param_code    :  MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
    signal    param_valid   :  std_logic;
    signal    param_last    :  std_logic;
    signal    param_error   :  std_logic;
    signal    param_done    :  std_logic;
    signal    param_shift   :  std_logic_vector          (CODE_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    value_code    :  MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
    signal    value_valid   :  std_logic;
    signal    value_last    :  std_logic;
    signal    value_error   :  std_logic;
    signal    value_ready   :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    encode_addr   :  std_logic_vector          ( ADDR_BITS-1 downto 0);
    signal    encode_start  :  std_logic;
    signal    encode_enable :  std_logic;
    signal    encode_size   :  std_logic_vector          ( SIZE_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    QUERY_ARRAY: MsgPack_Object_Query_Array      -- 
        generic map (                            -- 
            CODE_WIDTH      => CODE_WIDTH      , --
            ADDR_BITS       => ADDR_BITS         --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            I_CODE          => I_CODE          , -- In  :
            I_LAST          => I_LAST          , -- In  :
            I_VALID         => I_VALID         , -- In  :
            I_ERROR         => I_ERROR         , -- Out :
            I_DONE          => I_DONE          , -- Out :
            I_SHIFT         => I_SHIFT         , -- Out :
            O_CODE          => O_CODE          , -- Out :
            O_VALID         => O_VALID         , -- Out :
            O_LAST          => O_LAST          , -- Out :
            O_ERROR         => O_ERROR         , -- Out :
            O_READY         => O_READY         , -- In  :
            PARAM_START     => open            , -- Out :
            PARAM_ADDR      => encode_addr     , -- Out :
            PARAM_VALID     => param_valid     , -- Out :
            PARAM_CODE      => param_code      , -- Out :
            PARAM_LAST      => param_last      , -- Out :
            PARAM_ERROR     => param_error     , -- In  :
            PARAM_DONE      => param_done      , -- In  :
            PARAM_SHIFT     => param_shift     , -- In  :
            VALUE_VALID     => value_valid     , -- In  :
            VALUE_CODE      => value_code      , -- In  :
            VALUE_LAST      => value_last      , -- In  :
            VALUE_ERROR     => value_error     , -- In  :
            VALUE_READY     => value_ready       -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PARAM: MsgPack_Object_Query_Stream_Parameter --
        generic map (                            -- 
            CODE_WIDTH      => CODE_WIDTH      , --
            SIZE_BITS       => SIZE_BITS         --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            DEFAULT_SIZE    => DEFAULT_SIZE    , -- In  :
            I_CODE          => param_code      , -- In  :
            I_LAST          => param_last      , -- In  :
            I_VALID         => param_valid     , -- In  :
            I_ERROR         => param_error     , -- Out :
            I_DONE          => param_done      , -- Out :
            I_SHIFT         => param_shift     , -- Out :
            ENABLE          => encode_enable   , -- In  :
            START           => encode_start    , -- Out :
            SIZE            => encode_size       -- Out :
        );                                       -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ENCODE: MsgPack_Object_Encode_Integer_Array  -- 
        generic map (                            -- 
            CODE_WIDTH      => CODE_WIDTH      , --
            ADDR_BITS       => ADDR_BITS       , --
            SIZE_BITS       => SIZE_BITS       , --
            VALUE_BITS      => VALUE_BITS      , --
            VALUE_SIGN      => VALUE_SIGN      , --
            QUEUE_SIZE      => 0                 -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            START           => encode_start    , -- In  :
            ADDR            => encode_addr     , -- In  :
            SIZE            => encode_size     , -- In  :
            BUSY            => open            , -- Out :
            READY           => encode_enable   , -- Out :
            O_CODE          => value_code      , -- Out :
            O_LAST          => value_last      , -- Out :
            O_ERROR         => value_error     , -- Out :
            O_VALID         => value_valid     , -- Out :
            O_READY         => value_ready     , -- In  :
            I_START         => START           , -- Out :
            I_BUSY          => BUSY            , -- Out :
            I_SIZE          => SIZE            , -- Out :
            I_ADDR          => ADDR            , -- Out :
            I_VALUE         => VALUE           , -- In  :
            I_VALID         => VALID           , -- In  :
            I_READY         => READY             -- Out :
        );                                       --
end RTL;
