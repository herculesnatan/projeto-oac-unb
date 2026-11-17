architecture Comportamental of geracao_imediato is
begin
    process(instrucao)
        -- Variável para ler os 7 bits finais e descobrir o tipo da instrução
        variable opcode : std_logic_vector(6 downto 0);
    begin
        opcode := instrucao(6 downto 0);
        
        case opcode is
            -- Tipo I (LW, ADDi, ANDI, ORi, XORI, JALR)
            when "0000011" | "0010011" | "1100111" =>
                -- Pega os 12 bits mais significativos e estende o sinal para 32 bits
                imediato <= std_logic_vector(resize(signed(instrucao(31 downto 20)), 32));
                
            -- Tipo S (SW)
            when "0100011" =>
                -- Junta os bits separados do imediato tipo S
                imediato <= std_logic_vector(resize(signed(instrucao(31 downto 25) & instrucao(11 downto 7)), 32));
                
            -- Tipo B (BEQ, BNE, etc.)
            when "1100011" =>
                imediato <= std_logic_vector(resize(signed(instrucao(31) & instrucao(7) & instrucao(30 downto 25) & instrucao(11 downto 8)), 32));
                
            -- Tipo U (LUI, AUIPC)
            when "0110111" | "0010111" =>
                -- Imediato de 20 bits no topo, e preenche os 12 bits de baixo com zeros
                imediato <= instrucao(31 downto 12) & x"000";
                
            -- Tipo J (JAL)
            when "1101111" =>
                imediato <= std_logic_vector(resize(signed(instrucao(31) & instrucao(19 downto 12) & instrucao(20) & instrucao(30 downto 21)), 32));
                
            when others =>
                imediato <= (others => '0');
        end case;
    end process;
end Comportamental;
