# Sistema Operaciona HUSIS

Sistema Operacional Brasileiro e Modernoso para IBM PC :P

Objetivos:

- Rodar no IBM PC 4.77 Mhz
- Executar aplicações simples feitas para DOS (que se limitem a usar um sub conjunto do INT 21h)
- Ter um ambiente "gráfico" com usuário usando modo texto e muita bruxaria EGA/VGA para ter fontes bonitas.
- Permitir multitarefa Cooperativa orientada a eventos
- Ter suas partes principais feitas na linguagem T3X/86 (Uma linguagem simples que o compilador roda inteiramente no IBM PC rodando DOS 3.3)


Como melhor visualizar e editar o código fonte:

- Se for desenvolvido em Linux/Mac/Windows use o Visual Studio Code com a extensão t3x instalada
- Se for desenvolvido em DOS use o FED Editor (Tem no FreeDOS), com o arquivo FED.SYN fornecido com o compilador

## Estrutura do código fonte

Os códigos são separados por uma hierarquia que é próxima a sua hierarquia final das imagens bootáveis.

/HUSIS - Código fonte do núcleo

## Compilando

### Windows

Sua vida é triste, mas com a gambiarra certa é posivel simular o ambiente Linux usando WSL2 e muita fé e usar ele para compilar.

### Linux/macOS

Instale o DOSBOX e a ferramenta minixfs disponível em https://github.com/humbertocsjr/minixfs , bastando compilar com:
- make clean
- ./configure
- make
- sudo make install

Após instalado basta executar um dos comandos abaixo:

- make - Compila os codigos fontes usando DOSBOX
- make img - Gera as imagens bootaveis *.img
- make test - Executa as etapas anteriores e inicia o HUSIS dentro do DOSBOX

### DOS

Por enquanto apenas consegue compilar todos os códigos fontes usando o comando MAKE.BAT, porém a ferramenta minixfs ainda não foi portada pro DJGCC ou pro GCC IA-16 para executar diretamente do DOS, impossibilitando gerar as imagens de disquete diretamente do DOS.

