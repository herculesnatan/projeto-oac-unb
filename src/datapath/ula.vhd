library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula is
    Port (
        A        : in  std_logic_vector(31 downto 0);
        B        : in  std_logic_vector(31 downto 0);
        Controle : in  std_logic_vector(3 downto 0);
        SaidaULA : out std_logic_vector(31 downto 0);
        Zero     : out std_logic;
        Menor    : out std_logic; -- Para BLT / BGE (com sinal)
        MenorU   : out std_logic  -- Para BLTU / BGEU (sem sinal)
    );
end ula;

architecture Comportamental of ula is
begin
    process(A, B, Controle)
        variable resultado_temp : std_logic_vector(31 downto 0);
        variable shamt          : integer range 0 to 31;
    begin
        -- Quantidade de deslocamento (5 bits menos significativos de B)
        shamt := to_integer(unsigned(B(4 downto 0)));

        case Controle is
            when "0000" => -- AND / ANDI
                resultado_temp := A and B;

            when "0001" => -- OR / ORI
                resultado_temp := A or B;

            when "0010" => -- ADD / ADDI / LW / SW / AUIPC
                resultado_temp := std_logic_vector(signed(A) + signed(B));

            when "0011" => -- XOR / XORI
                resultado_temp := A xor B;

            when "0110" => -- SUB / Branches
                resultado_temp := std_logic_vector(signed(A) - signed(B));

            when "0111" => -- SLT / SLTI (com sinal)
                if signed(A) < signed(B) then
                    resultado_temp := x"00000001";
                else
                    resultado_temp := x"00000000";
                end if;

            when "1000" => -- SLTU / SLTIU (sem sinal)
                if unsigned(A) < unsigned(B) then
                    resultado_temp := x"00000001";
                else
                    resultado_temp := x"00000000";
                end if;

            when "1001" => -- SLL / SLLI (deslocamento lógico à esquerda)
                resultado_temp := std_logic_vector(shift_left(unsigned(A), shamt));

            when "1010" => -- SRL / SRLI (deslocamento lógico à direita)
                resultado_temp := std_logic_vector(shift_right(unsigned(A), shamt));

            when "1011" => -- SRA / SRAI (deslocamento aritmético à direita)
                resultado_temp := std_logic_vector(shift_right(signed(A), shamt));

            when others =>
                resultado_temp := (others => '0');
        end case;

        SaidaULA <= resultado_temp;

        -- Flags de comparação para todos os Branches
        if resultado_temp = x"00000000" then
            Zero <= '1';
        else
            Zero <= '0';
        end if;

        if signed(A) < signed(B) then
            Menor <= '1';
        else
            Menor <= '0';
        end if;

        if unsigned(A) < unsigned(B) then
            MenorU <= '1';
        else
            MenorU <= '0';
        end if;
    end process;
end Comportamental;
