library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoria is
    Port (
        clk         : in  std_logic;
        Endereco    : in  std_logic_vector(11 downto 0); -- 4096 posicoes = 12 bits
        DadoEscrita : in  std_logic_vector(31 downto 0);
        LeMem       : in  std_logic;
        EscreveMem  : in  std_logic;
        DadoLeitura : out std_logic_vector(31 downto 0)
    );
end memoria;

architecture Comportamental of memoria is
begin
    -- TODO: Trilha 3 implementa a RAM (Dados e Instrucoes unificados)
end Comportamental;
