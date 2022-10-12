ConstCabecas = 2
ConstSetoresPorTrilha = 18
.include BOOT.S

| Argumentos Extras
.ascii "80 2 18"
.byte 13
.byte 0

FimArgumento:
.zerob 1024-FimArgumento