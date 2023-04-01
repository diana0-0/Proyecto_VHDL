library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;
--use ieee.numeric_std.ALL;
use ieee.std_logic_arith.ALL;

entity draw_trex is
	generic(
		H_counter_size: natural:= 10; --sobran
		V_counter_size: natural:= 10
	);
	port(
		clk: in std_logic;
		jump: in std_logic;
		down: in std_logic;
		reset2: in std_logic;
		pixel_x: in integer;
		pixel_y: in integer;
		rgbDrawColor: out std_logic_vector(11 downto 0) := (others => '0')
	);
end draw_trex;

architecture arch of draw_trex is
	constant PIX : integer := 16;
	constant COLS : integer := 40;
	constant T_FAC : integer := 100000;
	constant cactusSpeed : integer := 40;
	constant pterodSpeed : integer := 40;
	
	signal cloudX_1: integer := 40;
	signal cloudY_1: integer := 8;
	
	-- T-Rex
	signal trexX: integer := 8;
	signal trexY: integer := 24;
	signal saltando: std_logic := '0';
	signal agacharse: std_logic := '0';
	signal gameover1: std_logic := '0';
	signal gameover2: std_logic := '0';
	signal off: std_logic := '1';
	
	-- Cactus	
	signal cactusX_1: integer := COLS;
	signal cactusY: integer := 24;
	
	-- Cloud 1	
	signal cloudX: integer := COLS;
	signal cloudY: integer := 3;
	
	-- Cloud 2	
	signal cloudX_2: integer := 11;
	signal cloudY_2: integer := 3;
	
	-- Pterodactilo1	
	signal pterodX: integer := COLS;
	signal pterodY: integer := 23;
	
	-- Game Over
	signal gameOverX: integer := 0;
	signal gameOverY: integer := 24;
	
	-- Pterodactilo	
	--signal pterodX: integer := 1;
	--signal pterodY: integer := 24;
	
-- Sprites
type sprite_block is array(0 to 15, 0 to 15) of integer range 0 to 1;
constant cloud: sprite_block:=(	(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
											(0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
											(0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 8
											(0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 9
											(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 10
											(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
											(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15

constant trex_up: sprite_block:=((0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
											(0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 1 
											(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 2
											(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
											(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
											(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
											(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
											(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
											(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
											(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
											(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
											(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
											(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
											(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
											(0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
											(0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15
								
constant trex_down: sprite_block:=( (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
												(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
												(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
												(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
												(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4 
												(0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,0), -- 5 
												(0,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 6 
												(1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1), -- 7
												(1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1), -- 8
												(1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1), -- 9
												(1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1), -- 10
												(1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1), -- 11
												(1,1,1,1,1,1,1,0,1,0,1,0,1,1,1,0), -- 12
												(1,1,1,1,1,1,0,0,1,0,0,0,1,1,1,0), -- 13
												(0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0), -- 14
												(0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0)); -- 15

constant pterodactilo: sprite_block:=( (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
													(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
													(0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1), -- 2
													(0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0), -- 3
													(0,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0), -- 4 
													(1,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0), -- 5 
										  			(0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0), -- 6 
										    		(0,0,0,0,1,1,0,0,0,1,1,1,1,0,0,0), -- 7
										   		(0,0,0,0,1,1,1,0,1,1,1,1,0,0,0,0), -- 8
										   		(0,0,0,1,0,1,1,1,1,1,1,0,0,0,0,0), -- 9
										   		(0,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1), -- 10
										   		(1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 11
										   		(0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0), -- 12
										   		(0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0), -- 13
										   		(0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0), -- 14
										   		(0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0)); -- 15
													
constant gameOver: sprite_block:=(  (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 0 
												(1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1), -- 1 
												(1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1), -- 2
												(1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1), -- 3
												(1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1), -- 4 
												(1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,1), -- 5 
										  		(1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1), -- 6 
										    	(1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1), -- 7
										   	(1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1), -- 8
										   	(1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1), -- 9
										   	(1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,1), -- 10
										   	(1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1), -- 11
										   	(1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1), -- 12
										   	(1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1), -- 13
										   	(1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1), -- 14
										   	(0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0)); -- 15
												
constant ground: sprite_block:=(  (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 0 
												(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 1 
												(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 2
												(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 3
												(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 4 
												(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 5 
										  		(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 6 
										    	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 8
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 9
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 10
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 12
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 13
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 14
										   	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)); -- 15

constant cactus: sprite_block :=((0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 0 
											(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 1 
									 		(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
											(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 3
									 		(0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0), -- 4
									 		(0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 5
									 		(0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 6
									 		(0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 7
									 		(0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 8
									 		(0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
									 		(0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0), -- 10
									 		(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 11
									 		(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 12
		 							 		(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 13
									 		(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 14
									 		(0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));-- 15									
									 
type color_arr is array(0 to 1) of std_logic_vector(11 downto 0);	
--Necesito mas array 								 
constant sprite_color : color_arr := ("100010101111", "010010100000");
constant sprite_color_TRex : color_arr := ("100010101111", "111100100010");
constant sprite_color_Cloud : color_arr := ("100010101111", "111111111111");
constant sprite_color_Ground1 : color_arr := ("100010101111", "010010100000");
constant sprite_color_Ground2 : color_arr := ("100010101111", "011100110000");
constant sprite_color_Sun : color_arr := ("100010101111", "111110110000");
constant sprite_color_Cactus : color_arr := ("100010101111", "010110010000");
constant sprite_color_GameOver : color_arr := ("100010101111", "111100000000");
constant sprite_color_Pterodactilo : color_arr := ("100010101111", "101000001111");


begin
	draw_objects: process(clk, pixel_x, pixel_y)	
	
	variable sprite_x : integer := 0;
	variable sprite_y : integer := 0;
	
	begin			
		if(clk'event and clk='1') then		
			-- Dibuja el fondo
			rgbDrawColor <= "1000" & "1010" & "1111";
			--rgbDrawColor2 <= "0000" & "0000" & "0000"; --Color azul bonito
					
			-- Dibuja el suelo
			
			sprite_x := pixel_x mod PIX;
			sprite_y := pixel_y mod PIX;
			
			-- Sun
			if ((pixel_x / PIX = 7 or pixel_x / PIX = 8 or pixel_x / PIX = 9) and (pixel_y / PIX = 3 or pixel_y / PIX = 4 or pixel_y / PIX = 5)) then 
				rgbDrawColor <= sprite_color_Sun(ground(sprite_y, sprite_x));
			end if;
			
			-- Ground 1
			if (pixel_y / PIX = 25) then 
				rgbDrawColor <= sprite_color_Ground1(ground(sprite_y, sprite_x));
			end if;
			-- Ground 2
			if (pixel_y / PIX = 26 or pixel_y / PIX = 27 or pixel_y / PIX = 28 or pixel_y / PIX = 29) then 
				rgbDrawColor <= sprite_color_Ground2(ground(sprite_y, sprite_x));
			end if;
			-- Nube 1
			if ((pixel_x / PIX = cloudX) and (pixel_y / PIX = cloudY)) then 
				rgbDrawColor <= sprite_color_Cloud(cloud(sprite_y, sprite_x));
			end if;
			-- Nube 2
			if ((pixel_x / PIX = cloudX_2) and (pixel_y / PIX = cloudY_2)) then 
				rgbDrawColor <= sprite_color_Cloud(cloud(sprite_y, sprite_x));
			end if;
						
			-- Cactus1
			--                 40            and           30
			if ((pixel_x / PIX = cactusX_1) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color_Cactus(cactus(sprite_y, sprite_x));
			--                                        16   ,   16
			end if;				
						
			-- Pterodactilo
			if ((pixel_x / PIX = pterodX) and (pixel_y / PIX = pterodY)) then 
				rgbDrawColor <= sprite_color_Pterodactilo(pterodactilo(sprite_y, sprite_x));
			end if;
			
			-- T-Rex Jump
			if (saltando = '1') then
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_TRex(trex_up(sprite_y, sprite_x));			
				end if;
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_TRex(trex_up(sprite_y, sprite_x));			
				end if;
			end if;
			
			-- T-Rex Down
			if (agacharse = '1') then
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_TRex(trex_down(sprite_y, sprite_x));			
				end if;
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_TRex(trex_up(sprite_y, sprite_x));			
				end if;
			end if;
			
			-- Game Over 1
			if (gameover1 = '1') then
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_GameOver(gameOver(sprite_y, sprite_x));			
				end if;
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_TRex(trex_up(sprite_y, sprite_x));			
				end if;
			end if;
			
			-- Game Over 2
			if (gameover2 = '1') then
				if	((pixel_x / PIX = gameOverX) and (pixel_y / PIX = gameOverY)) then
					rgbDrawColor <= sprite_color_GameOver(gameOver(sprite_y, sprite_x));			
				end if;
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
					rgbDrawColor <= sprite_color_TRex(trex_up(sprite_y, sprite_x));			
				end if;
			end if;
			
			--Reset
			if (off = '1')then
				rgbDrawColor <= "1111" & "1111" & "1111";
			end if;
			
		end if;
	end process;
	
	actions: process(clk, jump, down)	
	variable cactusCount: integer := 0;
	variable pterodCount: integer := 0;
	variable cloudCount: integer := 0;
	begin		
		if(clk'event and clk = '1') then
			
			if(reset2 = '1') then
				off <= '1';
			else
				off <= '0';
				-- Salto
				if(jump = '1') then
					saltando <= '1';
					if (trexY > 20) then
						trexY <= trexY - 1;
					else
						saltando <= '0';
					end if;
				else
					saltando <= '0';
					if (trexY < 24) then
						trexY <= trexY + 1;
					end if;
				end if;		
				-- Agacharse
				if(down = '1') then
					agacharse <= '1';
					--if (trexY < 24) then
						--trexY <= trexY + 1;
					--else
						--agacharse <= '0';
					--end if;
				else
					agacharse <= '0';
				end if;	
				
				-- Cactus Movement
				if (cactusCount >= T_FAC * cactusSpeed) then
					if (cactusX_1 <= 0) then
						cactusX_1 <= COLS;				
					else
						cactusX_1 <= cactusX_1 - 1;					
					end if;
						
					cactusCount := 0;
				end if;
				cactusCount := cactusCount + 1;
				
				-- Cloud Movement
				if (cloudCount >= T_FAC * cactusSpeed) then
					if (cloudX <= 0) then
						cloudX <= COLS;				
					else
						cloudX <= cloudX - 1;					
					end if;
						
					cloudCount := 0;
				end if;
				cloudCount := cloudCount + 1;
				
				-- Pterodactile Movement
				if (pterodCount >= T_FAC * pterodSpeed) then
					if (pterodX <= 0) then
						pterodX <= COLS;				
					else
						pterodX <= pterodX - 2;					
					end if;
					pterodCount := 0;
				end if;
				pterodCount := pterodCount + 1;
				
				-- Game Over 1
				if ((trexX = cactusX_1) and (trexY = cactusY)) then
					gameover1 <= '1';
				else
					gameover1 <= '0';
				end if;
				
				-- Game Over 2
				if (trexY = pterodY) then
					--if(down = '0')then
						gameover2 <= '1';
					--else
						--gameover2 <= '0';
					--end if;
				else
					gameover2 <= '0';
				end if;
				 
				-- You Lose
				if(gameover1 = '1' or gameover2 = '1')then
					off <= '1';
				end if;
				
			end if;
		end if;
	end process;
	
end arch;