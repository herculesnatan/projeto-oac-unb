library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity geracao_imediato is
    Port (
        instrucao : in  std_logic_vector(31 downto 0);
        imediato  : out std_logic_vector(31 downto 0)
    );
end geracao_imediato;

architecture Comportamental of geracao_imediato is
begin
    process(instrucao)
        variable opcode : std_logic_vector(6 downto 0);
    begin
        opcode := instrucao(6 downto 0);
        
        case opcode is
            -- Tipo I (LW, ADDI, ORI, ANDI, XORI, SLTI, SLLI, SRLI, SRAI, JALR)
            when "0000011" | "0010011" | "1100111" =>
                imediato <= std_logic_vector(resize(signed(instrucao(31 downto 20)), 32));
                
            -- Tipo S (SW)
            when "0100011" =>
                imediato <= std_logic_vector(resize(signed(instrucao(31 downto 25) & instrucao(11 downto 7)), 32));
                
            -- Tipo B (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            when "1100011" =>
                imediato <= std_logic_vector(resize(signed(instrucao(31) & instrucao(7) & instrucao(30 downto 25) & instrucao(11 downto 8)), 32));
                
            -- Tipo U (LUI, AUIPC)
            when "0110111" | "0010111" =>
                imediato <= instrucao(31 downto 12) & x"000";
                
            -- Tipo J (JAL)
            when "1101111" =>
                imediato <= std_logic_vector(resize(signed(instrucao(31) & instrucao(19 downto 12) & instrucao(20) & instrucao(30 downto 21)), 32));
                
            when others =>
                imediato <= (others => '0');
        end case;
    end process;
end Comportamental;
