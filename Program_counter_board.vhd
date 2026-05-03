library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
entity next_address_board is
port(rt_in, rs_in : in std_logic_vector(1 downto 0);
	pc_in : in std_logic_vector(2 downto 0);
	target_address_in : in std_logic_vector(2 downto 0);
	branch_type : in std_logic_vector(1 downto 0);
	pc_sel : in std_logic_vector(1 downto 0);
	next_pc_out : out std_logic_vector(2 downto 0));
end next_address_board;

architecture proximo of next_address_board is
signal temp_out : std_logic_vector(2 downto 0);
begin

next_pc_out <= temp_out when pc_sel = "00" else
target_address_in when pc_sel = "01" else
('0' & rs_in) when pc_sel = "10";
process(rt_in, rs_in, pc_in, target_address_in, branch_type, pc_sel)
variable mux_out :std_logic_vector(2 downto 0);
begin
	case branch_type is
	when "00" =>
	mux_out := pc_in +1;
	when "01" =>
	if(rt_in = rs_in) then
		mux_out := pc_in + target_address_in + '1';
	else
		mux_out := pc_in +'1';
	end if;

	when "10" =>
	if (rt_in /= rs_in) then
		mux_out := pc_in + target_address_in + '1';
	else
		mux_out := pc_in + '1';
	end if;

	when others =>
	if (rs_in(1) = '1') then
		mux_out := pc_in + target_address_in + '1';
	else
		mux_out := pc_in + '1';
	end if;
	end case;
temp_out <= mux_out;
end process;


end proximo;