library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
entity alu is
port(x_in, y_in : in std_logic_vector(3 downto 0);
	--two input operands
	add_sub    : in std_logic; -- 0 = add , 1 = sub
	logic_func : in std_logic_vector(1 downto 0);
	-- 00 = AND, 01 = OR, 10 = XOR, 11 = NOR
	func       : in std_logic_vector(1 downto 0);
	-- 00 = lui, 01 = setless, 10 = arith, 11 = logic
	output_out     : out std_logic_vector(3 downto 0);
	overflow   : out std_logic;
	zero       : out std_logic);
end alu;


architecture behaviour of alu is
signal x,y,output,arith_out, logic_out : std_logic_vector(31 downto 0);
signal msb: std_logic;
begin

-- signal declarations here
x(3 downto 0) <= x_in(3) & x_in(2) & x_in(1) & x_in(0); -- why not downto?
y(3 downto 0) <= y_in(3) & y_in(2) & y_in(1) & y_in(0);
y(31 downto 4) <= (others => y_in(3));
x(31 downto 4) <= (others => x_in(3));
msb <= arith_out(3);
output_out <= output(3 downto 0);



process(func, arith_out, logic_out, y) is --setting it up as a true multiplexer so results don't vary on inputs
begin
	case func is
		when "00" =>
			output <= y;
		when "01" =>
			output <= (31 downto 1 => '0') & arith_out(3);
		when "10" =>
			output <= arith_out;
		when others =>
			output <= logic_out;
		end case;
end process;


process(add_sub,x,y) is --arithmetic block
variable temp_result: std_logic_vector(31 downto 0);
variable temp_msb: std_logic;
variable zeroes: std_logic_vector(31 downto 0);
begin
	zeroes := (others => '0');
	if add_sub = '0' then
		temp_result := x+y;
		temp_msb :=temp_result(3);
		overflow <= ( temp_msb and (not x(3)) and (not y(3))) or (not temp_msb and x(3) and y(3));
	else
		temp_result := x-y;
		temp_msb :=temp_result(3);
		overflow <= (temp_msb and (not x(3)) and y(3)) or (not temp_msb and x(3) and not y(3));
	end if;
	if temp_result = zeroes then
		zero <= '1';
	else
		zero <= '0';
	end if;
arith_out <= temp_result;
end process;

process(logic_func,x,y) is
begin
	case logic_func is
		when "00" =>
			logic_out <= x and y;
		when "01" =>
			logic_out <= x OR y;
		when "10" =>
			logic_out <= x XOR y;
		when others => --others to avoid latch
			logic_out <= x nor y; 
	end case;
end process;
end behaviour;
