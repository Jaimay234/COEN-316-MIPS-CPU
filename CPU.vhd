library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
entity cpu is
port(reset : in std_logic;
	clk : in std_logic;
	rs_out, rt_out : out std_logic_vector(3 downto 0);
	-- output ports from register file
	pc_out : out std_logic_vector(3 downto 0); -- pc reg
	overflow, zero : out std_logic);
end cpu;

architecture cpu_flow of cpu is
--signal declaration
	signal pc_sel : std_logic_vector(1 downto 0);
	signal branch_type: std_logic_vector(1 downto 0);
        signal reg_dst        : std_logic; --rt (0) or rd(1)
        signal alu_src        : std_logic; --alu input 2 source
        signal add_sub        : std_logic; --alu add or sub
        signal logic_func     : std_logic_vector(1 downto 0); --AND OR XOR NOR
        signal data_write     : std_logic; --write into data cache or not
	signal data_write_reg : std_logic; --write into register
        signal reg_in_src     : std_logic; --ALU or D cache
        signal ext_func       : std_logic_vector(1 downto 0); --extender function 
	signal opcode         : std_logic_vector(5 downto 0);
	signal arithfunc      : std_logic_vector(5 downto 0);
	signal lookahead      : std_logic_vector(7 downto 0);

--component declaration
component Datapath
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
end component;
begin

Datapath_component: Datapath
	port map(
	reset => reset,
	clk => clk,
	overflow => overflow,
	zero => zero,
	pc_sel => pc_sel,
	branch_type => branch_type,
	reg_dst => reg_dst, --register destination
	alu_src => alu_src, --alu source mux
	add_sub => add_sub, --add or sub
	logic_func => logic_func,
	data_write => data_write, --dram data check
	data_write_reg => data_write_reg, --write in to register
	reg_in_src => reg_in_src, --register input source
	ext_func => ext_func, --sign extend function
	datapath =>opcode,
	arithfunc => arithfunc, --last 5 bits
	pc_out => pc_out,
	rs_out => rs_out,
	rt_out => rt_out,
	branch_cond => lookahead
);

Control_unit : process(opcode, arithfunc, reset)

begin
if(reset = '1') then
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <= '0';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "00";
	pc_sel <= "00";
	
else
	case opcode is
	when "001111" => --lui
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '1';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "00";
	pc_sel <= "00";
	when "000000" => --add sub slt and or xor nor jr
	case arithfunc is
		when "100000" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '0';
			data_write <= '0';
			logic_func <= "00";
			ext_func <= "10";
			branch_type <= "00";
			pc_sel <= "00";
		when "100010" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '1';
			data_write <= '0';
			logic_func <= "00";
			ext_func <= "10";
			branch_type <= "00";
			pc_sel <= "00";
		when "101010" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '1';
			data_write <= '0';
			logic_func <= "00";
			ext_func <= "01";
			branch_type <= "00";
			pc_sel <= "00";
		when "100100" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '1';
			data_write <= '0';
			logic_func <= "00";
			ext_func <= "11";
			branch_type <= "00";
			pc_sel <= "00";
		when "100101" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '1';
			data_write <= '0';
			logic_func <= "01";
			ext_func <= "11";
			branch_type <= "00";
			pc_sel <= "00";
		when "100110" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '1';
			data_write <= '0';
			logic_func <= "10";
			ext_func <= "11";
			branch_type <= "00";
			pc_sel <= "00";
		when "100111" =>
			data_write_reg <= '1';
			reg_dst <= '1';
			reg_in_src <= '1';
			alu_src <='0';
			add_sub <= '1';
			data_write <= '0';
			logic_func <= "11";
			ext_func <= "11";
			branch_type <= "00";
			pc_sel <= "00";
		when "001000" =>
			data_write_reg <= '0';
			reg_dst <= '0';
			reg_in_src <= '0';
			alu_src <='1';
			add_sub <= '0';
			data_write <= '0';
			logic_func <= "00";
			ext_func <= "00";
			branch_type <= "00";
			pc_sel <= "10";
		when others =>
			data_write_reg <= '0';
			reg_dst <= '0';
			reg_in_src <= '0';
			alu_src <='0';
			add_sub <= '0';
			data_write <= '0';
			logic_func <= "00";
			ext_func <= "00";
			branch_type <= "00";
			pc_sel <= "00";
		end case;
	when "001000" => --addi
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '1';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "10";
	branch_type <= "00";
	pc_sel <= "00";
	when "001010" => --slti
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '1';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "00";
	pc_sel <= "00";
	when "001100" => --andi
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '1';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "11";
	branch_type <= "00";
	pc_sel <= "00";
	when "001101" => --ori
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '1';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "01";
	ext_func <= "11";
	branch_type <= "00";
	pc_sel <= "00";
	when "001110" => --xori
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '1';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "10";
	ext_func <= "11";
	branch_type <= "00";
	pc_sel <= "00";
	when "100011" => --lw
	data_write_reg <= '1';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "10";
	ext_func <= "10";
	branch_type <= "00";
	pc_sel <= "00";
	when "101011" => --sw
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '1';
	logic_func <= "10";
	ext_func <= "10";
	branch_type <= "00";
	pc_sel <= "00";
	when "000010" => --j
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='1';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "00";
	pc_sel <= "01";
	when "000001" => --bltz
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='0';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "01";
	branch_type <= "11";
	pc_sel <= "00";
	when "000100" => --beq
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='0';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "01";
	pc_sel <= "00";
	when "000101" => --bne
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='0';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "10";
	pc_sel <= "00";
	when others =>
	data_write_reg <= '0';
	reg_dst <= '0';
	reg_in_src <= '0';
	alu_src <='0';
	add_sub <= '0';
	data_write <= '0';
	logic_func <= "00";
	ext_func <= "00";
	branch_type <= "00";
	pc_sel <= "00";
end case;

end if;
end process;
end cpu_flow;