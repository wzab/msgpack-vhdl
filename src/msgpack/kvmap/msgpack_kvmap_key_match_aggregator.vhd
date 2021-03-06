-----------------------------------------------------------------------------------
--!     @file    msgpack_kvmap_key_match_aggregator.vhd
--!     @brief   MessagePack-KVMap(Key Value Map) Key Match Aggregator Module :
--!     @version 0.2.0
--!     @date    2015/11/9
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
entity  MsgPack_KVMap_Key_Match_Aggregator is
    -------------------------------------------------------------------------------
    -- Generic Parameters
    -------------------------------------------------------------------------------
    generic (
        CODE_WIDTH      : positive := 1;
        MATCH_NUM       : integer  := 1;
        MATCH_PHASE     : integer  := 8
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals
    -------------------------------------------------------------------------------
        CLK             : in  std_logic; 
        RST             : in  std_logic;
        CLR             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Key Object Decode Input Interface
    -------------------------------------------------------------------------------
        I_KEY_VALID     : in  std_logic;
        I_KEY_CODE      : in  MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
        I_KEY_LAST      : in  std_logic := '0';
        I_KEY_SHIFT     : out std_logic_vector(          CODE_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- Key Object Encode Output Interface
    -------------------------------------------------------------------------------
        O_KEY_VALID     : out std_logic;
        O_KEY_CODE      : out MsgPack_Object.Code_Vector(CODE_WIDTH-1 downto 0);
        O_KEY_LAST      : out std_logic;
        O_KEY_READY     : in  std_logic := '1';
    -------------------------------------------------------------------------------
    -- Key Object Compare Interface
    -------------------------------------------------------------------------------
        MATCH_REQ       : out std_logic_vector(         MATCH_PHASE-1 downto 0);
        MATCH_OK        : in  std_logic_vector(MATCH_NUM           -1 downto 0);
        MATCH_NOT       : in  std_logic_vector(MATCH_NUM           -1 downto 0);
        MATCH_SHIFT     : in  std_logic_vector(MATCH_NUM*CODE_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- Aggregated Result Output
    -------------------------------------------------------------------------------
        MATCH_SEL       : out std_logic_vector(MATCH_NUM           -1 downto 0);
        MATCH_STATE     : out MsgPack_Object.Match_State_Type
    );
end MsgPack_KVMap_Key_Match_Aggregator;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library MsgPack;
use     MsgPack.MsgPack_Object;
architecture RTL of MsgPack_KVMap_Key_Match_Aggregator is
    constant  MATCH_ALL_0       :  std_logic_vector(  MATCH_NUM-1 downto 0) := (others => '0');
    constant  MATCH_ALL_1       :  std_logic_vector(  MATCH_NUM-1 downto 0) := (others => '1');
    constant  SHIFT_ALL_0       :  std_logic_vector( CODE_WIDTH-1 downto 0) := (others => '0');
    constant  SHIFT_ALL_1       :  std_logic_vector( CODE_WIDTH-1 downto 0) := (others => '1');
    constant  VALID_ALL_0       :  std_logic_vector( CODE_WIDTH-1 downto 0) := (others => '0');
    signal    curr_req_phase    :  std_logic_vector(MATCH_PHASE-1 downto 0);
    signal    intake_code_valid :  std_logic_vector( CODE_WIDTH-1 downto 0);
    signal    intake_code_last  :  std_logic;
    signal    intake_valid      :  std_logic;
    signal    intake_complete   :  std_logic;
    type      STATE_TYPE        is (RUN_STATE, SKIP_STATE);
    signal    curr_state        :  STATE_TYPE;
    signal    next_state        :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (I_KEY_CODE, I_KEY_LAST)
        variable  i_code_valid    :  std_logic_vector(CODE_WIDTH-1 downto 0);
        variable  i_code_complete :  std_logic_vector(CODE_WIDTH-1 downto 0);
        variable  o_code_valid    :  std_logic_vector(CODE_WIDTH-1 downto 0);
        variable  valid_on        :  boolean;
    begin
        for i in 0 to CODE_WIDTH-1 loop
            i_code_valid   (i) := I_KEY_CODE(i).valid;
            i_code_complete(i) := I_KEY_CODE(i).complete;
        end loop;

        valid_on := TRUE;
        for i in 0 to CODE_WIDTH-1 loop
            if (valid_on) then
                o_code_valid(i) := i_code_valid(i);
                if (i_code_valid(i) = '1' and i_code_complete(i) = '1') then
                    valid_on := FALSE;
                end if;
            else
                o_code_valid(i) := '0';
            end if;
        end loop;

        if (I_KEY_LAST = '1') or
           ((i_code_valid and i_code_complete) /= VALID_ALL_0) then
            intake_complete <= '1';
            intake_valid    <= i_code_valid(intake_code_valid'low );
        else
            intake_complete <= '0';
            intake_valid    <= i_code_valid(intake_code_valid'high);
        end if;
            
        intake_code_valid <= o_code_valid;

        if (I_KEY_LAST = '1') and
           ((i_code_valid and not o_code_valid) = VALID_ALL_0) then
            intake_code_last <= '1';
        else
            intake_code_last <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (curr_state, curr_req_phase,
             I_KEY_VALID, intake_valid, intake_code_valid, intake_code_last, intake_complete,
             MATCH_OK, MATCH_NOT, O_KEY_READY)
    begin
        case curr_state is
            when RUN_STATE => 
                if (I_KEY_VALID = '1') then
                    if    (O_KEY_READY = '0') then
                            MATCH_STATE <= MsgPack_Object.MATCH_BUSY_STATE;
                            I_KEY_SHIFT <= SHIFT_ALL_0;
                            next_state  <= RUN_STATE;
                    elsif (MATCH_OK  /= MATCH_ALL_0) then
                        if (intake_code_last = '1') then
                            MATCH_STATE <= MsgPack_Object.MATCH_DONE_FOUND_LAST_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                        else
                            MATCH_STATE <= MsgPack_Object.MATCH_DONE_FOUND_CONT_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                        end if;
                    elsif ((curr_req_phase(curr_req_phase'high) = '1') and intake_valid = '1') or
                          ((MATCH_NOT /= MATCH_ALL_0) and
                           ((MATCH_OK or MATCH_NOT) = MATCH_ALL_1)) then
                        if    (intake_complete  = '0') then
                            MATCH_STATE <= MsgPack_Object.MATCH_BUSY_NOT_FOUND_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= SKIP_STATE;
                        elsif (intake_code_last = '1') then
                            MATCH_STATE <= MsgPack_Object.MATCH_DONE_NOT_FOUND_LAST_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                        else
                            MATCH_STATE <= MsgPack_Object.MATCH_DONE_NOT_FOUND_CONT_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                        end if;
                    else
                            MATCH_STATE <= MsgPack_Object.MATCH_BUSY_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                    end if;
                else
                            MATCH_STATE <= MsgPack_Object.MATCH_IDLE_STATE;
                            I_KEY_SHIFT <= SHIFT_ALL_0;
                            next_state  <= RUN_STATE;
                end if;
            when SKIP_STATE =>
                if (I_KEY_VALID = '1') then
                    if    (O_KEY_READY = '0') then
                            MATCH_STATE <= MsgPack_Object.MATCH_BUSY_NOT_FOUND_STATE;
                            I_KEY_SHIFT <= SHIFT_ALL_0;
                            next_state  <= SKIP_STATE;
                    elsif (intake_complete = '0') then
                            MATCH_STATE <= MsgPack_Object.MATCH_BUSY_NOT_FOUND_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= SKIP_STATE;
                    elsif (intake_code_last = '1') then
                            MATCH_STATE <= MsgPack_Object.MATCH_DONE_NOT_FOUND_LAST_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                    else
                            MATCH_STATE <= MsgPack_Object.MATCH_DONE_NOT_FOUND_CONT_STATE;
                            I_KEY_SHIFT <= intake_code_valid;
                            next_state  <= RUN_STATE;
                    end if;
                else
                            MATCH_STATE <= MsgPack_Object.MATCH_IDLE_STATE;
                            I_KEY_SHIFT <= SHIFT_ALL_0;
                            next_state  <= RUN_STATE;
                end if;
            when others => 
                            MATCH_STATE <= MsgPack_Object.MATCH_IDLE_STATE;
                            I_KEY_SHIFT <= SHIFT_ALL_0;
                            next_state  <= RUN_STATE;
        end case;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    MATCH_SEL  <= MATCH_OK;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MATCH_REQ  <= curr_req_phase when (I_KEY_VALID = '1') and
                                      (curr_state = RUN_STATE) else (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                curr_req_phase <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') or
               (I_KEY_VALID = '0') then
                curr_req_phase <= (0 => '1', others => '0');
            elsif (curr_state = RUN_STATE and intake_valid = '1' and O_KEY_READY = '1') then
                for i in curr_req_phase'range loop
                    if (i > 0) then
                        curr_req_phase(i) <= curr_req_phase(i-1);
                    else
                        curr_req_phase(i) <= '0';
                    end if;
                end loop;
             end if ;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process(CLK, RST) begin
        if (RST = '1') then
                curr_state <= RUN_STATE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state <= RUN_STATE;
            else
                curr_state <= next_state;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (I_KEY_CODE, intake_code_valid) begin
        for i in O_KEY_CODE'range loop
            O_KEY_CODE(i)       <= I_KEY_CODE(i);
            O_KEY_CODE(i).valid <= intake_code_valid(i);
        end loop;
    end process;
    O_KEY_VALID <= '1' when (intake_valid    = '1' and I_KEY_VALID = '1') else '0';
    O_KEY_LAST  <= '1' when (intake_complete = '1' and I_KEY_VALID = '1') else '0';
end RTL;
