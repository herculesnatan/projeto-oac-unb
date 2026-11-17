library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity banco_registradores is
    Port (
        clk         : in  std_logic;
        EscreveReg  : in  std_logic;
        rs1         : in  std_logic_vector(4 downto 0);
        rs2         : in  std_logic_vector(4 downto 0);
        rd          : in  std_logic_vector(4 downto 0);
        DadoEscrita : in  std_logic_vector(31 downto 0);
        Dado1       : out std_logic_vector(31 downto 0);
        Dado2       : out std_logic_vector(31 downto 0)
    );
end banco_registradores;

architecture Comportamental of banco_registradores is
    -- Define o tipo de memória: 32 posições de 32 bits
    type mem_array is array (0 to 31) of std_logic_vector(31 downto 0);
    
    -- Cria o sinal dos registradores e inicializa tudo com zero para evitar 'U' no ModelSim
    signal registradores : mem_array := (others => (others => '0'));
begin

    -- Processo de Escrita (Síncrono)
    process(clk)
    begin
        if rising_edge(clk) then
            -- Só escreve se o controle mandar E se não for o registrador x0 (que é sempre 0)
            if EscreveReg = '1' and rd /= "00000" then
                registradores(to_integer(unsigned(rd))) <= DadoEscrita;
            end if;
        end if;
    end process;

    -- Leitura (Assíncrona / Imediata)
    -- Se pedir para ler o x0, força a saída para 0. Senão, lê o registrador pedido.
    Dado1 <= (others => '0') when rs1 = "00000" else registradores(to_integer(unsigned(rs1)));
    Dado2 <= (others => '0') when rs2 = "00000" else registradores(to_integer(unsigned(rs2)));

end Comportamental;
