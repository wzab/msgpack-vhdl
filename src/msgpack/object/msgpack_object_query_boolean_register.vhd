-----------------------------------------------------------------------------------
--!     @file    msgpack_object_query_integer_register.vhd
--!     @brief   MessagePack Object Query Boolean Register Module :
--!     @version 0.2.0
--!     @date    2016/6/23
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2016 Ichiro Kawazome
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
entity  MsgPack_Object_Query_Boolean_Register is
    -------------------------------------------------------------------------------
    -- Generic Parameters
    -------------------------------------------------------------------------------
    generic (
        CODE_WIDTH      :  positive := 1
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals
    -------------------------------------------------------------------------------
        CLK             : in  std_logic; 
        RST             : in  std_logic;
        CLR             : in  std_logic;
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
    -- 
    -------------------------------------------------------------------------------
        VALUE           : in  std_logic;
        VALID           : in  std_logic;
        READY           : out std_logic
    );
end  MsgPack_Object_Query_Boolean_Register;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library MsgPack;
use     MsgPack.MsgPack_Object;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Encode_Boolean;
use     MsgPack.MsgPack_Object_Components.MsgPack_Object_Query_Stream_Parameter;
architecture RTL of MsgPack_Object_Query_Boolean_Register is
    signal    start        :  std_logic;
    signal    busy         :  std_logic;
    signal    size         :  std_logic_vector(0 downto 0);
    constant  default_size :  std_logic_vector(0 downto 0) := (others => '1');
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PARAM: MsgPack_Object_Query_Stream_Parameter --
        generic map (                            -- 
            CODE_WIDTH      => CODE_WIDTH      , --
            SIZE_BITS       => 1                 --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            DEFAULT_SIZE    => default_size    , -- In  :
            I_CODE          => I_CODE          , -- In  :
            I_LAST          => I_LAST          , -- In  :
            I_VALID         => I_VALID         , -- In  :
            I_ERROR         => I_ERROR         , -- Out :
            I_DONE          => I_DONE          , -- Out :
            I_SHIFT         => I_SHIFT         , -- Out :
            START           => start           , -- Out :
            SIZE            => size            , -- Out :
            BUSY            => busy              -- In  :
        );                                       -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ENCODE: MsgPack_Object_Encode_Boolean        -- 
        generic map (                            -- 
            CODE_WIDTH      => CODE_WIDTH      , --
            QUEUE_SIZE      => 0                 --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            START           => start           , -- In  :
            BUSY            => busy            , -- Out :
            READY           => open            , -- Out :
            O_CODE          => O_CODE          , -- Out :
            O_LAST          => O_LAST          , -- Out :
            O_ERROR         => O_ERROR         , -- Out :
            O_VALID         => O_VALID         , -- Out :
            O_READY         => O_READY         , -- In  :
            I_VALUE         => VALUE           , -- In  :
            I_VALID         => VALID           , -- In  :
            I_READY         => READY             -- Out :
        );                                       --
end RTL;
