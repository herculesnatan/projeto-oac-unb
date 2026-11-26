library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controle_ula is
    Port (
        ALUOp    : in  std_logic_vector(1 downto 0);
        Funct3   : in  std_logic_vector(2 downto 0);
        Funct7   : in  std_logic;
        Controle : out std_logic_vector(3 downto 0)
    );
end controle_ula;

architecture Comportamental of controle_ula is
begin

    process(ALUOp, Funct3, Funct7)
    begin
        case ALUOp is

            -- Soma: busca, cálculo de endereço e operações de adição
            when "00" =>
                Controle <= "0010";

            -- Subtração: comparação dos desvios
            when "01" =>
                Controle <= "0110";

            -- Operações entre registradores
            when "10" =>
                case Funct3 is
                    when "000" =>
                        if Funct7 = '1' then
                            Controle <= "0110"; -- SUB
                        else
                            Controle <= "0010"; -- ADD
                        end if;

                    when "111" =>
                        Controle <= "0000"; -- AND

                    when "110" =>
                        Controle <= "0001"; -- OR

                    when "100" =>
                        Controle <= "0011"; -- XOR

                    when "010" =>
                        Controle <= "0111"; -- SLT

                    when others =>
                        Controle <= "0010";
                end case;

            -- Operações imediatas
            when "11" =>
                case Funct3 is
                    when "000" =>
                        Controle <= "0010"; -- ADDI

                    when "111" =>
                        Controle <= "0000"; -- ANDI

                    when "110" =>
                        Controle <= "0001"; -- ORI

                    when "100" =>
                        Controle <= "0011"; -- XORI

                    when "010" =>
                        Controle <= "0111"; -- SLTI

                    when others =>
                        Controle <= "0010";
                end case;

            when others =>
                Controle <= "0010";

        end case;
    end process;

end Comportamental;
