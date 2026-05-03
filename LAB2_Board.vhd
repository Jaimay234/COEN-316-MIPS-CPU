library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity regfile is
port( din_in : in std_logic_vector(3 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	write : in std_logic;
	read_a_in : in std_logic_vector(1 downto 0);
	read_b_in : in std_logic_vector(1 downto 0);
	write_address_in : in std_logic_vector(1 downto 0);
	out_a_out : out std_logic_vector(3 downto 0);
	out_b_out : out std_logic_vector(3 downto 0));
end regfile ;

architecture board_behav of regfile is
type register_array is array (31 downto 0) of std_logic_vector(31 downto 0);
signal reg_array : register_array;
begin

process(clk, reset)

begin

if(reset = '1') then
	for x in 31 downto 0 loop
		reg_array(x) <= (others => '0');
	end loop;
elsif(clk'event and clk = '1') then 
	if(write = '1') then
	write_check: case write_address_in is
		when "00" =>
			reg_array(0) <= x"0000000" & din_in;
		when "01" =>
			reg_array(1) <= x"0000000" & din_in;
		when "10" =>
			reg_array(2) <= x"0000000" & din_in;
		when "11" =>
			reg_array(3) <= x"0000000" & din_in;
		when others =>
			reg_array(4) <= x"0000000" & din_in;
		end case;
	end if;
end if;

end process;


process(read_a_in, read_b_in, reg_array)

begin
	read_check1 : case read_a_in is
		when "00" =>
			out_a_out <= reg_array(0)(3 downto 0);
		when "01" =>
			out_a_out <= reg_array(1)(3 downto 0);
		when "10" =>
			out_a_out <= reg_array(2)(3 downto 0);
		when others =>
			out_a_out <= reg_array(3)(3 downto 0);
		end case;
	

	read_check2: case read_b_in is
		when "00" =>
			out_b_out <= reg_array(0)(3 downto 0);
		when "01" =>
			out_b_out <= reg_array(1)(3 downto 0);
		when "10" =>
			out_b_out <= reg_array(2)(3 downto 0);
		when others =>
			out_b_out <= reg_array(3)(3 downto 0);
		end case;

end process;
end board_behav;
			
