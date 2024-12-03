-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all

entity UartTx is
generic(
    g_n_ClockRate   : natural := 9600;
    g_n_BaudRate    : natural := 9600;
    g_s_Parity      : string  := "none";
    g_n_StopLen     : natural := 1
);
port(
    i_sl_Clock      : in std_logic;
    i_sl_Reset      : in std_logic;
    i_sl_Transmit   : in std_logic;
    i_slv_Data      : in std_logic_vector(7 downto 0);
    o_sl_Tx         : out std_logic
);
end UartTx;

architecture behave of UartTx is
	-- type declaration
	type state is (IDLE, START,DATA,PARITY,STOP);
    -- Constant Declaration
    c_u_BaudPeriod : unsigned :=  to_unsigned(natural(ceil(g_n_ClockRate/g_n_BaudRate),32));
	-- Signal Declaration
    signal s_u_BaudCounter : unsigned;
    signal s_sl_BaudTick : std_logic;
	signal s_t_State : state;
    signal s_sl_Transmit : std_logic;
    signal s_slv_Data : std_logic_vector(7 downto 0);
    signal s_sl_Tx : std_logic;
    signal s_u_TxCnt : unsigned;
begin
  	-- To do: create a Baudrate counter
  	proc_BaudCntr: process(i_sl_Clock, i_sl_Reset)
    begin
    	if i_sl_Reset = '0' then
            s_u_BaudCounter <= (others <= '0');
            s_sl_BaudTick <= '0';
		elsif rising_edge(i_sl_Clock) then
            if s_u_BaudCounter < c_u_BaudPeriod then
                s_u_BaudCounter <= s_u_BaudCounter + 1;
                s_sl_BaudTick <= '0';
            else
                s_u_BaudCounter <= (others <= '0');
                s_sl_BaudTick <= '1';
            end if;
        end if;
    end process proc_BaudCntr;
    
	proc_Transmit:process(i_sl_Clock, i_sl_Reset)
    begin
    	if i_sl_Reset = '0' then
        	s_sl_Transmit <= '0';
            s_sl_Tx <= '1';
            s_u_TxCnt <= (others => '0');
            i_slv_Data
        elsif rising_edge(i_sl_Clock) then
        	s_sl_Transmit <= i_sl_Transmit;
            case s_t_State is
            When IDLE =>
            	if 	s_sl_Transmit = '1' and 
                	s_sl_Transmit /= i_sl_Transmit then
           			s_t_State <= START;
                	s_slv_Data <= i_slv_Data;
                end if;
            When START =>
        		s_sl_Tx <= '0';
                s_t_State <= DATA;
            	s_u_TxCnt <= (others => '0');

            When DATA =>
            	if s_u_TxCnt < 7 then
                	s_sl_Tx <= s_slv_Data(0);
                	s_slv_Data <= '0' & s_slv_Data(6 downto 0);
                    s_u_TxCnt <= s_u_TxCnt + 1;
            	elsif s_u_TxCnt = 7 then
                	s_sl_Tx <= s_slv_Data(0);
                    s_u_TxCnt <= s_u_TxCnt + 1;
                    s_t_State <= PARITY;
            When PARITY =>
        		s_sl_Tx <= '0';
            When others =>
        		s_sl_Tx <= '1';
                s_t_State <= IDLE
         	end case;
        
        end if;
	end process proc_Transmit;

end behave;