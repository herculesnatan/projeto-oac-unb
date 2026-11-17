library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controle_ula is
    Port (
        ALUOp      : in  std_logic_vector(1 downto 0);
        Funct3     : in  std_logic_vector(2 downto 0);
        Funct7     : in  std_logic; -- Apenas o bit 30 importa para RISC-V base
        Controle   : out std_logic_vector(3 downto 0)
    );
end controle_ula;

architecture Comportamental of controle_ula is
begin
    -- TODO: Trilha 2 decodifica a operacao exata da ULA
end Comportamental;
