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

library IEEE;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

architecture Comportamental of memoria is
    type ram_t is array (0 to 4095) of std_logic_vector(31 downto 0);
    constant INICIO_DADOS : natural := 16#2000# / 4;

    procedure carregar_hex(
        variable conteudo : inout ram_t;
        nome_arquivo      : in string;
        inicio            : in natural;
        limite            : in natural
    ) is
        file arquivo      : text;
        variable status   : file_open_status;
        variable linha    : line;
        variable palavra  : std_logic_vector(31 downto 0);
        variable valido   : boolean;
        variable posicao  : natural := inicio;
    begin
        file_open(status, arquivo, nome_arquivo, read_mode);

        -- Permite simular a RAM vazia enquanto os arquivos nao existem.
        if status /= open_ok then
            report "Arquivo indisponivel: " & nome_arquivo severity note;
            return;
        end if;

        while not endfile(arquivo) loop
            readline(arquivo, linha);
            if linha.all'length > 0 then
                if posicao >= limite then
                    report "Arquivo excede a regiao da RAM: " & nome_arquivo
                        severity failure;
                    exit;
                end if;

                hread(linha, palavra, valido);
                if not valido then
                    report "Palavra hexadecimal invalida em " & nome_arquivo
                        severity failure;
                    exit;
                end if;

                conteudo(posicao) := palavra;
                posicao := posicao + 1;
            end if;
        end loop;

        file_close(arquivo);
    end procedure;

    impure function inicializar_ram return ram_t is
        variable conteudo : ram_t := (others => (others => '0'));
    begin
        carregar_hex(conteudo, "programa.hex", 0, INICIO_DADOS);
        carregar_hex(conteudo, "dados.hex", INICIO_DADOS, 4096);
        return conteudo;
    end function;

    signal ram : ram_t := inicializar_ram;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if EscreveMem = '1' then
                ram(to_integer(unsigned(Endereco))) <= DadoEscrita;
            end if;
        end if;
    end process;

    DadoLeitura <= ram(to_integer(unsigned(Endereco)))
                   when LeMem = '1' else (others => '0');
end Comportamental;
