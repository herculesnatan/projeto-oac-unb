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
begin
    -- TODO: Trilha 2 implementa a Maquina de Estados (Fetch, Decode, Exec...)
end FSM;
