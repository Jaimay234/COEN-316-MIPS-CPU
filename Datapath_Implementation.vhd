library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity Datapath is
    port (
        reset          : in  std_logic;
        clk            : in  std_logic;
        -- Control Signals
        pc_sel         : in  std_logic_vector(1 downto 0); --pc_selection
        branch_type    : in  std_logic_vector(1 downto 0); --branch type
        reg_dst        : in  std_logic; --rt (0) or rd(1)
        alu_src        : in  std_logic; --alu input 2 source
        add_sub        : in  std_logic; --alu add or sub
        logic_func     : in  std_logic_vector(1 downto 0); --AND OR XOR NOR
        data_write     : in  std_logic; --write into data cache or not
	data_write_reg : in std_logic; --write into register
        reg_in_src     : in  std_logic; --ALU or D cache
        ext_func    : in  std_logic_vector(1 downto 0); --extender function 
        -- Outputs
        overflow       : out std_logic;
        zero           : out std_logic;
	datapath       : out std_logic_vector(5 downto 0);
	arithfunc      : out std_logic_vector(5 downto 0);
	pc_out         : out std_logic_vector(3 downto 0);
	rs_out         : out std_logic_vector(3 downto 0);
	rt_out         : out std_logic_vector(3 downto 0);
	branch_cond    : out std_logic_vector(7 downto 0)
    );
end Datapath;

architecture path of Datapath is --declare these all as say 4 bits and then use them on the thing
	-- Internal signals
signal pc_current   : std_logic_vector(31 downto 0) := (others => '0');
signal next_pc      : std_logic_vector(31 downto 0) := (others => '0');
signal out_a   : std_logic_vector(31 downto 0):= (others => '0');
signal out_b   : std_logic_vector(31 downto 0) := (others => '0');
signal imm_ext : std_logic_vector(31 downto 0) := (others => '0');
signal alu_out   : std_logic_vector(31 downto 0) := (others => '0');
signal write_reg    : std_logic_vector(4 downto 0) := (others => '0');
signal D_cache_out : std_logic_vector(31 downto 0) := (others => '0');
signal reg_din : std_logic_vector(31 downto 0) := (others => '0');
signal alu_in_2: std_logic_vector(31 downto 0) := (others => '0');
signal IC_out : std_logic_vector(31 downto 0) := (others => '0');
signal look_ahead: std_logic_vector(31 downto 0) := (others => '0');
type reg is array(31 downto 0) of std_logic_vector(31 downto 0);
signal Data_cache: reg;
signal Instr_cache: reg;


	-- Component declarations

component next_address_board
        port(
	rt_in, rs_in : in std_logic_vector(1 downto 0);
	pc_in : in std_logic_vector(2 downto 0);
	target_address_in : in std_logic_vector(2 downto 0);
	branch_type : in std_logic_vector(1 downto 0);
	pc_sel : in std_logic_vector(1 downto 0);
	next_pc_out : out std_logic_vector(2 downto 0)
        );
end component;

component alu
	port(
		x_in, y_in : in std_logic_vector(3 downto 0);
		--two input operands
		add_sub    : in std_logic; -- 0 = add , 1 = sub
		logic_func : in std_logic_vector(1 downto 0);
		-- 00 = AND, 01 = OR, 10 = XOR, 11 = NOR
		func       : in std_logic_vector(1 downto 0);
		-- 00 = lui, 01 = setless, 10 = arith, 11 = logic
		output_out    : out std_logic_vector(3 downto 0);
		overflow   : out std_logic;
		zero       : out std_logic
	);
end component;

component regfile
	port(
	din_in : in std_logic_vector(3 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	write : in std_logic;
	read_a_in : in std_logic_vector(1 downto 0);
	read_b_in : in std_logic_vector(1 downto 0);
	write_address_in : in std_logic_vector(1 downto 0);
	out_a_out : out std_logic_vector(3 downto 0);
	out_b_out : out std_logic_vector(3 downto 0)
	); --done
end component;



begin

-- Component instantiation

Reg_Component: regfile port map (
	din_in => reg_din(3 downto 0),
	reset => reset,
	clk => clk,
	write => data_write_reg,
	read_a_in => IC_out(22 downto 21),
	read_b_in => IC_out(17 downto 16),
	write_address_in => write_reg(1 downto 0),
	out_a_out => out_a(3 downto 0),
	out_b_out => out_b(3 downto 0)
);


ALU_Component: alu port map(
	x_in => out_a(3 downto 0),
	y_in => alu_in_2(3 downto 0),
	add_sub =>add_sub,
	logic_func =>logic_func,
	func => ext_func,
	output_out => alu_out(3 downto 0),
	overflow => overflow,
	zero => zero
);

PC_Component: next_address_board port map(
	rs_in => out_a(1 downto 0),
	rt_in => out_b(1 downto 0),
	target_address_in => IC_out(2 downto 0),
	pc_in => pc_current(2 downto 0),
	branch_type => branch_type,
	pc_sel =>pc_sel,
	next_pc_out => next_pc(2 downto 0)
);

-- Processes
sign_extend: process(IC_out,ext_func) --done
begin
	case ext_func is
	when "00" =>
	imm_ext <= IC_out(15 downto 0) & x"0000";
	when "01" =>
	imm_ext <=  (31 downto 16 => IC_out(15)) & IC_out(15 downto 0);
	when "10" =>
	imm_ext <=  (31 downto 16 => IC_out(15)) & IC_out(15 downto 0);
	when others =>
	imm_ext <= x"0000" & IC_out(15 downto 0);
end case;
end process;

D_cache: process(clk,reset) --done
variable temp_out: std_logic_vector(4 downto 0);
begin
temp_out := alu_out(4 downto 0);
if(reset = '1') then
		reset_loop: for x in 31 downto 0 loop
		Data_cache(x)<=(others => '0');
		end loop;
elsif(clk = '1' and clk'event) then
	if(data_write = '1') then
		Data_cache(conv_integer(temp_out)) <= out_b;
	end if;
end if;
D_cache_out <= Data_cache(conv_integer(temp_out));
end process;

register_in: process(reg_in_src, alu_out, D_cache_out)

begin
	if(reg_in_src = '1') then
	reg_din <= alu_out;
	else
	reg_din <= D_cache_out;
end if;
end process;


alu_input_2: process(alu_src, out_b, imm_ext)

begin
	if(alu_src = '0')then
	alu_in_2 <= out_b;
	else
	alu_in_2 <= imm_ext;
end if;
end process;


I_cache: process(pc_current,reset,clk)
variable address: std_logic_vector(4 downto 0);
begin
	--Initialize the cache
	if(reset = '1') then
		Instr_cache(0)<= "00100000000000010000000000000001";
	        Instr_cache(1)<= "00100000000000100000000000000010";
	        Instr_cache(2)<= "00000000010000010001000000100000";
	        Instr_cache(3)<= "00001000000000000000000000000010";

	for x in 31 downto 4 loop
		Instr_cache(x)<= x"00000000";

	end loop;
	else
	address := pc_current(4 downto 0);
	look_ahead <=Instr_cache(conv_integer(address));
	IC_out <= Instr_cache(conv_integer(pc_current(4 downto 0)));
	end if;
end process;

reg_address: process(IC_out, reg_dst)
begin
	if(reg_dst = '0') then
		write_reg <= IC_out (20 downto 16);
	else
		write_reg <= IC_out (15 downto 11);
end if;

end process;

program_counting: process(clk, reset) --literally advancing the pc so it can save it
begin
	if(reset = '1') then
		pc_current <= (others => '0');
	elsif(clk = '1' and clk'event) then
		pc_current <= next_pc;
	end if;
end process;

datapath <= IC_out(31 downto 26);
arithfunc <= IC_out(5 downto 0);
pc_out <= pc_current(3 downto 0);
rs_out <= out_a(3 downto 0);
rt_out <= out_b(3 downto 0);
branch_cond <= look_ahead(31 downto 26) & look_ahead(27 downto 26);
end path;
