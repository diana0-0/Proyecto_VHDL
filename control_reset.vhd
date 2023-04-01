-- Control reset al presionar el boton

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity control_reset is
	generic(
		counter_size: integer := 26
	);
	port(
		clk: in std_logic;
		keyR: in std_logic; -- activa en bajo
		pulseR: out std_logic := '0'		
	);
end control_reset;


architecture arch of control_reset is	
	signal counter: std_logic_vector(counter_size-1 downto 0) := (others => '0');
	signal ff1, ff2: std_logic;
	signal reset: std_logic;
	begin		
		reset <= ff1 xor ff2;
		process(clk)
			variable pulso_activo : std_logic := '0';			
		begin
			if(clk'event and clk='1') then
				ff1 <= keyR;
				ff2 <= ff1;			
				if(reset = '1' and pulso_activo = '0') then
					pulseR <= '1';
					counter <= (others => '0');
					pulso_activo := '1';
				elsif(counter(counter_size-1) /= '1') then
					counter <= counter + 1;
				else
					pulseR <= '0';
					pulso_activo := '0';
				end if;
			end if;
		end process;		
	end arch;