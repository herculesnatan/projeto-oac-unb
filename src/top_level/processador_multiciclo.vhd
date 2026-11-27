library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processador_multiciclo is
    Port (
        clk   : in std_logic;
        reset : in std_logic
    );
end processador_multiciclo;

architecture Estrutural of processador_multiciclo is
    subtype palavra_t is std_logic_vector(31 downto 0);

    signal pc, pc_salvo, proximo_pc : palavra_t;
    signal ir, mdr, reg_a, reg_b : palavra_t;

    signal endereco_memoria, dado_memoria : palavra_t;
    signal dado_rs1, dado_rs2, dado_escrita_reg : palavra_t;
    signal imediato, entrada_a_ula, entrada_b_ula : palavra_t;
    signal resultado_ula, resultado_guardado : palavra_t;

    signal escreve_pc, escreve_pc_cond, habilita_pc : std_logic;
    signal ioud, le_mem, escreve_mem, escreve_ir : std_logic;
    signal mem2reg, escreve_reg, escreve_pc_salvo : std_logic;
    signal zero, menor, menor_u, condicao_branch : std_logic;

    signal orig_a_ula, orig_b_ula, alu_op, orig_pc : std_logic_vector(1 downto 0);
    signal controle_operacao : std_logic_vector(3 downto 0);

begin
    unidade_controle : entity work.controle
        port map (
            clk           => clk,
            reset         => reset,
            opcode        => ir(6 downto 0),
            EscrevePCCond => escreve_pc_cond,
            EscrevePC     => escreve_pc,
            IouD          => ioud,
            LeMem         => le_mem,
            EscreveMem    => escreve_mem,
            EscreveIR     => escreve_ir,
            Mem2Reg       => mem2reg,
            EscreveReg    => escreve_reg,
            EscrevePCB    => escreve_pc_salvo,
            PCback        => open,
            OrigAULA      => orig_a_ula,
            OrigBULA      => orig_b_ula,
            ALUOp         => alu_op,
            OrigPC        => orig_pc
        );

    decodificador_ula : entity work.controle_ula
        port map (
            ALUOp    => alu_op,
            Funct3   => ir(14 downto 12),
            Funct7   => ir(30),
            Controle => controle_operacao
        );

    ram : entity work.memoria
        port map (
            clk         => clk,
            Endereco    => endereco_memoria(13 downto 2),
            DadoEscrita => reg_b,
            LeMem       => le_mem,
            EscreveMem  => escreve_mem,
            DadoLeitura => dado_memoria
        );

    registradores : entity work.banco_registradores
        port map (
            clk         => clk,
            EscreveReg  => escreve_reg,
            rs1         => ir(19 downto 15),
            rs2         => ir(24 downto 20),
            rd          => ir(11 downto 7),
            DadoEscrita => dado_escrita_reg,
            Dado1       => dado_rs1,
            Dado2       => dado_rs2
        );

    gerador : entity work.geracao_imediato
        port map (
            instrucao => ir,
            imediato  => imediato
        );

    unidade_ula : entity work.ula
        port map (
            A        => entrada_a_ula,
            B        => entrada_b_ula,
            Controle => controle_operacao,
            SaidaULA => resultado_ula,
            Zero     => zero,
            Menor    => menor,
            MenorU   => menor_u
        );

    endereco_memoria <= pc when ioud = '0' else resultado_guardado;
    dado_escrita_reg <= resultado_guardado when mem2reg = '0' else mdr;

    with orig_a_ula select
        entrada_a_ula <= pc_salvo         when "00",
                         reg_a            when "01",
                         pc               when "10",
                         (others => '0')  when others;

    with orig_b_ula select
        entrada_b_ula <= reg_b                           when "00",
                         x"00000004"                     when "01",
                         imediato                        when "10",
                         imediato(30 downto 0) & '0'     when "11",
                         (others => '0')                 when others;

    with orig_pc select
        proximo_pc <= resultado_ula                   when "00",
                      resultado_guardado              when "01",
                      resultado_ula(31 downto 1) & '0' when "10",
                      pc                              when others;

    -- Grupo Branch: escolhe a condicao a partir de funct3.
    with ir(14 downto 12) select
        condicao_branch <= zero        when "000", -- BEQ
                           not zero    when "001", -- BNE
                           menor       when "100", -- BLT
                           not menor   when "101", -- BGE
                           menor_u     when "110", -- BLTU
                           not menor_u when "111", -- BGEU
                           '0'         when others;

    habilita_pc <= escreve_pc or (escreve_pc_cond and condicao_branch);

    process(clk, reset)
    begin
        if reset = '1' then
            pc                <= (others => '0');
            pc_salvo          <= (others => '0');
            ir                <= (others => '0');
            mdr               <= (others => '0');
            reg_a             <= (others => '0');
            reg_b             <= (others => '0');
            resultado_guardado <= (others => '0');
        elsif rising_edge(clk) then
            if habilita_pc = '1' then
                pc <= proximo_pc;
            end if;

            if escreve_pc_salvo = '1' then
                pc_salvo <= pc;
            end if;

            if escreve_ir = '1' then
                ir <= dado_memoria;
            end if;

            if le_mem = '1' then
                mdr <= dado_memoria;
            end if;

            reg_a              <= dado_rs1;
            reg_b              <= dado_rs2;
            resultado_guardado <= resultado_ula;
        end if;
    end process;
end Estrutural;
