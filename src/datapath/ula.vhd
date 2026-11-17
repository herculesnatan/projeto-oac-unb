library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula is
    Port (
        A          : in  std_logic_vector(31 downto 0);
        B          : in  std_logic_vector(31 downto 0);
        Controle   : in  std_logic_vector(3 downto 0);
        SaidaULA   : out std_logic_vector(31 downto 0);
        Zero       : out std_logic
    );
end ula;

architecture Comportamental of ula is
begin
    -- TODO: Trilha 1 implementa a logica da ULA aqui
end Comportamental;
