# Projeto RISC-V Multiciclo em VHDL

Este repositório contém o código do processador RISC-V multiciclo.

## Organização por Trilhas
- **Trilha 1 (Datapath):** `src/datapath`
- **Trilha 2 (Controle):** `src/controle`
- **Trilha 3 (Memória e Top-Level):** `src/memoria` e `src/top_level`

**REGRA DE OURO:** Não altere as declarações de `entity` dos arquivos. Elas são o contrato de ligação do arquivo Top-Level.
