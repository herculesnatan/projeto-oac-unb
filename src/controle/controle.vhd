library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controle is
    Port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        opcode        : in  std_logic_vector(6 downto 0);
        
        -- Sinais de Saida conforme Diagrama
        EscrevePCCond : out std_logic;
        EscrevePC     : out std_logic;
        IouD          : out std_logic;
        LeMem         : out std_logic;
        EscreveMem    : out std_logic;
        EscreveIR     : out std_logic;
        Mem2Reg       : out std_logic;
        EscreveReg    : out std_logic;
        EscrevePCB    : out std_logic;
        PCback        : out std_logic;
        OrigAULA      : out std_logic_vector(1 downto 0);
        OrigBULA      : out std_logic_vector(1 downto 0);
        ALUOp         : out std_logic_vector(1 downto 0);
        OrigPC        : out std_logic_vector(1 downto 0)
    );
end controle;

architecture FSM of controle is
    type estado_t is (
        BUSCA, CAPTURA_INSTRUCAO, DECODIFICA,
        CALC_ENDERECO, LE_MEMORIA, CAPTURA_DADO, GRAVA_LW, ESCREVE_MEMORIA,
        EXEC_ALU_REG, EXEC_ALU_IMM, EXEC_LUI, EXEC_AUIPC, GRAVA_ALU,
        DESVIO, SALTA_JAL, SALTA_JALR, CALC_RETORNO
    );

    signal estado_atual, proximo_estado : estado_t;

    -- Entradas do seletor A da ULA
    constant A_PC_SALVO : std_logic_vector(1 downto 0) := "00";
    constant A_RS1      : std_logic_vector(1 downto 0) := "01";
    constant A_PC       : std_logic_vector(1 downto 0) := "10";
    constant A_ZERO     : std_logic_vector(1 downto 0) := "11";

    -- Entradas do seletor B da ULA
    constant B_RS2      : std_logic_vector(1 downto 0) := "00";
    constant B_QUATRO   : std_logic_vector(1 downto 0) := "01";
    constant B_IMM      : std_logic_vector(1 downto 0) := "10";
    constant B_IMM_X2   : std_logic_vector(1 downto 0) := "11";

    -- Fontes do proximo PC
    constant PC_ULA     : std_logic_vector(1 downto 0) := "00";
    constant PC_ALUOUT  : std_logic_vector(1 downto 0) := "01";
    constant PC_JALR    : std_logic_vector(1 downto 0) := "10";

begin
    process(clk, reset)
    begin
        if reset = '1' then
            estado_atual <= BUSCA;
        elsif rising_edge(clk) then
            estado_atual <= proximo_estado;
        end if;
    end process;

    process(estado_atual, opcode, reset)
    begin
        proximo_estado <= BUSCA;
        EscrevePCCond  <= '0';
        EscrevePC      <= '0';
        IouD           <= '0';
        LeMem          <= '0';
        EscreveMem     <= '0';
        EscreveIR      <= '0';
        Mem2Reg        <= '0';
        EscreveReg     <= '0';
        EscrevePCB     <= '0';
        PCback         <= '0';
        OrigAULA        <= A_PC_SALVO;
        OrigBULA       <= B_RS2;
        ALUOp          <= "00";
        OrigPC         <= PC_ULA;

        if reset = '0' then
            case estado_atual is
                when BUSCA =>
                    LeMem <= '1';
                    proximo_estado <= CAPTURA_INSTRUCAO;

                when CAPTURA_INSTRUCAO =>
                    LeMem      <= '1';
                    EscreveIR  <= '1';
                    EscrevePCB <= '1'; -- Guarda o PC desta instrucao
                    OrigAULA    <= A_PC;
                    OrigBULA   <= B_QUATRO;
                    EscrevePC  <= '1'; -- PC recebe PC + 4
                    proximo_estado <= DECODIFICA;

                when DECODIFICA =>
                    case opcode is
                        when "0000011" | "0100011" => -- LW e SW
                            proximo_estado <= CALC_ENDERECO;

                        when "0110011" =>
                            proximo_estado <= EXEC_ALU_REG;

                        when "0010011" => -- ADDI, ANDI, ORI, XORI
                            proximo_estado <= EXEC_ALU_IMM;

                        when "1100011" => -- BEQ e BNE
                            OrigAULA  <= A_PC_SALVO;
                            OrigBULA <= B_IMM_X2;
                            proximo_estado <= DESVIO;

                        when "1101111" => -- JAL
                            proximo_estado <= SALTA_JAL;

                        when "1100111" => -- JALR
                            proximo_estado <= SALTA_JALR;

                        when "0110111" => -- LUI
                            proximo_estado <= EXEC_LUI;

                        when "0010111" => -- AUIPC
                            proximo_estado <= EXEC_AUIPC;

                        when others =>
                            proximo_estado <= BUSCA;
                    end case;

                when CALC_ENDERECO =>
                    OrigAULA  <= A_RS1;
                    OrigBULA <= B_IMM;
                    if opcode = "0000011" then
                        proximo_estado <= LE_MEMORIA;
                    else
                        proximo_estado <= ESCREVE_MEMORIA;
                    end if;

                when LE_MEMORIA | CAPTURA_DADO =>
                    IouD     <= '1';
                    LeMem    <= '1';
                    -- Mantem o endereco no registrador de saida da ULA
                    OrigAULA  <= A_RS1;
                    OrigBULA <= B_IMM;
                    if estado_atual = LE_MEMORIA then
                        proximo_estado <= CAPTURA_DADO;
                    else
                        proximo_estado <= GRAVA_LW;
                    end if;

                when GRAVA_LW =>
                    Mem2Reg    <= '1';
                    EscreveReg <= '1';

                when ESCREVE_MEMORIA =>
                    IouD       <= '1';
                    EscreveMem <= '1';

                when EXEC_ALU_REG =>
                    OrigAULA  <= A_RS1;
                    OrigBULA <= B_RS2;
                    ALUOp    <= "10";
                    proximo_estado <= GRAVA_ALU;

                when EXEC_ALU_IMM =>
                    OrigAULA  <= A_RS1;
                    OrigBULA <= B_IMM;
                    ALUOp    <= "11";
                    proximo_estado <= GRAVA_ALU;

                when EXEC_LUI =>
                    OrigAULA  <= A_ZERO;
                    OrigBULA <= B_IMM;
                    proximo_estado <= GRAVA_ALU;

                when EXEC_AUIPC =>
                    OrigAULA  <= A_PC_SALVO;
                    OrigBULA <= B_IMM;
                    proximo_estado <= GRAVA_ALU;

                when GRAVA_ALU =>
                    EscreveReg <= '1';

                when DESVIO =>
                    OrigAULA       <= A_RS1;
                    OrigBULA      <= B_RS2;
                    ALUOp         <= "01"; -- Compara por subtracao
                    OrigPC        <= PC_ALUOUT;
                    EscrevePCCond <= '1';

                when SALTA_JAL =>
                    OrigAULA   <= A_PC_SALVO;
                    OrigBULA  <= B_IMM_X2;
                    EscrevePC <= '1';
                    proximo_estado <= CALC_RETORNO;

                when SALTA_JALR =>
                    OrigAULA   <= A_RS1;
                    OrigBULA  <= B_IMM;
                    OrigPC    <= PC_JALR;
                    EscrevePC <= '1';
                    proximo_estado <= CALC_RETORNO;

                when CALC_RETORNO =>
                    OrigAULA  <= A_PC_SALVO;
                    OrigBULA <= B_QUATRO;
                    proximo_estado <= GRAVA_ALU;
            end case;
        end if;
    end process;
end FSM;
    
